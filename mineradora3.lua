-- standalone_miner_fuel.lua
-- Turtle mines 30x30x2 areas, refuels from chest

print("=== AUTO-REFUEL TURTLE MINER ===")
print("Will mine 30x30 areas, 2 levels high")
print("Unloads every 100 blocks")
print("Refuels from chest automatically")

-- Configuration
local AREA_SIZE = 30      -- Mine 30x30 area
local LEVELS = 2          -- 2 levels high
local UNLOAD_AT = 100     -- Unload every 100 blocks
local CHEST_SIDE = "top"  -- Chest location (for unloading)
local FUEL_CHEST = "top"  -- Same chest for fuel (coal storage)

-- Refuel from chest
local function refuelFromChest()
    local current_fuel = turtle.getFuelLevel()
    
    if current_fuel > 1000 then  -- Already has enough fuel
        return true
    end
    
    print("Low fuel: " .. current_fuel)
    print("Getting coal from chest...")
    
    -- Face the chest
    if FUEL_CHEST == "top" then
        -- Already can access top
    elseif FUEL_CHEST == "bottom" then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif FUEL_CHEST == "front" then
        -- Already facing
    elseif FUEL_CHEST == "back" then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif FUEL_CHEST == "right" then
        turtle.turnRight()
    elseif FUEL_CHEST == "left" then
        turtle.turnLeft()
    end
    
    -- Try to get coal from chest
    local got_fuel = false
    
    -- Look for coal in chest
    if FUEL_CHEST == "top" then
        turtle.suckUp()  -- Try to get any item from chest above
    elseif FUEL_CHEST == "bottom" then
        turtle.suckDown()
    else
        turtle.suck()
    end
    
    -- Check what we got and refuel if it's fuel
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail(slot)
        if item then
            -- Check if item is fuel
            local name = item.name:lower()
            if name:find("coal") or name:find("charcoal") or 
               name:find("lava") or name:find("blaze") then
                if turtle.refuel(1) then
                    print("Refueled with " .. name .. " from slot " .. slot)
                    got_fuel = true
                    break
                end
            end
        end
    end
    
    -- Put non-fuel items back in chest
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail(slot)
        if item and slot ~= 1 then  -- Keep slot 1 for active fuel
            local name = item.name:lower()
            if not (name:find("coal") or name:find("charcoal")) then
                if FUEL_CHEST == "top" then
                    turtle.dropUp()
                elseif FUEL_CHEST == "bottom" then
                    turtle.dropDown()
                else
                    turtle.drop()
                end
            end
        end
    end
    
    -- Face forward again
    if FUEL_CHEST == "bottom" then
        turtle.turnRight()
        turtle.turnRight()
    elseif FUEL_CHEST == "back" then
        turtle.turnRight()
        turtle.turnRight()
    elseif FUEL_CHEST == "right" then
        turtle.turnLeft()
    elseif FUEL_CHEST == "left" then
        turtle.turnRight()
    end
    
    if got_fuel then
        print("Fuel after refuel: " .. turtle.getFuelLevel())
        return true
    else
        print("No fuel found in chest!")
        return false
    end
end

-- Smart fuel check (refuels from chest if needed)
local function checkFuel()
    local fuel = turtle.getFuelLevel()
    local needed = AREA_SIZE * AREA_SIZE * 2 * 2  -- Enough for 2 full cycles
    
    if fuel < needed then
        print("Fuel low (" .. fuel .. "), refueling from chest...")
        return refuelFromChest()
    end
    return true
end

-- Move forward, digging if needed
local function moveForward()
    while not turtle.forward() do
        if turtle.detect() then
            turtle.dig()
        end
        os.sleep(0.1)
    end
    return true
end

-- Move up, digging if needed
local function moveUp()
    while not turtle.up() do
        if turtle.detectUp() then
            turtle.digUp()
        end
        os.sleep(0.1)
    end
    return true
end

-- Move down, digging if needed
local function moveDown()
    while not turtle.down() do
        if turtle.detectDown() then
            turtle.digDown()
        end
        os.sleep(0.1)
    end
    return true
end

-- Count blocks mined
local blocks_mined = 0

