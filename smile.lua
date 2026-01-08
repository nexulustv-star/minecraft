-- turtle_controller.lua
print("=== Turtle Detection & Control System ===")
print("Detects turtles within 50 blocks")
print("Controls all detected turtles")
print("")

-- Check for wireless modem
local modem = peripheral.find("modem")
if not modem then
    print("❌ ERROR: No wireless modem attached!")
    print("Attach wireless modem to computer")
    return
end

print("✓ Wireless modem ready")

-- Configuration
local config = {
    scanRadius = 50,          -- Max distance to scan
    controlChannel = 7777,    -- Channel for commands
    pingChannel = 8888,       -- Channel for pings
    turtleResponseChannel = 9999, -- Turtles respond here
    scanInterval = 10,        -- Seconds between scans
    commandDelay = 0.5,       -- Delay between commands to turtles
    maxTurtles = 10           -- Maximum turtles to control
}

-- Open channels
modem.open(config.pingChannel)
modem.open(config.controlChannel)

-- Global turtle registry
local turtleRegistry = {}
local turtleCount = 0

-- Function to scan for turtles
local function scanForTurtles()
    print("\n=== Scanning for Turtles ===")
    print("Radius: " .. config.scanRadius .. " blocks")
    print("Pinging on channel " .. config.pingChannel)
    
    -- Send ping to all turtles
    modem.transmit(config.pingChannel, config.turtleResponseChannel, {
        type = "ping",
        from = os.getComputerID(),
        time = os.time(),
        command = "identify"
    })
    
    -- Listen for responses
    local responses = {}
    local startTime = os.clock()
    local timeout = 3  -- seconds
    
    while os.clock() - startTime < timeout do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        
        if channel == config.turtleResponseChannel and message and message.type == "pong" then
            -- Check if within range
            if distance <= config.scanRadius then
                local turtleID = message.turtleID or message.id or "unknown"
                
                if not responses[turtleID] then
                    responses[turtleID] = {
                        id = turtleID,
                        label = message.label or "Unnamed",
                        fuel = message.fuel or 0,
                        distance = math.floor(distance),
                        lastSeen = os.time(),
                        address = message.address  -- For direct messaging
                    }
                    
                    print("✓ Turtle detected: " .. turtleID)
                    print("  Label: " .. responses[turtleID].label)
                    print("  Distance: " .. distance .. " blocks")
                    print("  Fuel: " .. responses[turtleID].fuel)
                end
            end
        end
    end
    
    -- Update registry
    for id, info in pairs(responses) do
        if not turtleRegistry[id] then
            turtleCount = turtleCount + 1
            if turtleCount <= config.maxTurtles then
                turtleRegistry[id] = info
                print("📝 Registered new turtle: " .. id)
            else
                print("⚠ Maximum turtle limit reached")
                break
            end
        else
            -- Update existing turtle info
            turtleRegistry[id].lastSeen = os.time()
            turtleRegistry[id].fuel = info.fuel
            turtleRegistry[id].distance = info.distance
        end
    end
    
    -- Remove old turtles not seen in last 2 scans
    local removed = 0
    for id, info in pairs(turtleRegistry) do
        if os.time() - info.lastSeen > (config.scanInterval * 2) then
            turtleRegistry[id] = nil
            turtleCount = turtleCount - 1
            removed = removed + 1
        end
    end
    
    if removed > 0 then
        print("🗑️ Removed " .. removed .. " inactive turtles")
    end
    
    return turtleCount
end

-- Function to send command to specific turtle
local function commandTurtle(turtleID, command, data)
    if not turtleRegistry[turtleID] then
        print("❌ Turtle not found: " .. turtleID)
        return false
    end
    
    local msg = {
        type = "command",
        command = command,
        data = data or {},
        target = turtleID,
        from = os.getComputerID(),
        timestamp = os.time()
    }
    
    -- Send command
    modem.transmit(config.controlChannel, config.turtleResponseChannel, msg)
    print("📤 Command sent to " .. turtleID .. ": " .. command)
    
    -- Wait for acknowledgment
    local startTime = os.clock()
    while os.clock() - startTime < 2 do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        if channel == config.turtleResponseChannel and message and 
           message.type == "ack" and message.command == command and
           message.from == turtleID then
            print("✅ " .. turtleID .. " acknowledged: " .. command)
            return true
        end
    end
    
    print("⚠ No acknowledgment from " .. turtleID)
    return false
end

-- Function to broadcast command to all turtles
local function broadcastCommand(command, data)
    print("\n📢 Broadcasting command: " .. command)
    
    local msg = {
        type = "broadcast",
        command = command,
        data = data or {},
        from = os.getComputerID(),
        timestamp = os.time()
    }
    
    modem.transmit(config.controlChannel, config.turtleResponseChannel, msg)
    
    local responses = 0
    local startTime = os.clock()
    
    while os.clock() - startTime < 3 do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        if channel == config.turtleResponseChannel and message and 
           message.type == "ack" and message.command == command then
            responses = responses + 1
            print("  ✓ " .. (message.from or "Unknown") .. " acknowledged")
        end
    end
    
    print("📊 " .. responses .. "/" .. turtleCount .. " turtles responded")
    return responses
