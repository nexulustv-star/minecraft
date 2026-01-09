-- miner.lua
-- Place on EACH turtle (UNCHANGED)

print("=== TURTLE MINER ===")
print("Waiting for start signal...")
print("Face toward main computer!")

-- Config
local MINE_SIZE = 20      -- Mine 20x20 area
local UNLOAD_AT = 100     -- Unload after 100 blocks
local CHEST_ABOVE = true  -- Chest is ABOVE main computer

local mined = 0
local depth = 0
local running = true

-- Wait for start signal (redstone pulse on back)
while not redstone.getInput("back") do
    os.sleep(0.1)
end

print("STARTING MINING!")

-- Mine a single row
local function mineRow(length)
    for i = 1, length do
        if turtle.detect() then
            turtle.dig()
            mined = mined + 1
        end
        if i < length then
            while not turtle.forward() do
                turtle.dig()
            end
        end
    end
end

-- Mine square area
local function mineSquare(size)
    for row = 1, size do
        mineRow(size)
        
        if row < size then
            if row % 2 == 1 then  -- Odd row
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
            else  -- Even row
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
            end
        end
    end
    
    -- Return to start position
    if size % 2 == 0 then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    for i = 1, size - 1 do
        turtle.forward()
    end
    turtle.turnRight()
end

-- Go to surface
local function goToSurface()
    print("Going to surface...")
    for i = 1, depth * 3 do
        turtle.up()
    end
end

-- Go back to mining depth
local function goToDepth()
    print("Going back to depth...")
    for i = 1, depth * 3 do
        turtle.down()
    end
end

-- Unload to chest above main computer
local function unload()
    print("Unloading items...")
    
    -- Go to surface (where main computer is)
    goToSurface()
    
    -- Face main computer (assuming we're facing it)
    -- Drop items UP into chest above main computer
    for slot = 2, 16 do  -- Keep slot 1 for fuel
        turtle.select(slot)
        if turtle.getItemCount(slot) > 0 then
            turtle.dropUp()  -- Drop into chest ABOVE
        end
    end
    
    -- Go back to mining depth
    goToDepth()
    
    mined = 0
    print("Unload complete!")
end

-- Go deeper for next level
local function goDeeper()
    print("Going deeper...")
    for i = 1, 3 do
        if turtle.detectDown() then
            turtle.digDown()
        end
        turtle.down()
    end
    depth = depth + 1
    print("Now at depth: " .. (depth * 3))
end

-- Check for stop signal (continuous redstone on front)
local function checkStop()
    if redstone.getInput("front") then
        print("STOP signal received!")
        running = false
        return true
    end
    return false
end

-- Check for unload signal (pulses on right)
local function checkUnloadSignal()
    if redstone.getInput("right") then
        print("UNLOAD signal received!")
        os.sleep(0.5)  -- Wait for pulses to finish
        if redstone.getInput("right") then
            return true
        end
    end
    return false
end

-- Main mining loop
while running do
    -- Check signals
    if checkStop() then break end
    if checkUnloadSignal() then
        unload()
    end
    
    -- Auto-unload if needed
    if mined >= UNLOAD_AT then
        unload()
    end
    
    -- Mine current level
    print("Mining level " .. depth)
    mineSquare(MINE_SIZE)
    
    -- Go deeper for next level
    goDeeper()
    
    -- Brief pause
    os.sleep(1)
end

-- Final unload before stopping
print("Final unload...")
unload()

-- Return to surface
goToSurface()

print("=== MINING COMPLETE ===")
print("Final depth: " .. (depth * 3))
print("Total mined: " .. mined)
