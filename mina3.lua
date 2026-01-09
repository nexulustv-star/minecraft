-- master_miner.lua
-- Main computer controls multiple turtles in area

print("=== MASTER MINING CONTROLLER ===")

-- Check if we have peripheral support for turtles
local function findTurtles()
    local turtles = {}
    local peripherals = peripheral.getNames()
    
    for _, name in ipairs(peripherals) do
        if peripheral.getType(name) == "turtle" then
            table.insert(turtles, {
                name = name,
                peripheral = peripheral.wrap(name),
                busy = false,
                depth = 0,
                mined = 0
            })
        end
    end
    
    return turtles
end

-- Broadcast command to all turtles
local function broadcastCommand(turtles, command, ...)
    print("Broadcasting: " .. command)
    local results = {}
    
    for i, turtle in ipairs(turtles) do
        local func = turtle.peripheral[command]
        if func then
            local success, result = pcall(func, ...)
            results[i] = {success = success, result = result}
        end
    end
    
    return results
end

-- Send individual command to turtle
local function sendCommand(turtle, command, ...)
    local func = turtle.peripheral[command]
    if func then
        local success, result = pcall(func, ...)
        return success, result
    end
    return false, "Command not found"
end

-- Initialize turtles for mining
local function setupTurtles(turtles)
    print("Setting up " .. #turtles .. " turtles...")
    
    -- Send setup commands
    broadcastCommand(turtles, "turnRight")
    os.sleep(0.5)
    broadcastCommand(turtles, "turnLeft")
    os.sleep(0.5)
    
    -- Check fuel on all turtles
    for i, turtle in ipairs(turtles) do
        local fuel = turtle.peripheral.getFuelLevel()
        print("Turtle " .. i .. " fuel: " .. fuel)
        
        if fuel < 1000 then
            turtle.peripheral.select(1)
            turtle.peripheral.refuel(1)
        end
    end
end

-- Mining program to send to turtles
local mining_program = [[
-- turtle_miner.lua
-- Worker turtle controlled by master

local CHUNK_SIZE = 20
local UNLOAD_AT = 100
local CHEST_SIDE = "up"  -- Chest is above master computer

local mined = 0
local depth = 0
local total_mined = 0

-- Simple mining function
function mineForward()
    if turtle.detect() then
        turtle.dig()
        mined = mined + 1
        total_mined = total_mined + 1
        return true
    end
    return false
end

function mineChunk()
    print("Mining chunk " .. CHUNK_SIZE .. "x" .. CHUNK_SIZE)
    
    for x = 1, CHUNK_SIZE do
        for z = 1, CHUNK_SIZE do
            -- Mine and move
            mineForward()
            
            if z < CHUNK_SIZE then
                while not turtle.forward() do
                    turtle.dig()
                end
            end
            
            -- Mine sides
            turtle.turnLeft()
            if turtle.detect() then turtle.dig() end
            turtle.turnRight()
            
            turtle.turnRight()
            if turtle.detect() then turtle.dig() end
            turtle.turnLeft()
            
            -- Mine up/down
            if turtle.detectUp() then turtle.digUp() end
            if turtle.detectDown() then turtle.digDown() end
        end
        
        -- Turn around at end of row
        if x < CHUNK_SIZE then
            turtle.turnRight()
            while not turtle.forward() do
                turtle.dig()
            end
            turtle.turnRight()
        end
    end
    
    -- Return to start of chunk
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, CHUNK_SIZE - 1 do
        turtle.forward()
    end
    turtle.turnRight()
    turtle.turnRight()
end

function goDeeper()
    print("Going deeper...")
    for i = 1, 3 do  -- Go down 3 blocks
        while turtle.detectDown() do
            turtle.digDown()
        end
        turtle.down()
    end
    depth = depth + 1
end

function unloadToMaster()
    print("Returning to master to unload...")
    
    -- Go up to surface
    for i = 1, depth * 3 do
        turtle.up()
    end
    
    -- Find master computer (chest above it)
    -- For now, just drop items up
    for slot = 2, 16 do
        turtle.select(slot)
        if turtle.getItemCount(slot) > 0 then
            turtle.dropUp()
        end
    end
    
    -- Go back down to mining depth
    for i = 1, depth * 3 do
        turtle.down()
    end
    
    mined = 0  -- Reset counter
end

-- Main loop
while true do
    -- Check if need to unload
    if total_mined >= UNLOAD_AT then
        unloadToMaster()
    end
    
    -- Mine current chunk
    mineChunk()
    
    -- Go deeper
    goDeeper()
    
    -- Wait for next command from master
    redstone.setOutput("bottom", true)
    os.sleep(0.1)
    redstone.setOutput("bottom", false)
    
    -- Check for stop signal
    if redstone.getInput("top") then
        break
    end
end

print("Mining complete! Total mined: " .. total_mined)
]]

-- Deploy program to all turtles
local function deployToTurtles(turtles)
    print("Deploying mining program to turtles...")
    
    -- Save program to file
    local file = fs.open("miner_program.lua", "w")
    file.write(mining_program)
    file.close()
    
    -- Send to each turtle
    for i, turtle in ipairs(turtles) do
        print("Sending to turtle " .. i .. "...")
        
        -- Open file on turtle
        local success = sendCommand(turtle, "run", "delete miner.lua")
        
        -- We'll use redstone to signal turtles instead
        turtle.busy = false
    end
    
    print("Deployment complete!")
end

-- Control loop for master computer
local function controlLoop()
    local turtles = findTurtles()
    
    if #turtles == 0 then
        print("No turtles found!")
        print("Place turtles within 10 blocks of this computer")
        return
    end
    
    print("Found " .. #turtles .. " turtles")
    setupTurtles(turtles)
    
    -- Create chest above computer for unloading
    print("\n=== SETUP INSTRUCTIONS ===")
    print("1. Place a chest ABOVE this computer")
    print("2. Turtles will unload items there")
    print("3. Each turtle mines 20x20 area")
    print("4. Goes 3 blocks deeper each level")
    print("5. Unloads after 100 blocks mined")
    
    print("\nReady to start? (y/n): ")
    if read():lower() ~= "y" then
        return
    end
    
    -- Signal turtles to start
    print("Starting mining operation...")
    redstone.setOutput("bottom", true)
    os.sleep(1)
    redstone.setOutput("bottom", false)
    
    -- Monitor progress
    local activeTurtles = #turtles
    local cycle = 1
    
    while activeTurtles > 0 do
        term.clear()
        print("=== MINING CONTROL CENTER ===")
        print("Cycle: " .. cycle)
        print("Active turtles: " .. activeTurtles)
        print("\nTurtle Status:")
        
        -- Check each turtle's redstone signal
        for i, turtle in ipairs(turtles) do
            if not turtle.busy then
                -- Send start signal
                redstone.setOutput("front", true)
                os.sleep(0.1)
                redstone.setOutput("front", false)
                turtle.busy = true
            end
            
            -- Monitor via redstone (turtle pulses when done with chunk)
            if redstone.getInput("back") then
                print("Turtle " .. i .. ": Chunk complete")
                turtle.mined = turtle.mined + 400  -- 20x20 = 400 blocks
                
                if turtle.mined >= 100 then
                    print("Turtle " .. i .. ": Returning to unload")
                    turtle.mined = 0
                end
            end
        end
        
        print("\nPress Ctrl+T to stop all turtles")
        os.sleep(5)  -- Check every 5 seconds
        cycle = cycle + 1
    end
end

-- Simple redstone control version
local function simpleControl()
    print("=== SIMPLE TURTLE CONTROLLER ===")
    
    local turtles = findTurtles()
    if #turtles == 0 then
        print("No turtles found nearby")
        return
    end
    
    print("Found " .. #turtles .. " turtles")
    print("\nCommands to give each turtle:")
    print("\n-- COPY THIS TO EACH TURTLE --")
    print([[
-- Simple mining script for master control
local mined = 0
local depth = 0

while true do
    -- Mine 20 blocks forward
    for i = 1, 20 do
        if turtle.detect() then turtle.dig() end
        turtle.forward()
        mined = mined + 1
        
        -- Mine sides occasionally
        if i % 5 == 0 then
            turtle.turnLeft()
            if turtle.detect() then turtle.dig() end
            turtle.turnRight()
            
            turtle.turnRight()
            if turtle.detect() then turtle.dig() end
            turtle.turnLeft()
        end
    end
    
    -- Turn around and return
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 20 do
        turtle.forward()
    end
    turtle.turnRight()
    turtle.turnRight()
    
    -- Go deeper every 4 passes
    depth = depth + 1
    if depth % 4 == 0 then
        for i = 1, 3 do
            turtle.down()
        end
    end
    
    -- Unload every 100 blocks
    if mined >= 100 then
        -- Return to surface
        for i = 1, (depth // 4) * 3 do
            turtle.up()
        end
        
        -- Unload to chest above master
        for slot = 2, 16 do
            turtle.select(slot)
            turtle.dropUp()
        end
        
        -- Go back down
        for i = 1, (depth // 4) * 3 do
            turtle.down()
        end
        
        mined = 0
    end
    
    -- Signal master we're done with cycle
    redstone.setOutput("bottom", true)
    os.sleep(0.1)
    redstone.setOutput("bottom", false)
    
    -- Check for stop signal from master
    if redstone.getInput("top") then
        break
    end
end
]])
    
    print("\n-- MASTER CONTROL --")
    print("Place chest ABOVE this computer")
    print("Turtles will unload items there")
    
    print("\nStart mining? (y/n): ")
    if read():lower() == "y" then
        -- Start signal
        redstone.setOutput("all", true)
        os.sleep(1)
        redstone.setOutput("all", false)
        
        print("Turtles started!")
        print("They will mine and auto-unload")
        
        -- Monitor
        while true do
            print("\n[1] Stop all turtles")
            print("[2] Emergency return")
            print("[3] Check status")
            print("[0] Exit monitor")
            
            local choice = read()
            if choice == "1" then
                redstone.setOutput("top", true)  -- Stop signal
                print("Stop signal sent!")
                break
            elseif choice == "2" then
                -- Emergency return signal
                for i = 1, 5 do
                    redstone.setOutput("left", true)
                    os.sleep(0.2)
                    redstone.setOutput("left", false)
                    os.sleep(0.2)
                end
                print("Emergency return signal sent!")
            elseif choice == "3" then
                print("Monitoring... (Ctrl+T to exit)")
                os.sleep(3)
            elseif choice == "0" then
                break
            end
        end
    end
end

-- Main menu
while true do
    term.clear()
    print("=== MASTER MINING CONTROL ===")
    print("\n[1] Start automatic turtle control")
    print("[2] Simple redstone control")
    print("[3] Find connected turtles")
    print("[4] Send test command to turtles")
    print("[5] Setup instructions")
    print("[0] Exit")
    
    term.write("\nChoice: ")
    local choice = read()
    
    if choice == "0" then
        print("Goodbye!")
        break
    elseif choice == "1" then
        controlLoop()
    elseif choice == "2" then
        simpleControl()
    elseif choice == "3" then
        local turtles = findTurtles()
        print("\nFound " .. #turtles .. " turtles:")
        for i, turtle in ipairs(turtles) do
            local fuel = turtle.peripheral.getFuelLevel()
            print(i .. ". " .. turtle.name .. " (Fuel: " .. fuel .. ")")
        end
        print("\nPress any key...")
        os.pullEvent("key")
    elseif choice == "4" then
        local turtles = findTurtles()
        if #turtles > 0 then
            print("Testing turtles...")
            broadcastCommand(turtles, "turnRight")
            os.sleep(1)
            broadcastCommand(turtles, "turnLeft")
            print("Test complete!")
        else
            print("No turtles found!")
        end
        os.sleep(2)
    elseif choice == "5" then
        term.clear()
        print("=== SETUP INSTRUCTIONS ===")
        print("\n1. Place main computer as control center")
        print("2. Place turtles within 10 blocks radius")
        print("3. Place a CHEST ABOVE the main computer")
        print("4. All turtles must have:")
        print("   - Fuel in slot 1")
        print("   - Empty inventory")
        print("\n5. Turtles will:")
        print("   - Mine 20x20 area each")
        print("   - Go 3 blocks deeper each level")
        print("   - Unload to chest after 100 blocks")
        print("   - Return automatically to mine")
        print("\nPress any key...")
        os.pullEvent("key")
    end
end
