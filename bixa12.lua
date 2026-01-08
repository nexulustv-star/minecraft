-- vasya_colorful.lua
print("Starting Colorful Vasya Display")

-- Get screen
local screen = peripheral.find("monitor") or term
screen.clear()
screen.setBackgroundColor(colors.black)

-- Make text normal size (not big)
if peripheral.getType(screen) == "monitor" then
    screen.setTextScale(1.0)  -- Normal size
end

-- Text messages
local messages = {
    "VASYA IS GAY",
    "VASYA = GAY",
    "GAY VASYA",
    "VASYA GAY",
    "GAY IS VASYA"
}

-- Color list (use numbers for CC:Tweaked colors)
local colorList = {
    1,   -- white
    4,   -- yellow
    6,   -- pink
    11,  -- cyan
    12,  -- orange
    13,  -- magenta
    14,  -- lightBlue
    15   -- lightGray
}

local currentMsg = 1

print("Displaying colorful text...")
print("Ctrl+T to stop")

while true do
    screen.clear()
    
    -- Get screen size
    local width, height = screen.getSize()
    local text = messages[currentMsg]
    
    -- Calculate center position
    local startX = math.floor(width / 2 - #text / 2)
    local y = math.floor(height / 2)
    
    -- Display each letter with random color
    for i = 1, #text do
        local char = text:sub(i, i)
        local color = colorList[math.random(#colorList)]
        
        screen.setCursorPos(startX + i - 1, y)
        screen.setTextColor(color)
        screen.write(char)
    end
    
    -- Wait and change message
    sleep(3)
    
    currentMsg = currentMsg + 1
    if currentMsg > #messages then
        currentMsg = 1
    end
end
