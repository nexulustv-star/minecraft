-- smart_radial_miner.lua
-- Advanced turtle that mines radially, descends levels, and returns to unload

print("=== SMART RADIAL MINER ===")

-- Check if turtle
if not turtle then
    print("ERROR: Must run on a turtle!")
    return
end

-- Configuration
local MAX_RADIUS = 50
local MAX_LEVELS = 10
local BLOCKS_PER_LEVEL = 3  -- How far down to go each level
local HOME_SIDE = "back"    -- Side where chest is for unloading

-- Navigation tracking
local posX, posY, posZ = 0, 0, 0  -- Current position
local facing = 0  -- 0=North, 1=East, 2=South, 3=West
local homeX, homeY, homeZ = 0, 0, 0  -- Home/chest position
local pathMemory = {}  -- Remember path for return

-- Ores to mine
local valuableOres = {
    "diamond", "emerald", "gold", "iron", "copper",
    "redstone", "lapis", "coal", "quartz", "ancient_debris"
}

-- Initialize
local function init()
    print("Initializing Smart Miner...")
    homeX, homeY, homeZ = 0, 0, 0
    posX, posY, posZ = 0, 0, 0
    facing = 0  -- Start facing North
    pathMemory = {{x=0, y=0, z=0, action="start"}}
    print("Home set to (0,0,0)")
end

-- Fuel management
local function checkFuel(needed)
    local fuel = turtle.getFuelLevel()
    if fuel < needed then
        print("Low fuel: " .. fuel .. " (need " .. needed .. ")")
        turtle.select(1)
        if turtle.refuel(1) then
            print("Refueled to " .. turtle.getFuelLevel())
            return true
        else
            print("No fuel in slot 1!")
            return false
        end
    end
    return true
end

-- Navigation functions
local function turnTo(dir)
    while facing ~= dir do
        turtle.turnRight()
        facing = (facing + 1) % 4
        table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="turn"})
    end
end

local function moveTo(x, y, z)
    -- Move vertically first
    while posY ~= y do
        if posY < y then
            while turtle.detectUp() do
                turtle.digUp()
            end
            if turtle.up() then
                posY = posY + 1
                table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="up"})
            end
        else
            while turtle.detectDown() do
                turtle.digDown()
            end
            if turtle.down() then
                posY = posY - 1
                table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="down"})
            end
        end
    end
    
    -- Move horizontally
    while posX ~= x or posZ ~= z do
        if posX < x then
            turnTo(1)  -- Face East
            while turtle.detect() do
                turtle.dig()
            end
            if turtle.forward() then
                posX = posX + 1
                table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="east"})
            end
        elseif posX > x then
            turnTo(3)  -- Face West
            while turtle.detect() do
                turtle.dig()
            end
            if turtle.forward() then
                posX = posX - 1
                table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="west"})
            end
        elseif posZ < z then
            turnTo(2)  -- Face South
            while turtle.detect() do
                turtle.dig()
            end
            if turtle.forward() then
                posZ = posZ + 1
                table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="south"})
            end
        elseif posZ > z then
            turnTo(0)  -- Face North
            while turtle.detect() do
                turtle.dig()
            end
            if turtle.forward() then
                posZ = posZ - 1
                table.insert(pathMemory, {x=posX, y=posY, z=posZ, action="north"})
            end
        end
    end
end

local function returnToHome()
    print("Returning to home to unload...")
    moveTo(homeX, homeY, homeZ)
    turnTo(0)  -- Face North (toward chest)
end

local function goToMiningPosition(level)
    print("Going to mining level " .. level)
    local targetY = homeY - (level * BLOCKS_PER_LEVEL)
    moveTo(0, targetY, 0)
    posX, posZ = 0, 0  -- Reset to center for mining
end

-- Inventory management
local function isOre(itemName)
    if not itemName then return false end
    itemName = itemName:lower()
    for _, ore in ipairs(valuableOres) do
        if itemName:find(ore) then
            return true
        end
    end
    return false
end

local function inventoryFull()
    local usedSlots = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            usedSlots = usedSlots + 1
        end
    end
    return usedSlots >= 14  -- Leave 2 slots empty
