-- simple_deepseek.lua
-- Super simple DeepSeek chat

local API_KEY = "sk-dd67e2b4e14140b78964fc1b75ceac80"

if not http then
    print("HTTP not available")
    return
end

term.clear()
print("DeepSeek Chat")
print("Type 'q' to quit")
print("--------------")

while true do
    term.write("\nYou: ")
    local q = read()
    
    if q:lower() == "q" then break end
    if q == "" then goto next end
    
    print("Processing...")
    
    -- Build simple JSON manually
    local json = '{"model":"deepseek-chat","messages":[{"role":"user","content":"' .. 
                q:gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n") .. 
                '"}],"max_tokens":300}'
    
    local resp = http.post(
        "https://api.deepseek.com/v1/chat/completions",
        json,
        {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. API_KEY
        }
    )
    
    if resp and resp.getResponseCode() == 200 then
        local text = resp.readAll()
        -- Find content in response
        local start = text:find('"content":"')
        if start then
            start = start + 11
            local ending = text:find('"', start)
            if ending then
                local answer = text:sub(start, ending - 1)
                answer = answer:gsub('\\"', '"'):gsub("\\\\", "\\"):gsub("\\n", "\n")
                print("\nAI: " .. answer)
            end
        end
    else
        print("\nError getting response")
    end
    
    ::next::
end
