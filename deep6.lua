-- deepseek.lua
-- Robust DeepSeek chat for CC:Tweaked

-- PUT YOUR API KEY HERE
local API_KEY = "sk-dd67e2b4e14140b78964fc1b75ceac80"

if not http then
    print("ERROR: HTTP API not available")
    print("Add this to ComputerCraft config:")
    print("  http_enable = true")
    return
end

if API_KEY == "sk-" then
    print("ERROR: Need API key")
    print("1. Go to: https://platform.deepseek.com")
    print("2. Sign up (free)")
    print("3. Create API key")
    print("4. Edit this script with your key")
    return
end

-- Simple function to make JSON string safe
local function escape(str)
    str = str:gsub("\\", "\\\\")
    str = str:gsub('"', '\\"')
    str = str:gsub("\n", "\\n")
    str = str:gsub("\r", "\\r")
    str = str:gsub("\t", "\\t")
    return str
end

term.clear()
print("========================")
print("  DEEPSEEK AI CHAT")
print("========================")
print("\nCommands:")
print("  Type normally to ask questions")
print("  Type 'quit' or 'exit' to end")
print("  Type 'clear' to clear screen")
print("========================\n")

while true do
    term.write("You: ")
    local question = read()
    
    -- Check commands
    local q_lower = question:lower()
    if q_lower == "quit" or q_lower == "exit" then
        print("Goodbye!")
        break
    elseif q_lower == "clear" then
        term.clear()
        term.setCursorPos(1, 1)
        print("Screen cleared.\n")
        goto continue
    end
    
    if #question == 0 then
        goto continue
    end
    
    print("Waiting for response...")
    
    -- Build JSON string manually (safe way)
    local json = [[
{
  "model": "deepseek-chat",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant running on a Minecraft ComputerCraft computer. Keep answers concise."
    },
    {
      "role": "user",
      "content": "]] .. escape(question) .. [["
    }
  ],
  "max_tokens": 300,
  "temperature": 0.7
}]]
    
    -- Try to send request
    local response = http.post(
        "https://api.deepseek.com/v1/chat/completions",
        json,
        {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. API_KEY
        }
    )
    
    if not response then
        print("ERROR: No response from server")
        print("Check internet connection")
        goto continue
    end
    
    local status = response.getResponseCode()
    
    if status ~= 200 then
        print("ERROR: HTTP " .. tostring(status))
        
        -- Try to read error message
        local body = response.readAll()
        if body and #body > 0 then
            -- Look for error in response
            local err = body:match('"message":"([^"]+)"') or 
                       body:match('"error":"([^"]+)"') or
                       body:sub(1, 100)
            print("Details: " .. err)
        end
        
        if status == 401 then
            print("Invalid API key")
        elseif status == 429 then
            print("Rate limit exceeded")
        elseif status == 500 then
            print("Server error")
        end
        
        goto continue
    end
    
    -- Success! Parse the response
    local body = response.readAll()
    
    if not body or #body == 0 then
        print("ERROR: Empty response")
        goto continue
    end
    
    -- Try to find the content in the response
    -- Look for pattern: "content":"...text..."
    local start_pos = body:find('"content":"')
    
    if not start_pos then
        print("ERROR: Could not find answer in response")
        print("Raw response start: " .. body:sub(1, 100))
        goto continue
    end
    
    start_pos = start_pos + 11 -- Move past '"content":"'
    
    -- Find the closing quote (handle escaped quotes)
    local end_pos = start_pos
    local in_escape = false
    
    while end_pos <= #body do
        local char = body:sub(end_pos, end_pos)
        
        if in_escape then
            in_escape = false
        elseif char == "\\" then
            in_escape = true
        elseif char == '"' then
            break
        end
        
        end_pos = end_pos + 1
    end
    
    if end_pos > #body then
        print("ERROR: Malformed response")
        goto continue
    end
    
    -- Extract and unescape the content
    local content = body:sub(start_pos, end_pos - 1)
    
    -- Unescape common sequences
    content = content:gsub('\\"', '"')
    content = content:gsub("\\\\", "\\")
    content = content:gsub("\\n", "\n")
    content = content:gsub("\\r", "\r")
    content = content:gsub("\\t", "\t")
    
    -- Display the answer
    print("\n" .. string.rep("-", 40))
    print("DeepSeek:")
    print(content)
    print(string.rep("-", 40) .. "\n")
    
    ::continue::
end
