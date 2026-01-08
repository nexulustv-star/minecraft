-- vasya_text.lua
print("Vasya Text Display")

-- Find monitor
local m = peripheral.find("monitor")
local screen = m or term

-- Setup screen
screen.clear()
screen.setBackgroundColor(colors.black)
screen.setTextColor(colors.white)

if m then
    m.setTextScale(2)  -- Make text bigger
end

local w, h = screen.getSize()

-- Different text variations
local messages = {
    "VASYA IS GAY",
    "VASYA = GAY",
    "GAY VASYA",
    "VASYA GAY",
    "GAY IS VASYA",
    "VASYA ♥ BOYS",
    "VASYA LIKES BOYS",
    "GAY = VASYA"
}

local current = 1

print("Displaying text on screen")
print("Press SPACE to change text")
print("Press Q to quit")

-- Display first message
screen.setCursorPos(1, 1)
screen.write("Current: " .. messages[current])

screen.setCursorPos(math.floor(w/2 - #messages[current]/2), math.floor(h/2))
screen.write(messages[current])

while true do
    local event = os.pullEvent()
    
    if event == "key" then
        local key = select(2, os.pullEvent("key"))
        
        if key == keys.space then
            -- Change to next message
            current = current + 1
            if current > #messages then current = 1 end
            
            screen.clear()
            screen.setCursorPos(1, 1)
            screen.write("Text " .. current .. "/" .. #messages)
            
            screen.setCursorPos(math.floor(w/2 - #messages[current]/2), math.floor(h/2))
            screen.write(messages[current])
            
        elseif key == keys.q then
            break
        end
    end
end

screen.clear()
screen.setCursorPos(1, 1)
print("Display closed")
