-- mega_computer.lua
-- All-in-one ComputerCraft utility suite

local term = require("term")
local gpu = term.gpu
local shell = shell or {}

-- Configuration
local DEEPSEEK_API_KEY = nil  -- Set your API key here
local API_URL = "https://api.deepseek.com/v1/chat/completions"

-- Main menu
local function drawMainMenu()
    term.clear()
    local width, height = term.getSize()
    
    -- Draw header
    print(string.rep("=", width))
    print("MEGA COMPUTER UTILITY SUITE")
    print(string.rep("=", width))
    print("")
    
    -- Menu options
    local menuItems = {
        "[1] System Information",
        "[2] File Manager",
        "[3] Redstone Controller",
        "[4] Turtle Commander",
        "[5] DeepSeek AI Chat",
        "[6] Local Chatbot",
        "[7] Disk Cleaner",
        "[8] Network Scanner",
        "[9] Program Launcher",
        "[0] Settings & About",
        "[Q] Quit"
    }
    
    for _, item in ipairs(menuItems) do
        print("  " .. item)
    end
    
    print("\n" .. string.rep("=", width))
    print("Select an option (1-9, 0, or Q):")
end

-- 1. System Information
local function systemInfo()
    term.clear()
    print("=== SYSTEM INFORMATION ===")
    print("Computer ID: " .. os.getComputerID())
    print("Label: " .. (os.getComputerLabel() or "Unlabeled"))
    
    -- Disk space
    local free = 0
    for _, path in pairs(fs.getDirectory("/")) do
        if not fs.isReadOnly(path) then
            free = free + fs.getFreeSpace(path)
        end
    end
    print(string.format("Free Disk: %.2f MB", free / (1024 * 1024)))
    
    -- Uptime
    local uptime = os.clock()
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    print(string.format("Uptime: %02d:%02d:%02d", hours, minutes, seconds))
    
    -- Peripherals
    local peripherals = peripheral.getNames()
    print("\nConnected Peripherals (" .. #peripherals .. "):")
    for i, name in ipairs(peripherals) do
        local type = peripheral.getType(name)
        print(string.format("  %d. %s (%s)", i, name, type))
    end
    
    print("\nPress any key to return...")
    os.pullEvent("key")
end

-- 2. File Manager
local function fileManager()
    local currentDir = "/"
    local selected = 1
    local files = {}
    
    local function refreshFiles()
        files = {}
        for _, file in pairs(fs.list(currentDir)) do
            table.insert(files, file)
        end
        table.sort(files)
    end
    
    local function displayFiles()
        term.clear()
        print("FILE MANAGER - " .. currentDir)
        print(string.rep("-", 50))
        
        if currentDir ~= "/" then
            print("[..] Parent Directory")
        end
        
        for i, file in ipairs(files) do
            local prefix = " "
            if i == selected then
                prefix = ">"
            end
            
            local path = fs.combine(currentDir, file)
            local isDir = fs.isDir(path)
            local size = isDir and "[DIR]" or string.format("%d B", fs.getSize(path))
            
            print(string.format("%s %-30s %10s", prefix, file, size))
        end
        
        print("\nControls: ↑/↓ Navigate | Enter Open | D Delete | R Rename")
        print("          N New File | M New Dir | B Back | Q Quit")
    end
    
    while true do
        refreshFiles()
        displayFiles()
        
        local event, key = os.pullEvent()
        
        if event == "key" then
            if key == keys.up then
                selected = math.max(1, selected - 1)
            elseif key == keys.down then
                selected = math.min(#files, selected + 1)
            elseif key == keys.enter then
                local path = fs.combine(currentDir, files[selected])
                if fs.isDir(path) then
                    currentDir = path
                    selected = 1
                else
                    -- View file
                    term.clear()
                    local file = fs.open(path, "r")
                    if file then
                        print("Contents of " .. files[selected] .. ":")
                        print(string.rep("-", 50))
                        print(file.readAll())
                        file.close()
                        print("\nPress any key to continue...")
                        os.pullEvent("key")
                    end
                end
            elseif key == keys.b then
                if currentDir ~= "/" then
                    currentDir = fs.getDir(currentDir)
                    selected = 1
                end
            elseif key == keys.q then
                break
            elseif key == keys.d then
                -- Delete
                local path = fs.combine(currentDir, files[selected])
                print("\nDelete '" .. files[selected] .. "'? (y/n): ")
                local answer = read()
                if answer:lower() == "y" then
                    fs.delete(path)
                end
            elseif key == keys.n then
                -- New file
                print("\nEnter filename: ")
                local filename = read()
                local path = fs.combine(currentDir, filename)
                local file = fs.open(path, "w")
                if file then
                    file.write("")
                    file.close()
                end
            elseif key == keys.m then
                -- New directory
                print("\nEnter directory name: ")
                local dirname = read()
                local path = fs.combine(currentDir, dirname)
                fs.makeDir(path)
            end
        end
    end
end

-- 3. Redstone Controller
local function redstoneControl()
    local sides = {"bottom", "top", "back", "front", "right", "left"}
    local selected = 1
    
    local function displayControls()
        term.clear()
        print("=== REDSTONE CONTROLLER ===")
        print(string.rep("-", 40))
        
        for i, side in ipairs(sides) do
            local prefix = " "
            if i == selected then
                prefix = ">"
            end
            
            local input = redstone.getInput(side)
            local output = redstone.getOutput(side)
            local analog = redstone.getAnalogInput(side)
            
            print(string.format("%s %-8s In: %-5s Out: %-5s Analog: %d",
                prefix, side:upper(), tostring(input), 
                tostring(output), analog))
        end
        
        print("\nControls: ↑/↓ Select | T Toggle | A Analog | P Pulse")
        print("          S Set All | C Clear All | Q Quit")
    end
    
    while true do
        displayControls()
        
        local event, key = os.pullEvent()
        
        if event == "key" then
            if key == keys.up then
                selected = math.max(1, selected - 1)
            elseif key == keys.down then
                selected = math.min(#sides, selected + 1)
            elseif key == keys.t then
                -- Toggle output
                local side = sides[selected]
                local current = redstone.getOutput(side)
                redstone.setOutput(side, not current)
            elseif key == keys.a then
                -- Set analog value
                local side = sides[selected]
                print("\nEnter analog value (0-15): ")
                local value = tonumber(read())
                if value and value >= 0 and value <= 15 then
                    redstone.setAnalogOutput(side, value)
                end
            elseif key == keys.p then
                -- Pulse
                local side = sides[selected]
                print("\nEnter pulse duration (seconds): ")
                local duration = tonumber(read())
                if duration then
                    redstone.setOutput(side, true)
                    os.sleep(duration)
                    redstone.setOutput(side, false)
                end
            elseif key == keys.s then
                -- Set all
                redstone.setOutput("all", true)
            elseif key == keys.c then
                -- Clear all
                redstone.setOutput("all", false)
            elseif key == keys.q then
                break
            end
        end
    end
end

-- 4. Turtle Commander (simplified)
local function turtleCommander()
    local turtles = {}
    local peripherals = peripheral.getNames()
    
    for _, name in ipairs(peripherals) do
        if peripheral.getType(name) == "turtle" then
            table.insert(turtles, name)
        end
    end
    
    if #turtles == 0 then
        print("No turtles found!")
        print("Press any key to return...")
        os.pullEvent("key")
        return
    end
    
    local selected = 1
    
    while true do
        term.clear()
        print("=== TURTLE COMMANDER ===")
        print("Connected Turtles:")
        
        for i, name in ipairs(turtles) do
            local prefix = " "
            if i == selected then
                prefix = ">"
            end
            
            local turtle = peripheral.wrap(name)
            local fuel = turtle.getFuelLevel()
            local label = turtle.getLabel() or "Unnamed"
            
            print(string.format("%s %d. %s (Fuel: %d, Label: %s)",
                prefix, i, name, fuel, label))
        end
        
        print("\nCommands: F Forward | B Back | L Turn Left | R Turn Right")
        print("          U Up | D Down | G Dig | I Inspect | Q Quit")
        print("\nSelect command: ")
        
        local command = read():lower()
        
        if command == "q" then
            break
        end
        
        local turtle = peripheral.wrap(turtles[selected])
        local success, result
        
        if command == "f" then
            success, result = turtle.forward()
        elseif command == "b" then
            success, result = turtle.back()
        elseif command == "l" then
            success, result = turtle.turnLeft()
        elseif command == "r" then
            success, result = turtle.turnRight()
        elseif command == "u" then
            success, result = turtle.up()
        elseif command == "d" then
            success, result = turtle.down()
        elseif command == "g" then
            success, result = turtle.dig()
        elseif command == "i" then
            success, result = turtle.inspect()
        else
            print("Unknown command!")
            os.sleep(1)
            goto continue
        end
        
        if success then
            print("Success! Result: " .. tostring(result))
        else
            print("Failed: " .. tostring(result))
        end
        
        os.sleep(1)
        ::continue::
    end
end

-- 5. DeepSeek AI Chat (requires HTTP)
local function deepSeekChat()
    if not DEEPSEEK_API_KEY or DEEPSEEK_API_KEY == "" then
        print("DeepSeek API key not configured!")
        print("Edit the script and set DEEPSEEK_API_KEY")
        print("Press any key to return...")
        os.pullEvent("key")
        return
    end
    
    if not http then
        print("HTTP API not available!")
        print("Enable it in ComputerCraft config")
        print("Press any key to return...")
        os.pullEvent("key")
        return
    end
    
    term.clear()
    print("=== DEEPSEEK AI CHAT ===")
    print("Type 'exit' to quit")
    print(string.rep("-", 50))
    
    local history = {}
    
    while true do
        term.write("\nYou: ")
        local question = read()
        
        if question:lower() == "exit" then
            break
        end
        
        -- Prepare request
        table.insert(history, {role = "user", content = question})
        
        local requestData = {
            model = "deepseek-chat",
            messages = history,
            max_tokens = 500
        }
        
        local json = require("json")
        local jsonData = json.encode(requestData)
        
        print("Thinking...")
        
        -- Make request
        local response = http.post(
            API_URL,
            jsonData,
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. DEEPSEEK_API_KEY
            }
        )
        
        if response and response.getResponseCode() == 200 then
            local responseText = response.readAll()
            local responseData = json.decode(responseText)
            
            if responseData.choices and responseData.choices[1] then
                local answer = responseData.choices[1].message.content
                print("\nDeepSeek: " .. answer)
                table.insert(history, {role = "assistant", content = answer})
            else
                print("Error: Invalid response format")
            end
        else
            print("Error connecting to DeepSeek API")
        end
    end
end

-- 6. Local Chatbot
local function localChatbot()
    local responses = {
        ["hello"] = "Hello! I'm your local ComputerCraft assistant!",
        ["how are you"] = "Running on redstone power, feeling electric!",
        ["help"] = "I can help with ComputerCraft questions, Lua programming, and Minecraft automation!",
        ["time"] = "Computer time: " .. os.time(),
        ["what can you do"] = "I'm part of the Mega Computer Suite. Try the other tools too!"
    }
    
    term.clear()
    print("=== LOCAL CHATBOT ===")
    print("Type 'exit' to quit")
    print(string.rep("-", 50))
    
    while true do
        term.write("\nYou: ")
        local input = read():lower()
        
        if input == "exit" then
            break
        end
        
        local response = responses[input] or 
            "I'm a simple bot. Try 'hello', 'help', or use the DeepSeek AI for better answers!"
        
        print("Bot: " .. response)
    end
end

-- 7. Disk Cleaner
local function diskCleaner()
    term.clear()
    print("=== DISK CLEANER ===")
    
    -- Scan for files
    local tempFiles = {}
    
    local function scanDir(path)
        for _, file in pairs(fs.list(path)) do
            local fullPath = fs.combine(path, file)
            
            if fs.isDir(fullPath) then
                scanDir(fullPath)
            else
                -- Look for temp/log files
                if file:find("%.tmp$") or file:find("%.log$") or 
                   file:find("%.bak$") or file:find("%.old$") then
                    table.insert(tempFiles, {
                        path = fullPath,
                        size = fs.getSize(fullPath)
                    })
                end
            end
        end
    end
    
    scanDir("/")
    
    if #tempFiles == 0 then
        print("No temporary files found!")
        print("Press any key to return...")
        os.pullEvent("key")
        return
    end
    
    -- Display files
    print(string.format("Found %d temporary files:", #tempFiles))
    print(string.rep("-", 60))
    
    local totalSize = 0
    for i, file in ipairs(tempFiles) do
        if i <= 15 then  -- Show first 15
            print(string.format("%3d. %-40s %10d B",
                i, file.path, file.size))
        end
        totalSize = totalSize + file.size
    end
    
    if #tempFiles > 15 then
        print("... and " .. (#tempFiles - 15) .. " more files")
    end
    
    print(string.rep("-", 60))
    print(string.format("Total size: %.2f KB", totalSize / 1024))
    
    print("\nDelete all? (y/n): ")
    local answer = read()
    
    if answer:lower() == "y" then
        local deleted = 0
        for _, file in ipairs(tempFiles) do
            if fs.delete(file.path) then
                deleted = deleted + 1
            end
        end
        print(string.format("Deleted %d/%d files", deleted, #tempFiles))
    else
        print("Cleanup cancelled.")
    end
    
    print("\nPress any key to return...")
    os.pullEvent("key")
end

-- 8. Network Scanner
local function networkScanner()
    local modem = peripheral.find("modem")
    
    if not modem then
        print("No modem found!")
        print("Press any key to return...")
        os.pullEvent("key")
        return
    end
    
    term.clear()
    print("=== NETWORK SCANNER ===")
    print("Scanning for nearby computers...")
    
    -- Simple ping
    modem.open(1)
    modem.transmit(1, 1, {type = "ping", id = os.getComputerID()})
    
    local computers = {}
    local startTime = os.clock()
    
    while os.clock() - startTime < 2 do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        
        if message and message.type == "pong" then
            computers[message.id] = message.label or "Unknown"
        end
    end
    
    modem.close(1)
    
    term.clear()
    print("=== NETWORK SCANNER ===")
    
    if next(computers) == nil then
        print("No other computers found on the network.")
    else
        print("Found computers:")
        print(string.rep("-", 40))
        
        local i = 1
        for id, label in pairs(computers) do
            print(string.format("%2d. ID: %d | Label: %s", i, id, label))
            i = i + 1
        end
    end
    
    print("\nPress any key to return...")
    os.pullEvent("key")
end

-- 9. Program Launcher
local function programLauncher()
    local programs = {}
    
    -- Find all .lua files
    for _, file in pairs(fs.list("/")) do
        if not fs.isDir(file) and file:sub(-4) == ".lua" then
            table.insert(programs, file)
        end
    end
    
    table.sort(programs)
    
    local selected = 1
    
    while true do
        term.clear()
        print("=== PROGRAM LAUNCHER ===")
        print("Available Programs:")
        print(string.rep("-", 50))
        
        for i, program in ipairs(programs) do
            local prefix = " "
            if i == selected then
                prefix = ">"
            end
            print(string.format("%s %2d. %s", prefix, i, program))
        end
        
        print("\nControls: ↑/↓ Select | Enter Run | R Refresh | Q Quit")
        
        local event, key = os.pullEvent()
        
        if event == "key" then
            if key == keys.up then
                selected = math.max(1, selected - 1)
            elseif key == keys.down then
                selected = math.min(#programs, selected + 1)
            elseif key == keys.enter then
                local program = programs[selected]
                term.clear()
                print("Running: " .. program)
                shell.run(program)
                print("\nPress any key to return to launcher...")
                os.pullEvent("key")
            elseif key == keys.r then
                -- Refresh list
                programs = {}
                for _, file in pairs(fs.list("/")) do
                    if not fs.isDir(file) and file:sub(-4) == ".lua" then
                        table.insert(programs, file)
                    end
                end
                table.sort(programs)
            elseif key == keys.q then
                break
            end
        end
    end
end

-- 0. Settings & About
local function settings()
    while true do
        term.clear()
        print("=== SETTINGS & ABOUT ===")
        print("Mega Computer Utility Suite")
        print("Version 1.0")
        print(string.rep("-", 50))
        
        print("\n[1] Set Computer Label")
        print("[2] View Configuration")
        print("[3] About")
        print("[4] Return to Main Menu")
        
        print("\nSelect option: ")
        local choice = read()
        
        if choice == "1" then
            print("\nCurrent label: " .. (os.getComputerLabel() or "None"))
            print("Enter new label (or 'none' to remove): ")
            local newLabel = read()
            if newLabel:lower() == "none" then
                os.setComputerLabel(nil)
                print("Label removed.")
            else
                os.setComputerLabel(newLabel)
                print("Label set to: " .. newLabel)
            end
            os.sleep(1)
        elseif choice == "2" then
            print("\n=== CONFIGURATION ===")
            print("Computer ID: " .. os.getComputerID())
            print("Color Support: " .. tostring(term.isColor()))
            print("HTTP Available: " .. tostring(not not http))
            print("DeepSeek API Key: " .. (DEEPSEEK_API_KEY and "Set" or "Not Set"))
            print("\nPress any key to continue...")
            os.pullEvent("key")
        elseif choice == "3" then
            print("\n=== ABOUT ===")
            print("Mega Computer Suite")
            print("All-in-one utility for CC:Tweaked")
            print("Includes 9 different tools:")
            print("  • System Info")
            print("  • File Manager")
            print("  • Redstone Control")
            print("  • Turtle Commander")
            print("  • AI Chat")
            print("  • Local Chatbot")
            print("  • Disk Cleaner")
            print("  • Network Scanner")
            print("  • Program Launcher")
            print("\nPress any key to continue...")
            os.pullEvent("key")
        elseif choice == "4" then
            break
        end
    end
end

-- Main loop
function main()
    while true do
        drawMainMenu()
        local choice = read():lower()
        
        if choice == "1" then
            systemInfo()
        elseif choice == "2" then
            fileManager()
        elseif choice == "3" then
            redstoneControl()
        elseif choice == "4" then
            turtleCommander()
        elseif choice == "5" then
            deepSeekChat()
        elseif choice == "6" then
            localChatbot()
        elseif choice == "7" then
            diskCleaner()
        elseif choice == "8" then
            networkScanner()
        elseif choice == "9" then
            programLauncher()
        elseif choice == "0" then
            settings()
        elseif choice == "q" then
            term.clear()
            term.setCursorPos(1, 1)
            print("Goodbye!")
            break
        else
            print("Invalid choice! Press any key...")
            os.pullEvent("key")
        end
    end
end

-- Run the program
main()
