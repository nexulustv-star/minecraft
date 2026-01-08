-- vasya_auto.lua
local screen = peripheral.find("monitor") or term
screen.clear()
screen.setBackgroundColor(colors.black)
screen.setTextColor(colors.white)

if peripheral.getType(screen) == "monitor" then
    screen.setTextScale(2)
end

local w, h = screen.getSize()
local texts = {
    "VASYA IS GAY",
    "VASYA = GAY", 
    "GAY VASYA",
    "VASYA GAY",
    "GAY IS VASYA"
}
local index = 1

print("Auto-changing text every 2 seconds")
print("Press any key to stop")

while true do
    -- Clear screen
    screen.clear()
    
    -- Show current text count
    screen.setCursorPos(1, 1)
    screen.write(index .. "/" .. #texts)
    
    -- Show the text in center
    local text = texts[index]
    local x = math.floor(w/2 - #text/2)
    local y = math.floor(h/2)
    
    screen.setCursorPos(x, y)
    screen.write(text)
    
    -- Wait 2 seconds or for key press
    local event = os.pullEventRaw(2)
    if event == "key" then
        break
    end
    
    -- Next text
    index = index + 1
    if index > #texts then index = 1 end
end

screen.clear()
print("Done")
