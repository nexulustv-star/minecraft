-- wink.lua - Animated winking smiley
term.clear()
term.setCursorPos(1, 1)

print("Animated Smiley Face")
print("Press any key to stop...")
print("")

local frames = {
    -- Frame 1: Both eyes open
    [[
       *******       
     **       **     
    *           *    
   *  O       O  *   
   *             *   
   *    _____    *   
    *           *    
     **       **     
       *******       
    ]],
    
    -- Frame 2: Winking right eye
    [[
       *******       
     **       **     
    *           *    
   *  O       -  *   
   *             *   
   *    _____    *   
    *           *    
     **       **     
       *******       
    ]],
    
    -- Frame 3: Winking left eye
    [[
       *******       
     **       **     
    *           *    
   *  -       O  *   
   *             *   
   *    _____    *   
    *           *    
     **       **     
       *******       
    ]]
}

local running = true
local frame = 1

-- Function to check for key press without blocking
local function checkKey()
    local event = os.pullEvent()
    if event == "key" then
        running = false
    end
end

-- Animation loop
while running do
    -- Clear and draw
    term.setCursorPos(1, 5)
    print(frames[frame])
    
    -- Cycle frames
    frame = frame + 1
    if frame > #frames then
        frame = 1
    end
    
    -- Wait a bit (non-blocking)
    sleep(0.5)
    
    -- Check for key press
    if os.pullEventRaw("key") then
        running = false
    end
end

term.clear()
term.setCursorPos(1, 1)
print("Animation stopped!")