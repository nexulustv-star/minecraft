-- vasya_bw.lua
print("Starting Vasya Bounce (Black & White)...")

-- Find monitor
local m = peripheral.find("monitor")
local screen = m or term

-- Setup screen
screen.setBackgroundColor(colors.black)
screen.setTextColor(colors.white)
screen.clear()

if m then
    m.setTextScale(2)
end

local width, height = screen.getSize()
local messages = {
    "VASYA IS GAY",
    "VASYA = GAY", 
    "GAY VASYA",
    "VASYA GAY",
    "GAY IS VASYA"
}

-- Starting position and direction
local posX = 1
local posY = 1
local moveX = 1
local moveY = 1
local currentMsg = 1
local frame = 0

print("Text bouncing with message changes")
print("Press ANY KEY to stop")

-- Main animation loop
while true do
    frame = frame + 1
    
    -- Clear old position
    screen.setCursorPos(posX, posY)
    screen.write("               ")  -- Clear with spaces
    
    -- Move to new position
    posX = posX + moveX
    posY = posY + moveY
    
    -- Bounce on edges
    if posX <= 1 then
        moveX = 1
        currentMsg = currentMsg + 1
        if currentMsg > #messages then currentMsg = 1 end
    end
    
    if posX + #messages[currentMsg] > width then
        moveX = -1
        currentMsg = currentMsg + 1
        if currentMsg > #messages then currentMsg = 1 end
    end
    
    if posY <= 1 then
        moveY = 1
        currentMsg = currentMsg + 1
        if currentMsg > #messages then currentMsg = 1 end
    end
    
    if posY > height then
        moveY = -1
        currentMsg = currentMsg + 1
        if currentMsg > #messages then currentMsg = 1 end
    end
    
    -- Change message every 10 frames
    if frame % 10 == 0 then
        currentMsg = currentMsg + 1
        if currentMsg > #messages then currentMsg = 1 end
    end
    
    -- Draw text at new position
    screen.setCursorPos(posX, posY)
    screen.write(messages[currentMsg])
    
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