end

-- Function to make turtles move in pattern
local function movePattern(patternName)
    print("\n🎯 Starting movement pattern: " .. patternName)
    
    local patterns = {
        circle = {
            {cmd = "forward", data = {steps = 4}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 4}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 4}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 4}},
            {cmd = "turnRight", data = {}},
        },
        square = {
            {cmd = "forward", data = {steps = 5}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 5}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 5}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 5}},
        },
        spiral = {
            {cmd = "forward", data = {steps = 2}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 2}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 3}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 3}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 4}},
            {cmd = "turnRight", data = {}},
            {cmd = "forward", data = {steps = 4}},
        },
        random = {
            {cmd = "randomMove", data = {}},
            {cmd = "randomMove", data = {}},
            {cmd = "randomMove", data = {}},
            {cmd = "randomMove", data = {}},
            {cmd = "randomMove", data = {}},
        }
    }
    
    local pattern = patterns[patternName]
    if not pattern then
        print("❌ Pattern not found: " .. patternName)
        return
    end
    
    -- Send pattern to all turtles
    for _, step in ipairs(pattern) do
        print("  Step: " .. step.cmd)
        broadcastCommand(step.cmd, step.data)
        sleep(config.commandDelay)
    end
    
    print("✅ Pattern completed")
end

-- Function to display turtle status
local function showTurtleStatus()
    print("\n=== Turtle Status ===")
    print("Total turtles: " .. turtleCount)
    print("")
    
    if turtleCount == 0 then
        print("No turtles detected")
        return
    end
    
    for id, info in pairs(turtleRegistry) do
        local age = os.time() - info.lastSeen
        print("ID: " .. id)
        print("  Label: " .. info.label)
        print("  Distance: " .. info.distance .. " blocks")
        print("  Fuel: " .. info.fuel)
        print("  Last seen: " .. age .. " seconds ago")
        print("  Address: " .. (info.address or "N/A"))
        print("")
    end
end

-- Function to assign different tasks to turtles
local function assignTasks()
    print("\n=== Assigning Tasks ===")
    
    local tasks = {"miner", "guard", "builder", "farmer", "courier"}
    local turtleIndex = 1
    
    for id, info in pairs(turtleRegistry) do
        local task = tasks[turtleIndex] or "guard"
        turtleIndex = turtleIndex + 1
        
        print("Assigning " .. id .. " as: " .. task)
        commandTurtle(id, "setTask", {task = task})
        
        if task == "miner" then
            commandTurtle(id, "startMining", {depth = 10, width = 3})
        elseif task == "guard" then
            commandTurtle(id, "startPatrol", {radius = 15})
        end
        
        sleep(config.commandDelay)
    end
end

-- Function to form turtle formations
local function formFormation(formationType)
    print("\n⚔️  Forming formation: " .. formationType)
    
    local formations = {
        line = {
            {offsetX = 0, offsetZ = 0},
            {offsetX = 3, offsetZ = 0},
            {offsetX = -3, offsetZ = 0},
            {offsetX = 6, offsetZ = 0},
            {offsetX = -6, offsetZ = 0},
        },
        square = {
            {offsetX = 0, offsetZ = 0},
            {offsetX = 3, offsetZ = 3},
            {offsetX = -3, offsetZ = 3},
            {offsetX = 3, offsetZ = -3},
            {offsetX = -3, offsetZ = -3},
        },
        circle = {
            {offsetX = 0, offsetZ = 5},
            {offsetX = 3.5, offsetZ = 3.5},
            {offsetX = 5, offsetZ = 0},
            {offsetX = 3.5, offsetZ = -3.5},
            {offsetX = 0, offsetZ = -5},
        }
    }
    
    local formation = formations[formationType]
    if not formation then
        print("❌ Formation not found")
        return
    end
    
    local index = 1
    for id, info in pairs(turtleRegistry) do
        if index <= #formation then
            local offset = formation[index]
            commandTurtle(id, "goToRelative", {
                x = offset.offsetX,
                z = offset.offsetZ,
                y = 0
            })
            index = index + 1
        end
        sleep(config.commandDelay)
    end
    
    print("✅ Formation complete")
end