end

local function unloadToChest()
    print("Unloading to chest...")
    
    -- Face the chest (assuming chest is at HOME_SIDE)
    if HOME_SIDE == "back" then
        turnTo(2)  -- Face South (behind)
    elseif HOME_SIDE == "front" then
        turnTo(0)  -- Face North
    elseif HOME_SIDE == "right" then
        turnTo(1)  -- Face East
    elseif HOME_SIDE == "left" then
        turnTo(3)  -- Face West
    end
    
    -- Drop all non-fuel items
    for i = 2, 16 do  -- Keep slot 1 for fuel
        turtle.select(i)
        local count = turtle.getItemCount(i)
        if count > 0 then
            local item = turtle.getItemDetail(i)
            if item and isOre(item.name) then
                turtle.drop()
                print("Unloaded " .. item.name .. " x" .. count)
            end
        end
    end
    
    -- Turn back to mining direction
    turnTo(0)
    print("Unload complete!")
end

local function smartMineBlock()
    local minedOre = false
    
    -- Check if block in front is ore
    local success, data = turtle.inspect()
    if success then
        if isOre(data.name) then
            turtle.dig()
            minedOre = true
            print("Mined ore: " .. data.name)
        elseif data.name:find("stone") or data.name:find("dirt") or data.name:find("gravel") then
            turtle.dig()  -- Mine through common blocks
        end
    end
    
    return minedOre
end

-- Radial mining pattern
local function mineRadialCircle(radius, level)
    print("Mining circle radius " .. radius .. " at level " .. level)
    
    local totalOres = 0
    local steps = 0
    
    -- Start from center, mine outward in spiral
    for r = 1, radius do
        -- Mine 4 sides of the square
        for side = 1, 4 do
            -- Mine this side
            for step = 1, (r * 2) do
                -- Check fuel every 10 steps
                if steps % 10 == 0 then
                    checkFuel(100)
                end
                
                -- Check inventory
                if inventoryFull() then
                    print("Inventory full, returning to unload...")
                    returnToHome()
                    unloadToChest()
                    goToMiningPosition(level)
                end
                
                -- Mine block in front
                if smartMineBlock() then
                    totalOres = totalOres + 1
                end
                
                -- Move forward
                while not turtle.forward() do
                    turtle.dig()
                end
                
                -- Update position based on facing
                if facing == 0 then
                    posZ = posZ - 1
                elseif facing == 1 then
                    posX = posX + 1
                elseif facing == 2 then
                    posZ = posZ + 1
                elseif facing == 3 then
                    posX = posX - 1
                end
                
                steps = steps + 1
                
                -- Mine adjacent walls (vein mining)
                turtle.turnLeft()
                local success, leftData = turtle.inspect()
                if success and isOre(leftData.name) then
                    turtle.dig()
                    totalOres = totalOres + 1
                end
                turtle.turnRight()
                
                turtle.turnRight()
                local success, rightData = turtle.inspect()
                if success and isOre(rightData.name) then
                    turtle.dig()
                    totalOres = totalOres + 1
                end
                turtle.turnLeft()
                
                -- Mine above and below
                local success, upData = turtle.inspectUp()
                if success and isOre(upData.name) then
                    turtle.digUp()
                    totalOres = totalOres + 1
                end
                
                local success, downData = turtle.inspectDown()
                if success and isOre(downData.name) then
                    turtle.digDown()
                    totalOres = totalOres + 1
                end
            end
            
            -- Turn for next side
            turtle.turnRight()
            facing = (facing + 1) % 4
        end
        
        -- Move to next radius (diagonal)
        turtle.turnRight()
        facing = (facing + 1) % 4
        while not turtle.forward() do
            turtle.dig()
        end
        turtle.turnLeft()
        facing = (facing + 3) % 4
        
        -- Update position
        if facing == 0 then
            posZ = posZ - 1
            posX = posX - 1
        elseif facing == 1 then
            posX = posX + 1
            posZ = posZ - 1
        elseif facing == 2 then
            posZ = posZ + 1
            posX = posX + 1
        elseif facing == 3 then
            posX = posX - 1
            posZ = posZ + 1
        end
        
        print("Radius " .. r .. " complete. Ores: " .. totalOres)
    end
    
    -- Return to center
    print("Returning to center of circle...")
    moveTo(0, posY, 0)
    
    return totalOres
