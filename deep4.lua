-- ask.lua
-- Simple DeepSeek AI chat

-- Put your DeepSeek API key here
local API_KEY = "sk-dd67e2b4e14140b78964fc1b75ceac80"

-- Don't change these
local API_URL = "https://api.deepseek.com/v1/chat/completions"

-- Helper function to trim strings
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Clear screen and show welcome
term.clear()
term.setCursorPos(1, 1)

print("================================")
print("      DEEPSEEK AI CHAT")
print("================================")

-- Check if API key is set
if API_KEY == "" then
    print("\nWARNING: No API key found!")
    print("Get one from: https://platform.deepseek.com")
    print("Then edit this script and add your key.")
    print("\nPress any key to exit...")
    os.pullEvent("key")
    return
end

-- Check if HTTP is available
if not http then
    print("\nERROR: HTTP is not enabled!")
    print("Add 'http_enable=true' to CC:Tweaked config")
    print("\nPress any key to exit...")
    os.pullEvent("key")
    return
end

-- Check if JSON is available
if not require then
    print("\nERROR: require() function not available!")
    print("This computer may need rebooting.")
    print("\nPress any key to exit...")
    os.pullEvent("key")
    return
end

local json_ok, json = pcall(require, "json")
if not json_ok then
    print("\nERROR: JSON module not found!")
    print("Make sure JSON API is installed.")
    print("\nPress any key to exit...")
    os.pullEvent("key")
    return
end

print("\nReady to chat!")
print("Type 'exit' or 'quit' to end")
print("Type 'clear' to clear screen")
print("Type 'new' to start fresh")
print("================================\n")

-- Keep conversation history
local history = {}

-- Main chat loop
while true do
    -- Ask for question
    term.write("You: ")
    local question = read()
    
    -- Check for commands
    if question:lower() == "exit" or question:lower() == "quit" then
        print("\nGoodbye!")
        break
    elseif question:lower() == "clear" then
        term.clear()
        term.setCursorPos(1, 1)
        print("Chat cleared!\n")
        goto continue
    elseif question:lower() == "new" then
        history = {}
        print("Started new conversation.\n")
        goto continue
    elseif trim(question) == "" then
        goto continue
    end
    
    -- Show thinking message
    print("Thinking...")
    
    -- Prepare the request
    local messages = {
        {
            role = "system",
            content = "You are a helpful AI assistant running on a Minecraft ComputerCraft computer. Keep answers clear and concise for terminal display."
        }
    }
    
    -- Add history if we have any
    if #history > 0 then
        for _, msg in ipairs(history) do
            table.insert(messages, msg)
        end
    end
    
    -- Add current question
    table.insert(messages, {
        role = "user",
        content = question
    })
    
    -- Build request data
    local requestData = {
        model = "deepseek-chat",
        messages = messages,
        max_tokens = 500,
        temperature = 0.7
    }
    
    -- Try to send request
    local success, response = pcall(function()
        -- Convert to JSON
        local jsonData = json.encode(requestData)
        
        -- Send to DeepSeek
        local http_response = http.post(
            API_URL,
            jsonData,
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. API_KEY
            }
        )
        
        if not http_response then
            return nil, "No response from server"
        end
        
        local status = http_response.getResponseCode()
        if status ~= 200 then
            return nil, "HTTP Error: " .. tostring(status)
        end
        
        -- Read and parse response
        local responseText = http_response.readAll()
        local data = json.decode(responseText)
        
        if data and data.choices and data.choices[1] then
            return data.choices[1].message.content
        else
            return nil, "Could not get response from API"
        end
    end)
    
    -- Show response or error
    if success and response then
        print("\nDeepSeek: " .. response .. "\n")
        
        -- Save to history
        table.insert(history, {
            role = "user",
            content = question
        })
        table.insert(history, {
            role = "assistant",
            content = response
        })
        
        -- Limit history size to prevent memory issues
        if #history > 20 then
            table.remove(history, 1)
            table.remove(history, 1)
        end
    else
        print("\nERROR: " .. tostring(response))
        print("Will try again next time.\n")
    end
    
    ::continue::
end
