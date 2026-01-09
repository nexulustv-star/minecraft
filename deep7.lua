-- admin.lua
-- Server Administration Tool for Minecraft
-- Requires CC:Tweaked with commands permission

local term = require("term")
local commands = commands or {}

-- Check if we have command permissions
if not commands then
    print("ERROR: Command computer not enabled!")
    print("Add to server.properties:")
    print("  enable-command-block=true")
    print("Or in ComputerCraft config:")
    print("  command.computer=computers-command")
    return
end

-- Admin database (simple file storage)
local admin_file = "admin_data.txt"
local banned_players = {}
local warnings = {}
local logs = {}

-- Load data from file
local function loadData()
    if fs.exists(admin_file) then
        local file = fs.open(admin_file, "r")
        local data = file.readAll()
        file.close()
        
        -- Simple parsing (in real use, you'd want better parsing)
        for line in data:gmatch("[^\n]+") do
            if line:find("BAN:") then
                local player = line:match("BAN:(%S+)")
                if player then table.insert(banned_players, player) end
            elseif line:find("WARN:") then
                local player, count = line:match("WARN:(%S+) (%d+)")
                if player then warnings[player] = tonumber(count) or 1 end
            end
        end
    end
end

-- Save data to file
local function saveData()
    local file = fs.open(admin_file, "w")
    
    for _, player in ipairs(banned_players) do
        file.writeLine("BAN:" .. player)
    end
    
    for player, count in pairs(warnings) do
        file.writeLine("WARN:" .. player .. " " .. count)
    end
    
    file.close()
end

-- Log an action
local function logAction(action, target, details)
    local entry = os.date("%Y-%m-%d %H:%M:%S") .. " | " .. action .. " | " .. target .. " | " .. (details or "")
    table.insert(logs, entry)
    
    -- Keep only last 100 logs
    if #logs > 100 then
        table.remove(logs, 1)
    end
    
    -- Also save to file
    local log_file = fs.open("admin_logs.txt", "a")
    log_file.writeLine(entry)
    log_file.close()
    
    return entry
end

-- Execute a Minecraft command
local function runCommand(cmd)
    print("Executing: " .. cmd)
    local success, result = commands.exec(cmd)
    
    if success then
        print("✓ Success")
        return true, result
    else
        print("✗ Failed: " .. (result or "Unknown error"))
        return false, result
    end
end

-- Player Management
local function playerManagement()
    while true do
        term.clear()
        print("=== PLAYER MANAGEMENT ===")
        print("[1] List Online Players")
        print("[2] Kick Player")
        print("[3] Ban Player")
        print("[4] Unban Player")
        print("[5] Give Warning")
        print("[6] Teleport Player")
        print("[7] Set Gamemode")
        print("[8] Check Player Inventory")
        print("[9] Clear Player Inventory")
        print("[0] Return to Main Menu")
        
        print("\nSelect option: ")
        local choice = read()
        
        if choice == "0" then break end
        
        if choice == "1" then
            -- List players (this would need server-specific integration)
            print("\nOnline Players:")
            print("(Feature requires server mod/plugin)")
            
        elseif choice == "2" then
            print("\nEnter player name to kick: ")
            local player = read()
            print("Enter reason (optional): ")
            local reason = read()
            
            local cmd = "kick " .. player
            if reason and reason ~= "" then
                cmd = cmd .. " " .. reason
            end
            
            runCommand(cmd)
            logAction("KICK", player, reason or "No reason given")
            
        elseif choice == "3" then
            print("\nEnter player name to ban: ")
            local player = read()
            print("Enter reason (optional): ")
            local reason = read()
            
            local cmd = "ban " .. player
            if reason and reason ~= "" then
                cmd = cmd .. " " .. reason
            end
            
            if runCommand(cmd) then
                table.insert(banned_players, player)
                saveData()
            end
            logAction("BAN", player, reason or "No reason given")
            
        elseif choice == "4" then
            print("\nBanned Players:")
            for i, p in ipairs(banned_players) do
                print(i .. ". " .. p)
            end
            
            print("\nEnter player name to unban: ")
            local player = read()
            
            if runCommand("pardon " .. player) then
                for i, p in ipairs(banned_players) do
                    if p == player then
                        table.remove(banned_players, i)
                        break
                    end
                end
                saveData()
            end
            logAction("UNBAN", player, "")
            
        elseif choice == "5" then
            print("\nEnter player name to warn: ")
            local player = read()
            print("Enter warning reason: ")
            local reason = read()
            
            warnings[player] = (warnings[player] or 0) + 1
            saveData()
            
            runCommand("tell " .. player .. " [WARNING] " .. reason)
            print("Warning #" .. warnings[player] .. " given to " .. player)
            logAction("WARN", player, "Count: " .. warnings[player] .. " - " .. reason)
            
        elseif choice == "6" then
            print("\nEnter player name to teleport: ")
            local player = read()
            print("Enter destination (player or coordinates x y z): ")
            local dest = read()
            
            local cmd = "tp " .. player .. " " .. dest
            runCommand(cmd)
            logAction("TELEPORT", player, "to " .. dest)
            
        elseif choice == "7" then
            print("\nEnter player name: ")
            local player = read()
            print("Enter gamemode (0=survival, 1=creative, 2=adventure, 3=spectator): ")
            local mode = read()
            
            local cmd = "gamemode " .. mode .. " " .. player
            runCommand(cmd)
            logAction("GAMEMODE", player, "Mode: " .. mode)
            
        elseif choice == "8" then
            print("\nEnter player name to check: ")
            local player = read()
            
            -- This would require server-specific integration
            print("(Inventory check requires server mod/plugin)")
            
        elseif choice == "9" then
            print("\nEnter player name to clear inventory: ")
            local player = read()
            print("Clear entire inventory? (y/n): ")
            local confirm = read()
            
            if confirm:lower() == "y" then
                runCommand("clear " .. player)
                logAction("CLEAR_INV", player, "Full inventory")
            else
                print("Enter item ID to clear (or 'all'): ")
                local item = read()
                
                if item:lower() == "all" then
                    runCommand("clear " .. player)
                    logAction("CLEAR_INV", player, "All items")
                else
                    print("Enter amount (0 for all): ")
                    local amount = read()
                    
                    local cmd = "clear " .. player .. " " .. item
                    if amount ~= "0" then
                        cmd = cmd .. " " .. amount
                    end
                    
                    runCommand(cmd)
                    logAction("CLEAR_INV", player, "Item: " .. item .. " Amount: " .. amount)
                end
            end
        end
        
        print("\nPress any key to continue...")
        os.pullEvent("key")
    end
end

-- World Management
local function worldManagement()
    while true do
        term.clear()
        print("=== WORLD MANAGEMENT ===")
        print("[1] Set Time of Day")
        print("[2] Set Weather")
        print("[3] Change Difficulty")
        print("[4] Save World")
        print("[5] Toggle Day/Night Cycle")
        print("[6] Set Game Rule")
        print("[0] Return to Main Menu")
        
        print("\nSelect option: ")
        local choice = read()
        
        if choice == "0" then break end
        
        if choice == "1" then
            print("\nTime options:")
            print("0 = Dawn, 6000 = Noon, 12000 = Dusk, 18000 = Midnight")
            print("Or: day, night, noon, midnight")
            print("\nEnter time value: ")
            local time = read()
            
            local cmd = "time set " .. time
            runCommand(cmd)
            logAction("TIME_SET", "World", "Time: " .. time)
            
        elseif choice == "2" then
            print("\nWeather options: clear, rain, thunder")
            print("Enter weather: ")
            local weather = read()
            
            local cmd = "weather " .. weather
            runCommand(cmd)
            logAction("WEATHER", "World", "Set to: " .. weather)
            
        elseif choice == "3" then
            print("\nDifficulty levels: peaceful, easy, normal, hard")
            print("Enter difficulty: ")
            local diff = read()
            
            local cmd = "difficulty " .. diff
            runCommand(cmd)
            logAction("DIFFICULTY", "World", "Set to: " .. diff)
            
        elseif choice == "4" then
            print("\nSaving world...")
            runCommand("save-all")
            logAction("SAVE", "World", "Manual save")
            
        elseif choice == "5" then
            print("\nToggle day/night cycle:")
            print("[1] Enable cycle (default)")
            print("[2] Disable cycle (static time)")
            local opt = read()
            
            if opt == "1" then
                runCommand("gamerule doDaylightCycle true")
                logAction("GAMERULE", "World", "Daylight cycle: ON")
            elseif opt == "2" then
                runCommand("gamerule doDaylightCycle false")
                logAction("GAMERULE", "World", "Daylight cycle: OFF")
            end
            
        elseif choice == "6" then
            print("\nCommon Game Rules:")
            print("doFireTick, mobGriefing, keepInventory")
            print("doMobSpawning, doWeatherCycle")
            print("\nEnter rule name: ")
            local rule = read()
            print("Enter value (true/false): ")
            local value = read()
            
            local cmd = "gamerule " .. rule .. " " .. value
            runCommand(cmd)
            logAction("GAMERULE", "World", rule .. " = " .. value)
        end
        
        print("\nPress any key to continue...")
        os.pullEvent("key")
    end
end

-- Item/Entity Management
local function itemEntityManagement()
    while true do
        term.clear()
        print("=== ITEM/ENTITY MANAGEMENT ===")
        print("[1] Give Item to Player")
        print("[2] Remove Item from Player")
        print("[3] Spawn Entity")
        print("[4] Remove Entities")
        print("[5] Set Block")
        print("[6] Fill Area")
        print("[7] Clone Area")
        print("[0] Return to Main Menu")
        
        print("\nSelect option: ")
        local choice = read()
        
        if choice == "0" then break end
        
        if choice == "1" then
            print("\nEnter player name: ")
            local player = read()
            print("Enter item ID (e.g., diamond, minecraft:diamond): ")
            local item = read()
            print("Enter amount: ")
            local amount = read() or "1"
            print("Enter data value (optional): ")
            local data = read()
            
            local cmd = "give " .. player .. " " .. item .. " " .. amount
            if data and data ~= "" then
                cmd = cmd .. " " .. data
            end
            
            runCommand(cmd)
            logAction("GIVE_ITEM", player, item .. " x" .. amount)
            
        elseif choice == "2" then
            print("\nEnter player name: ")
            local player = read()
            print("Enter item ID to remove (or 'all'): ")
            local item = read()
            print("Enter amount (0 for all): ")
            local amount = read()
            
            if item:lower() == "all" then
                runCommand("clear " .. player)
                logAction("REMOVE_ITEMS", player, "All items")
            else
                local cmd = "clear " .. player .. " " .. item
                if amount ~= "0" then
                    cmd = cmd .. " " .. amount
                end
                runCommand(cmd)
                logAction("REMOVE_ITEMS", player, item .. " x" .. amount)
            end
            
        elseif choice == "3" then
            print("\nEnter entity type (e.g., cow, zombie, creeper): ")
            local entity = read()
            print("Enter coordinates (x y z) or 'here': ")
            local coords = read()
            
            local cmd = "summon " .. entity
            if coords:lower() ~= "here" then
                cmd = cmd .. " " .. coords
            end
            
            runCommand(cmd)
            logAction("SPAWN_ENTITY", entity, "at " .. coords)
            
        elseif choice == "4" then
            print("\nRemove Entities:")
            print("[1] Remove specific entity type")
            print("[2] Remove all entities in area")
            print("[3] Kill all mobs")
            local opt = read()
            
            if opt == "1" then
                print("Enter entity type (e.g., creeper, zombie): ")
                local entity = read()
                print("Enter radius (blocks): ")
                local radius = read()
                
                local cmd = "kill @e[type=" .. entity .. ",r=" .. radius .. "]"
                runCommand(cmd)
                logAction("REMOVE_ENTITIES", entity, "radius: " .. radius)
                
            elseif opt == "2" then
                print("Enter radius (blocks): ")
                local radius = read()
                
                local cmd = "kill @e[r=" .. radius .. "]"
                runCommand(cmd)
                logAction("REMOVE_ENTITIES", "ALL", "radius: " .. radius)
                
            elseif opt == "3" then
                runCommand("kill @e[type=!player]")
                logAction("KILL_MOBS", "World", "All hostile mobs")
            end
            
        elseif choice == "5" then
            print("\nEnter coordinates (x y z): ")
            local coords = read()
            print("Enter block ID (e.g., stone, diamond_block): ")
            local block = read()
            print("Enter data value (optional): ")
            local data = read()
            
            local cmd = "setblock " .. coords .. " " .. block
            if data and data ~= "" then
                cmd = cmd .. " " .. data
            end
            
            runCommand(cmd)
            logAction("SET_BLOCK", coords, block)
            
        elseif choice == "6" then
            print("\nEnter first corner (x1 y1 z1): ")
            local corner1 = read()
            print("Enter opposite corner (x2 y2 z2): ")
            local corner2 = read()
            print("Enter block ID: ")
            local block = read()
            print("Fill mode (hollow, outline, keep, destroy): ")
            local mode = read() or "replace"
            
            local cmd = "fill " .. corner1 .. " " .. corner2 .. " " .. block .. " " .. mode
            runCommand(cmd)
            logAction("FILL_AREA", corner1 .. " to " .. corner2, block)
            
        elseif choice == "7" then
            print("\nEnter source area (x1 y1 z1 x2 y2 z2): ")
            local source = read()
            print("Enter destination (x y z): ")
            local dest = read()
            print("Clone mode (normal, move, force): ")
            local mode = read() or "normal"
            
            local cmd = "clone " .. source .. " " .. dest .. " " .. mode
            runCommand(cmd)
            logAction("CLONE_AREA", source, "to " .. dest)
        end
        
        print("\nPress any key to continue...")
        os.pullEvent("key")
    end
end

-- View Logs
local function viewLogs()
    while true do
        term.clear()
        print("=== ADMINISTRATION LOGS ===")
        print("Last " .. #logs .. " actions:")
        print(string.rep("-", 60))
        
        for i = math.max(1, #logs - 20), #logs do
            print(logs[i])
        end
        
        print("\n[1] Clear Logs")
        print("[2] Export Logs to File")
        print("[0] Return to Main Menu")
        
        print("\nSelect option: ")
        local choice = read()
        
        if choice == "0" then
            break
        elseif choice == "1" then
            logs = {}
            print("\nLogs cleared!")
            os.sleep(1)
        elseif choice == "2" then
            local file = fs.open("admin_logs_export.txt", "w")
            for _, entry in ipairs(logs) do
                file.writeLine(entry)
            end
            file.close()
            print("\nLogs exported to admin_logs_export.txt")
            os.sleep(1)
        end
    end
end

-- Main Menu
local function mainMenu()
    loadData()
    
    while true do
        term.clear()
        local width, height = term.getSize()
        
        -- Draw header
        print(string.rep("=", width))
        print("        SERVER ADMINISTRATION TOOL")
        print(string.rep("=", width))
        
        -- Stats
        print("\nStats:")
        print("Banned Players: " .. #banned_players)
        print("Active Warnings: " .. (next(warnings) and "Yes" or "None"))
        print("Logged Actions: " .. #logs)
        
        -- Menu
        print("\n" .. string.rep("-", width))
        print("[1] Player Management")
        print("[2] World Management")
        print("[3] Item/Entity Management")
        print("[4] View Administration Logs")
        print("[5] Emergency Commands")
        print("[6] System Information")
        print("[0] Exit")
        print(string.rep("-", width))
        
        print("\nSelect option: ")
        local choice = read()
        
        if choice == "0" then
            saveData()
            print("\nGoodbye! Data saved.")
            break
        elseif choice == "1" then
            playerManagement()
        elseif choice == "2" then
            worldManagement()
        elseif choice == "3" then
            itemEntityManagement()
        elseif choice == "4" then
            viewLogs()
        elseif choice == "5" then
            -- Emergency commands
            term.clear()
            print("=== EMERGENCY COMMANDS ===")
            print("[1] Save and Stop Server")
            print("[2] Broadcast Message")
            print("[3] Op/Deop Player")
            print("[4] Set Default Gamemode")
            print("[5] Reload Server")
            
            print("\nSelect: ")
            local em = read()
            
            if em == "1" then
                print("WARNING: This will stop the server!")
                print("Type 'CONFIRM' to continue: ")
                local confirm = read()
                if confirm == "CONFIRM" then
                    runCommand("stop")
                end
            elseif em == "2" then
                print("Enter message to broadcast: ")
                local msg = read()
                runCommand("say [SERVER] " .. msg)
            elseif em == "3" then
                print("Enter player name: ")
                local player = read()
                print("Operation (op/deop): ")
                local op = read()
                runCommand(op .. " " .. player)
            elseif em == "4" then
                print("Enter default gamemode (0-3): ")
                local mode = read()
                runCommand("defaultgamemode " .. mode)
            elseif em == "5" then
                runCommand("reload")
            end
            
            print("\nPress any key to continue...")
            os.pullEvent("key")
            
        elseif choice == "6" then
            term.clear()
            print("=== SYSTEM INFORMATION ===")
            print("Computer ID: " .. os.getComputerID())
            print("Uptime: " .. math.floor(os.clock()) .. " seconds")
            print("Free Disk: " .. fs.getFreeSpace("/") .. " bytes")
            
            local peripherals = peripheral.getNames()
            print("Connected Peripherals: " .. #peripherals)
            
            print("\nPress any key to continue...")
            os.pullEvent("key")
        end
    end
end

-- Start the program
mainMenu()