-- Mine a single row at current level
local function mineRow(length)
    for i = 1, length do
        if turtle.detect() then
            turtle.dig()
            blocks_mined = blocks_mined + 1
        end
        if i < length then
            moveForward()
        end
    end
end

-- Mine a complete level (AREA_SIZE x AREA_SIZE)
local function mineLevel()
    print("Mining level " .. AREA_SIZE .. "x" .. AREA_SIZE)
    
    for row = 1, AREA_SIZE do
        mineRow(AREA_SIZE)
        
        if row < AREA_SIZE then
            -- Turn for next row
            if row % 2 == 1 then
                turtle.turnRight()
                moveForward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                moveForward()
                turtle.turnLeft()
            end
        end
    end
    
    -- Return to start position
    if AREA_SIZE % 2 == 0 then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    
    for i = 1, AREA_SIZE - 1 do
        moveForward()
    end
    
    turtle.turnRight()
end

-- Mine 2 levels high (current level and level above)
local function mineTwoLevels()
    print("Mining 2 levels high...")
    
    -- Mine current level
    mineLevel()
    
    -- Move up and mine level above
    moveUp()
    turtle.turnRight()
    turtle.turnRight()  -- Turn around to mine in same pattern
    
    mineLevel()
    
    -- Turn back and move down
    turtle.turnRight()
    turtle.turnRight()
    moveDown()
end

-- Unload items to chest (but keep coal for fuel)
local function unloadToChest()
    print("Unloading " .. blocks_mined .. " blocks (keeping coal)...")
    
    -- Turn to face chest
    if CHEST_SIDE == "top" then
        -- Already can drop up
    elseif CHEST_SIDE == "bottom" then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif CHEST_SIDE == "front" then
        -- Already facing
    elseif CHEST_SIDE == "back" then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif CHEST_SIDE == "right" then
        turtle.turnRight()
    elseif CHEST_SIDE == "left" then
        turtle.turnLeft()
    end
    
    -- Drop all non-fuel items
    local unloaded = 0
    for slot = 2, 16 do
        turtle.select(slot)
        local count = turtle.getItemCount(slot)
        if count > 0 then
            local item = turtle.getItemDetail(slot)
            if item then
                local name = item.name:lower()
                -- Keep coal for fuel, drop everything else
                if not (name:find("coal") or name:find("charcoal")) then
                    if CHEST_SIDE == "top" then
                        turtle.dropUp()
                    elseif CHEST_SIDE == "bottom" then
                        turtle.dropDown()
                    else
                        turtle.drop()
                    end
                    unloaded = unloaded + count
                    print("Unloaded " .. name .. " x" .. count)
                else
                    print("Keeping " .. name .. " for fuel")
                end
            end
        end
    end
    
    -- Turn back to mining direction
    if CHEST_SIDE == "bottom" then
        turtle.turnRight()
        turtle.turnRight()
    elseif CHEST_SIDE == "back" then
        turtle.turnRight()
        turtle.turnRight()
    elseif CHEST_SIDE == "right" then
        turtle.turnLeft()
    elseif CHEST_SIDE == "left" then
        turtle.turnRight()
    end
    
    blocks_mined = 0
    print("Unloaded " .. unloaded .. " items, kept fuel")
end

-- Go down to next mining area
local function goToNextDepth()
    print("Going down to next mining area...")
    for i = 1, 2 do  -- Go down 2 blocks (since we mined 2 levels)
        moveDown()
    end
end

-- Smart inventory management
local function manageInventory()
    -- Check if inventory is getting full (14+ slots used)
    local used_slots = 0
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            used_slots = used_slots + 1
        end
    end
    
    if used_slots >= 14 then
        print("Inventory getting full (" .. used_slots .. "/16 slots)")
        return true
    end
    return false
end

-- Take coal from inventory to active fuel slot (1)
local function takeCoalFromInventory()
    for slot = 2, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail(slot)
        if item then
            local name = item.name:lower()
            if name:find("coal") or name:find("charcoal") then
                -- Move coal to slot 1 for refueling
                turtle.transferTo(1, 64)  -- Move all coal to slot 1
                turtle.select(1)
                print("Moved coal to fuel slot")
                return true
            end
        end
    end
    return false
end

