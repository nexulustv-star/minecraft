-- vasya_working.lua
print("Starting Vasya Bounce...")

-- Find monitor
local m = peripheral.find("monitor")
local screen = m or term

-- Setup screen
screen.setBackgroundColor(colors.black)
screen.clear()

if m then
    m.setTextScale(2)
end

local width, height = screen.getSize()
local text = "VASYA IS GAY"
local colorList = {colors.red, colors.yellow, colors.green, colors.blue, colors.purple}

-- Starting position and direction
local posX = 1
local posY = 1
local moveX = 1
local moveY = 1
local currentColor = 1

print("Text will bounce around screen")
print("Press ANY KEY to stop")

-- Main animation loop
while true do
    -- Clear old position
    screen.setCursorPos(posX, posY)
    screen.write("            ")  -- Clear with spaces
    
    -- Move to new position
    posX = posX + moveX
    posY = posY + moveY
    
    -- Bounce on edges
    if posX <= 1 then
        moveX = 1
        currentColor = currentColor + 1
        if currentColor > #colorList then currentColor = 1 end
    end
    
    if posX + #text > width then
        moveX = -1
        currentColor = currentColor + 1
        if currentColor > #colorList then currentColor = 1 end
    end
    
    if posY <= 1 then
        moveY = 1
        currentColor = currentColor + 1
        if currentColor > #colorList then currentColor = 1 end
    end
    
    if posY > height then
        moveY = -1
        currentColor = currentColor + 1
        if currentColor > #colorList then currentColor = 1 end
    end
    
    -- Draw text at new position
    screen.setCursorPos(posX, posY)
    screen.setTextColor(colorList[currentColor])
    screen.write(text)
    
    -- Check for exit
    local event = os.pullEventRaw(0.1)
    if event == "key" then
        break
    end
end

-- Cleanup
screen.clear()
screen.setCursorPos(1, 1)
print("Animation stopped")
