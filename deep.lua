-- deepseek.lua
-- Connect to DeepSeek API for answering questions
local http = require("http")
local term = require("term")
local json = require("json")  -- CC:Tweaked's JSON library

-- Configuration
local API_KEY = "your_api_key_here"  -- Replace with your DeepSeek API key
local API_URL = "https://api.deepseek.com/v1/chat/completions"
local MODEL = "deepseek-chat"  -- or "deepseek-coder" for coding tasks

-- Check if http module is available
if not http then
    print("HTTP API is not enabled!")
    print("Add 'http_enable=true' to your ComputerCraft config")
    return
end

-- Check if json module is available
if not json then
    print("JSON module not found!")
    print("Make sure you have the JSON API installed")
    return
end

local function splitText(text, maxWidth)
    -- Simple text wrapping function
    local lines = {}
    local currentLine = ""
    
    for word in text:gmatch("%S+") do
        if #currentLine + #word + 1 <= maxWidth then
            if currentLine ~= "" then
                currentLine = currentLine .. " " .. word
            else
                currentLine = word
            end
        else
            table.insert(lines, currentLine)
            currentLine = word
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

local function displayMessage(sender, message, width)
    -- Display a message with proper formatting
    local _, screenHeight = term.getSize()
    local cursorY = select(2, term.getCursorPos())
    
    -- Add a header for the sender
    print("\n" .. string.rep("-", width))
    print(sender .. ":")
    print(string.rep("-", width))
    
    -- Wrap and display the message
    local wrappedLines = splitText(message, width - 4)
    for _, line in ipairs(wrappedLines) do
        print("  " .. line)
    end
    
    -- Check if we need to scroll
    local newCursorY = select(2, term.getCursorPos())
    if newCursorY >= screenHeight - 5 then
        print("\n[Press any key to continue...]")
        os.pullEvent("key")
        term.clear()
        term.setCursorPos(1, 1)
        print("Continuing conversation...")
    end
end

local function askDeepSeek(question, history)
    -- Send a question to DeepSeek API
    print("\nConnecting to DeepSeek...")
    
    -- Prepare messages array
    local messages = {}
    
    -- Add system message for context
    table.insert(messages, {
        role = "system",
        content = "You are DeepSeek AI assistant running on a Minecraft ComputerCraft computer. Keep responses concise and suitable for terminal display."
    })
    
    -- Add conversation history if provided
    if history then
        for _, msg in ipairs(history) do
            table.insert(messages, msg)
        end
    end
    
    -- Add the current question
    table.insert(messages, {
        role = "user",
        content = question
    })
    
    -- Prepare request data
    local requestData = {
        model = MODEL,
        messages = messages,
        max_tokens = 500,
        temperature = 0.7
    }
    
    -- Convert to JSON
    local jsonData, err = json.encode(requestData)
    if not jsonData then
        return nil, "JSON encoding failed: " .. tostring(err)
    end
    
    -- Make HTTP request
    local response = http.post(
        API_URL,
        jsonData,
        {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. API_KEY
        }
    )
    
    if not response then
        return nil, "No response from server"
    end
    
    -- Check response status
    if response.getResponseCode() ~= 200 then
        return nil, "API error: " .. tostring(response.getResponseCode())
    end
    
    -- Parse response
    local responseText = response.readAll()
    local responseData, parseErr = json.decode(responseText)
    
    if not responseData then
        return nil, "Failed to parse response: " .. tostring(parseErr)
    end
    
    -- Extract the answer
    if responseData.choices and responseData.choices[1] then
        return responseData.choices[1].message.content, nil
    else
        return nil, "No response in API answer"
    end
end

local function saveConversation(filename, history)
    -- Save conversation to a file
    local file = fs.open(filename, "w")
    if file then
        for _, msg in ipairs(history) do
            file.writeLine("[" .. msg.role .. "]: " .. msg.content)
        end
        file.close()
        return true
    end
    return false
end

