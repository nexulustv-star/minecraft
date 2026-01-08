-- vasya_final.lua
print("Vasya Display Starting...")

-- Setup screen
local screen = peripheral.find("monitor") or term
screen.clear()
screen.setBackgroundColor(colors.black)

if peripheral.getType(screen) == "monitor" then
    screen.setTextScale(2)
end

-- All text variations
local texts = {
    "VASYA IS GAY",
    "VASYA = GAY",
    "GAY VASYA",
    "VASYA GAY",
    "GAY IS VASYA",
    "VASYA ♥ BOYS",
    "GAY = VASYA",
    "BOYS ♥ VASYA"
}

local current = 1

print("Displaying messages...")
print("Press Ctrl+T to stop")

-- Main display loop
while true do
    -- Clear screen
    screen.clear()
    
    -- Get screen size
    local width, height
    if peripheral.getType(screen) == "monitor" then
        width, height = screen.getSize()
    else
        width, height = term.getSize()
    end
    
    local text = texts[current]
    
    -- Calculate center position
    local x = math.floor(width / 2 - #text / 2)
    local y = math.floor(height / 2)
    
    -- Display text
    screen.setTextColor(colors.white)
    screen.setCursorPos(x, y)
    screen.write(text)
    
    -- Show progress at bottom
    screen.setTextColor(colors.gray)
    screen.setCursorPos(1, height)
    screen.write("Message " .. current .. "/" .. #texts)
    
    -- Wait before changing
    sleep(2)
    
    -- Go to next message
    current = current + 1
    if current > #texts then
        current = 1
    end
end
