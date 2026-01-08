-- vasya_easy.lua
local s = peripheral.find("monitor") or term
s.clear()

local texts = {"VASYA IS GAY", "VASYA = GAY", "GAY VASYA"}
local i = 1

print("Changing text every 2 seconds...")

while true do
    s.clear()
    s.setCursorPos(1, 1)
    s.write(texts[i])
    
    i = i + 1
    if i > 3 then i = 1 end
    
    sleep(2)
    
    local e = os.pullEventRaw()
    if e == "key" then break end
end

s.clear()
print("Done")