local function loadConversation(filename)
    -- Load conversation from a file
    local history = {}
    if fs.exists(filename) then
        local file = fs.open(filename, "r")
        while true do
            local line = file.readLine()
            if not line then break end
            
            -- Parse line (simplified)
            local role, content = line:match("%[([^%]]+)%]: (.+)")
            if role and content then
                table.insert(history, {
                    role = role,
                    content = content
                })
            end
        end
        file.close()
    end
    return history
end

local function main()
    term.clear()
    term.setCursorPos(1, 1)
    
    local width, height = term.getSize()
    
    print(string.rep("=", width))
    print("DEEPSEEK AI ASSISTANT")
    print("Running on CC:Tweaked Computer")
    print(string.rep("=", width))
    
    if API_KEY == "your_api_key_here" then
        print("\n⚠️ WARNING: API Key not configured!")
        print("Please edit this script and set your DeepSeek API key")
        print("Get one from: https://platform.deepseek.com/api_keys")
        print("\nPress any key to continue in demo mode...")
        os.pullEvent("key")
    end
    
    local conversationHistory = {}
    local conversationFile = "deepseek_chat.txt"
    
    -- Try to load previous conversation
    conversationHistory = loadConversation(conversationFile)
    if #conversationHistory > 0 then
        print("\nLoaded previous conversation (" .. #conversationHistory .. " messages)")
    end
    
    print("\n" .. string.rep("=", width))
    print("Type 'quit', 'exit', or 'bye' to end the conversation")
    print("Type 'clear' to clear conversation history")
    print("Type 'save' to save conversation to file")
    print("Type 'help' for available commands")
    print(string.rep("=", width))
    
    while true do
        print("\n> You: ")
        term.write("> ")
        local question = read()
        
        -- Check for commands
        if question:lower() == "quit" or question:lower() == "exit" or question:lower() == "bye" then
            print("\nSaving conversation...")
            saveConversation(conversationFile, conversationHistory)
            print("Goodbye!")
            break
            
        elseif question:lower() == "clear" then
            conversationHistory = {}
            term.clear()
            term.setCursorPos(1, 1)
            print("Conversation cleared!")
            continue
            
        elseif question:lower() == "save" then
            if saveConversation(conversationFile, conversationHistory) then
                print("Conversation saved to " .. conversationFile)
            else
                print("Failed to save conversation")
            end
            continue
            
        elseif question:lower() == "help" then
            displayMessage("Help", "Available commands:\n- quit/exit/bye: End conversation\n- clear: Clear history\n- save: Save to file\n- help: Show this help\n\nJust type normally to ask DeepSeek a question!", width)
            continue
            
        elseif question:trim() == "" then
            continue
        end
        
        -- Add user message to history
        table.insert(conversationHistory, {
            role = "user",
            content = question
        })
        
        -- Get response from DeepSeek
        local response, err = askDeepSeek(question, conversationHistory)
        
        if err then
            -- If API fails, use a fallback response
            displayMessage("System Error", "API Error: " .. err .. "\n\nRunning in fallback mode...", width)
            response = "I apologize, but I'm having trouble connecting to my servers right now. "
            response = response .. "You asked: '" .. question .. "'. "
            response = response .. "In a real response, I would provide a helpful answer to your question."
        end
        
        -- Display the response
        displayMessage("DeepSeek", response, width)
        
        -- Add assistant response to history
        table.insert(conversationHistory, {
            role = "assistant",
            content = response
        })
        
        -- Limit history size to prevent memory issues
        if #conversationHistory > 20 then
            table.remove(conversationHistory, 1)
            table.remove(conversationHistory, 1)
        end
    end
end

-- Alternative: Simple one-shot query function
local function quickQuery()
    print("Ask DeepSeek a question:")
    print("(Type 'exit' to quit)")
    
    while true do
        term.write("> ")
        local question = read()
        
        if question:lower() == "exit" then
            break
        end
        
        local response, err = askDeepSeek(question)
        if err then
            print("Error: " .. err)
            -- Fallback response
            print("DeepSeek (offline): I'd normally answer: '" .. question .. "'")
        else
            print("\nDeepSeek: " .. response .. "\n")
        end
    end
end

-- Check command line arguments
local args = {...}
if #args > 0 and args[1] == "quick" then
    quickQuery()
else
    main()
end
