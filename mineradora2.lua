-- miner_fixed.lua
-- Fixed turtle mining script

print("=== TURTLE MINER v2 ===")
print("Face toward main computer!")

-- Config
local MINE_SIZE = 20      -- Mine 20x20 area
local UNLOAD_AT = 100     -- Unload after 100 blocks

local mined = 0
local depth = 0
local running = true

-- Function to ensure we move forward
local function safeForward()
    local attempts = 0
    while not turtle.forward() do
        if turtle.detect() then
            turtle.dig()
            print("Dug block")
        end
        attempts = attempts + 1
        if attempts > 10 then
            print("Stuck! Turning...")
            turtle.turnLeft()
            return false
        end
        os.sleep(0.5)
    end
    return true
end

-- Mine a single row with movement
local function mineRow(length)
    for i = 1, length do
        -- Mine block in front
        if turtle.detect() then
            turtle.dig()
            mined = mined + 1
            print("Mined block " .. mined)
        end
        
        -- Move forward (except last block)
        if i < length then
            if not safeForward() then
                return false
            end
        end
    end
    return true
end

-- Mine square area
local function mineSquare(size)
    print("Mining " .. size .. "x" .. size .. " area...")
    
    for row = 1, size do
        print("Row " .. row .. "/" .. size)
        
        if not mineRow(size) then
            return false
        end
        
        if row < size then
            -- Turn for next row
            if row % 2 == 1 then  -- Odd row
                turtle.turnRight()
                if not safeForward() then return false end
                turtle.turnRight()
            else  -- Even row
                turtle.turnLeft()
                if not safeForward() then return false end
                turtle.turnLeft()
            end
        end
    end
    
    -- Return to start position
    print("Returning to start...")
    if size % 2 == 0 then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    
    for i = 1, size - 1 do
        if not safeForward() then return false end
    end
    
    turtle.turnRight()
    return true
end

-- Go to surface
local function goToSurface()
    print("Going to surface from depth " .. depth)
    for i = 1, depth * 3 do
        while turtle.detectUp() do
            turtle.digUp()
        end
        turtle.up()
    end
end

-- Go back to mining depth
local function goToDepth()
    print("Going back to depth " .. depth)
    for i = 1, depth * 3 do
        while turtle.detectDown() do
            turtle.digDown()
        end
        turtle.down()
    end
end

-- Unload items
local function unload()
    print("Unloading " .. mined .. " blocks...")
    
    -- Go to surface
    goToSurface()
    
    -- Drop items UP (to chest above main computer)
    local unloaded = 0
    for slot = 2, 16 do  -- Keep slot 1 for fuel
        turtle.select(slot)
        local count = turtle.getItemCount(slot)
        if count > 0 then
            turtle.dropUp()
            unloaded = unloaded + count
            print("Unloaded " .. count .. " items from slot " .. slot)
        end
    end
    
    -- Go back down
    goToDepth()
    
    mined = 0
    print("Unloaded " .. unloaded .. " total items")
end

-- Go deeper
local function goDeeper()
    print("Going deeper...")
    for i = 1, 3 do
        while turtle.detectDown() do
            turtle.digDown()
            mined = mined + 1
        end
        turtle.down()
    end
    depth = depth + 1
    print("Now at depth level " .. depth .. " (" .. (depth * 3) .. " blocks down)")
end

-- Check for stop signal
local function checkStop()
    if redstone.getInput("front") then
        print("STOP signal received!")
        return true
    end
    return false
end

-- Check for unload signal
local function checkUnloadSignal()
    if redstone.getInput("right") then
        print("Unload signal detected...")
        os.sleep(0.5)
        if redstone.getInput("right") then
            return true
        end
    end
    return false
end

-- Check fuel
local function checkFuel()
    local fuel = turtle.getFuelLevel()
    if fuel < 100 then
        turtle.select(1)
        if turtle.refuel(1) then
            print("Refueled! Fuel: " .. turtle.getFuelLevel())
        else
            print("Low fuel: " .. fuel .. " - No fuel in slot 1!")
        end
    end
end

-- TEST: Simple movement test
print("\n=== TEST MODE ===")
print("Testing movement...")

-- Test forward
print("Testing forward move...")
if turtle.detect() then
    turtle.dig()
    print("Dug block")
end

if turtle.forward() then
    print("Moved forward!")
else
    print("Can't move forward!")
    print("Make sure nothing is blocking turtle")
end

-- Test back to start
turtle.back()
print("Back to start")

-- Wait for start signal
print("\n=== WAITING FOR START ===")
print("Make sure redstone is connected:")
print("Main computer BACK -> Turtle BACK")
print("Waiting for signal...")

local waitCount = 0
while not redstone.getInput("back") do
    waitCount = waitCount + 1
    if waitCount % 10 == 0 then
        print("Still waiting... (" .. waitCount .. " seconds)")
        print("Check redstone connection!")
    end
    os.sleep(1)
end

print("\n✓ START SIGNAL RECEIVED!")
print("BEGINNING MINING OPERATION!")

-- Main mining loop
local cycle = 1
while running do
    print("\n=== CYCLE " .. cycle .. " ===")
    
    -- Check signals
    if checkStop() then
        running = false
        break
    end
    
    if checkUnloadSignal() then
        unload()
    end
    
    -- Check fuel
    checkFuel()
    
    -- Auto-unload if needed
    if mined >= UNLOAD_AT then
        print("Reached " .. mined .. " blocks, unloading...")
        unload()
    end
    
    -- Mine current level
    print("Mining at depth " .. depth)
    if not mineSquare(MINE_SIZE) then
        print("Mining failed! Trying to recover...")
        turtle.turnLeft()
        turtle.turnLeft()
        for i = 1, 10 do
            if turtle.forward() then break end
        end
    end
    
    -- Go deeper
    goDeeper()
    
    cycle = cycle + 1
    os.sleep(1)  -- Brief pause
end

-- Final operations
print("\n=== MINING STOPPED ===")
print("Final unload...")
unload()

print("Returning to surface...")
goToSurface()

print("\n=== OPERATION COMPLETE ===")
print("Total cycles: " .. (cycle - 1))
print("Final depth: " .. (depth * 3) .. " blocks")
print("Total blocks mined this session: " .. mined)
print("Turtle ready for next mission!")