-- Main control menu
local function mainMenu()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        
        print("=== Turtle Control Center ===")
        print("Detected Turtles: " .. turtleCount)
        print("")
        print("1. Scan for Turtles")
        print("2. Show Turtle Status")
        print("3. Assign Tasks")
        print("4. Movement Patterns")
        print("5. Formations")
        print("6. Broadcast Commands")
        print("7. Individual Control")
        print("8. Auto-mode (Swarm)")
        print("9. Clear Registry")
        print("0. Exit")
        print("")
        
        -- Show quick status
        if turtleCount > 0 then
            print("Active Turtles:")
            for id, info in pairs(turtleRegistry) do
                local age = os.time() - info.lastSeen
                if age < 5 then  -- Recently active
                    print("  " .. id .. " (" .. info.label .. ")")
                end
            end
        end
        
        print("")
        write("Choice: ")
        
        local choice = read()
        
        if choice == "0" then
            print("Shutting down controller...")
            break
            
        elseif choice == "1" then
            local count = scanForTurtles()
            print("\nFound " .. count .. " turtle(s)")
            print("Press any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "2" then
            showTurtleStatus()
            print("Press any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "3" then
            assignTasks()
            print("Press any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "4" then
            print("\nMovement Patterns:")
            print("1. Circle")
            print("2. Square")
            print("3. Spiral")
            print("4. Random")
            print("5. All patterns")
            write("Pattern: ")
            
            local patternChoice = read()
            local patterns = {"circle", "square", "spiral", "random"}
            
            if patternChoice == "5" then
                for _, pattern in ipairs(patterns) do
                    movePattern(pattern)
                    sleep(1)
                end
            elseif tonumber(patternChoice) and patterns[tonumber(patternChoice)] then
                movePattern(patterns[tonumber(patternChoice)])
            end
            
            print("Press any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "5" then
            print("\nFormations:")
            print("1. Line")
            print("2. Square")
            print("3. Circle")
            write("Formation: ")
            
            local formChoice = read()
            local forms = {"line", "square", "circle"}
            
            if tonumber(formChoice) and forms[tonumber(formChoice)] then
                formFormation(forms[tonumber(formChoice)])
            end
            
            print("Press any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "6" then
            print("\nBroadcast Commands:")
            print("1. Forward all")
            print("2. Turn right all")
            print("3. Turn left all")
            print("4. Stop all")
            print("5. Gather here")
            print("6. Custom command")
            write("Command: ")
            
            local cmdChoice = read()
            local commands = {
                ["1"] = {cmd = "forward", data = {steps = 1}},
                ["2"] = {cmd = "turnRight", data = {}},
                ["3"] = {cmd = "turnLeft", data = {}},
                ["4"] = {cmd = "stop", data = {}},
                ["5"] = {cmd = "gather", data = {x=0, z=0}}
            }
            
            if cmdChoice == "6" then
                write("Enter command: ")
                local customCmd = read()
                write("Enter data (JSON): ")
                local customData = read()
                broadcastCommand(customCmd, textutils.unserializeJSON(customData or "{}"))
            elseif commands[cmdChoice] then
                broadcastCommand(commands[cmdChoice].cmd, commands[cmdChoice].data)
            end
            
            print("Press any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "7" then
            if turtleCount == 0 then
                print("No turtles to control")
                sleep(1)
            else
                print("\nSelect turtle to control:")
                local turtleList = {}
                local index = 1
                
                for id, info in pairs(turtleRegistry) do
                    print(index .. ". " .. id .. " (" .. info.label .. ")")
                    turtleList[index] = id
                    index = index + 1
                end
                
                print("")
                write("Turtle number: ")
                local turtleNum = tonumber(read())
                
                if turtleNum and turtleList[turtleNum] then
                    local turtleID = turtleList[turtleNum]
                    print("\nControlling: " .. turtleID)
                    print("Commands: forward, back, up, down, left, right, stop, status")
                    
                    while true do
                        write("Command for " .. turtleID .. ": ")
                        local cmd = read()
                        
                        if cmd == "exit" then
                            break
                        elseif cmd == "status" then
                            showTurtleStatus()
                        else
                            commandTurtle(turtleID, cmd, {})
                        end
                    end
                end
            end
            
        elseif choice == "8" then
            print("\n🚀 Starting Auto-Swarm Mode")
            print("Turtles will move autonomously")
            print("Press any key to stop")
            
            -- Start autonomous mode
            broadcastCommand("startAutonomous", {mode = "swarm"})
            
            -- Keep swarming until key press
            local running = true
            local timer = os.startTimer(0.5)
            
            while running do
                local event = os.pullEvent()
                if event == "timer" then
                    -- Send random movement commands
                    local moves = {"forward", "turnRight", "turnLeft", "dig"}
                    local randomMove = moves[math.random(#moves)]
                    broadcastCommand(randomMove, {})
                    timer = os.startTimer(0.5)
                elseif event == "key" then
                    running = false
                    broadcastCommand("stop", {})
                    print("Auto-mode stopped")
                end
            end
            
        elseif choice == "9" then
            turtleRegistry = {}
            turtleCount = 0
            print("Registry cleared")
            sleep(1)
        end
    end
end

-- Run the system
print("Initializing Turtle Controller...")
sleep(1)

-- Initial scan
scanForTurtles()

-- Start main menu
mainMenu()

print("Controller shutdown complete")