-- Main mining loop
local function startMining()
    print("\n=== SETUP ===")
    print("1. Place turtle where you want to start mining")
    print("2. Place chest on TOP of turtle")
    print("3. Put COAL in chest for automatic refueling")
    print("4. Turtle will:")
    print("   - Mine 30x30 areas, 2 levels high")
    print("   - Unload ores to chest")
    print("   - Take coal from chest for fuel")
    print("   - Go deeper and repeat forever")
    
    print("\nReady to start? (y/n): ")
    if read():lower() ~= "y" then
        return
    end
    
    -- Initial fuel: try to get from chest first
    if turtle.getFuelLevel() < 500 then
        refuelFromChest()
    end
    
    local cycles = 0
    
    print("\n=== MINING STARTED ===")
    print("Press Ctrl+T to stop")
    
    -- Infinite mining loop
    while true do
        cycles = cycles + 1
        print("\n=== CYCLE " .. cycles .. " ===")
        
        -- Check and refuel from chest if needed
        if not checkFuel() then
            print("CRITICAL: No fuel available!")
            print("Please add coal to chest and press any key...")
            os.pullEvent("key")
            refuelFromChest()
        end
        
        -- Use coal from inventory if we have it
        takeCoalFromInventory()
        
        -- Refuel from slot 1 if we have coal there
        turtle.select(1)
        if turtle.getItemCount(1) > 0 then
            turtle.refuel(1)
        end
        
        -- Check inventory and unload if needed
        if manageInventory() or blocks_mined >= UNLOAD_AT then
            unloadToChest()
        end
        
        -- Mine 2 levels
        mineTwoLevels()
        
        -- Go deeper for next cycle
        goToNextDepth()
        
        -- Brief pause
        os.sleep(1)
    end
end

-- Emergency stop and unload
local function emergencyStop()
    print("\n=== EMERGENCY STOP ===")
    print("Unloading items...")
    unloadToChest()
    
    -- Refuel one last time
    refuelFromChest()
    
    print("Returning to surface...")
    for i = 1, 10 do
        if turtle.detectUp() then
            turtle.digUp()
        end
        if turtle.up() then
            -- success
        else
            break
        end
    end
    
    print("Stopped safely!")
end

-- Test chest access
local function testChestAccess()
    print("Testing chest access...")
    
    -- Try to get item from chest
    turtle.select(16)
    if FUEL_CHEST == "top" then
        if turtle.suckUp(1) then
            print("✓ Can get items from chest above")
            local item = turtle.getItemDetail(16)
            if item then
                print("Got: " .. item.name)
                turtle.dropUp()
            end
        else
            print("✗ Cannot access chest above")
        end
    end
    
    -- Try to put item in chest
    turtle.select(1)
    if turtle.getItemCount(1) > 0 then
        if FUEL_CHEST == "top" then
            if turtle.dropUp(1) then
                print("✓ Can put items in chest above")
                turtle.suckUp(1)  -- Get it back
            else
                print("✗ Cannot put items in chest")
            end
        end
    end
    
    print("Current fuel: " .. turtle.getFuelLevel())
end

-- Main menu
local function mainMenu()
    while true do
        print("\n=== AUTO-REFUEL MINER ===")
        print("Fuel: " .. turtle.getFuelLevel())
        print("Chest: " .. CHEST_SIDE .. " (for unload/fuel)")
        print("\n[1] Start mining forever")
        print("[2] Refuel from chest now")
        print("[3] Test chest access")
        print("[4] Unload ores now")
        print("[5] Check inventory")
        print("[0] Exit")
        
        term.write("Choice: ")
        local choice = read()
        
        if choice == "0" then
            print("Goodbye!")
            break
        elseif choice == "1" then
            -- Catch Ctrl+T to emergency stop
            local success, err = pcall(startMining)
            if not success then
                print("Mining stopped: " .. err)
                emergencyStop()
            end
        elseif choice == "2" then
            refuelFromChest()
        elseif choice == "3" then
            testChestAccess()
        elseif choice == "4" then
            unloadToChest()
        elseif choice == "5" then
            print("Inventory:")
            for slot = 1, 16 do
                local count = turtle.getItemCount(slot)
                if count > 0 then
                    local item = turtle.getItemDetail(slot)
                    print(slot .. ": " .. item.name .. " x" .. count)
                end
            end
        end
    end
end

-- Start
mainMenu()