end

-- Main mining sequence
local function startMining()
    init()
    
    print("\n=== SETUP ===")
    print("1. Place turtle at mining center")
    print("2. Place chest behind turtle for unloading")
    print("3. Put fuel in slot 1")
    print("4. Turtle will mine " .. MAX_RADIUS .. " block radius")
    print("5. Will dig " .. MAX_LEVELS .. " levels down")
    
    print("\nReady to start? (y/n)")
    if read():lower() ~= "y" then
        return
    end
    
    -- Initial fuel check
    local estimatedFuel = MAX_RADIUS * MAX_RADIUS * MAX_LEVELS * 2
    if not checkFuel(estimatedFuel) then
        print("Not enough fuel!")
        return
    end
    
    local totalOresAllLevels = 0
    
    for level = 1, MAX_LEVELS do
        print("\n=== MINING LEVEL " .. level .. " ===")
        
        -- Go to this level
        goToMiningPosition(level)
        
        -- Mine this level
        local oresThisLevel = mineRadialCircle(MAX_RADIUS, level)
        totalOresAllLevels = totalOresAllLevels + oresThisLevel
        
        print("Level " .. level .. " complete: " .. oresThisLevel .. " ores")
        
        -- Return to unload after each level
        if oresThisLevel > 0 then
            returnToHome()
            unloadToChest()
        end
        
        -- Ask if continue to next level
        if level < MAX_LEVELS then
            print("\nContinue to level " .. (level + 1) .. "? (y/n)")
            if read():lower() ~= "y" then
                break
            end
        end
    end
    
    -- Final unload
    returnToHome()
    unloadToChest()
    
    print("\n=== MINING COMPLETE ===")
    print("Total ores mined: " .. totalOresAllLevels)
    print("Final fuel: " .. turtle.getFuelLevel())
    print("Returned to home position")
end

-- Emergency return function
local function emergencyReturn()
    print("EMERGENCY RETURN TO HOME!")
    returnToHome()
    unloadToChest()
    print("Safe at home!")
end

-- Status display
local function showStatus()
    print("\n=== MINER STATUS ===")
    print("Position: (" .. posX .. "," .. posY .. "," .. posZ .. ")")
    print("Facing: " .. facing)
    print("Fuel: " .. turtle.getFuelLevel())
    print("Home: (" .. homeX .. "," .. homeY .. "," .. homeZ .. ")")
    
    local oreCount = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            local item = turtle.getItemDetail(i)
            if item and isOre(item.name) then
                oreCount = oreCount + turtle.getItemCount(i)
            end
        end
    end
    print("Ores in inventory: " .. oreCount)
end

-- Main menu
local function mainMenu()
    while true do
        print("\n=== SMART RADIAL MINER ===")
        print("[1] Start automatic mining")
        print("[2] Emergency return to home")
        print("[3] Show status")
        print("[4] Set new home position")
        print("[5] Test movement")
        print("[0] Exit")
        
        term.write("Choice: ")
        local choice = read()
        
        if choice == "0" then
            print("Goodbye!")
            break
        elseif choice == "1" then
            startMining()
        elseif choice == "2" then
            emergencyReturn()
        elseif choice == "3" then
            showStatus()
        elseif choice == "4" then
            print("Setting current position as home...")
            homeX, homeY, homeZ = posX, posY, posZ
            print("New home: (" .. homeX .. "," .. homeY .. "," .. homeZ .. ")")
        elseif choice == "5" then
            print("Testing movement...")
            moveForward()
            os.sleep(1)
            turtle.back()
            print("Test complete")
        end
    end
end

-- Helper movement function
local function moveForward()
    while not turtle.forward() do
        turtle.dig()
    end
    if facing == 0 then
        posZ = posZ - 1
    elseif facing == 1 then
        posX = posX + 1
    elseif facing == 2 then
        posZ = posZ + 1
    elseif facing == 3 then
        posX = posX - 1
    end
end

-- Start the program
mainMenu()
