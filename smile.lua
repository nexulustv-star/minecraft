-- startup.lua - Runs when turtle boots
print("=== Standalone Turtle Booting ===")
print("ID: " .. os.getComputerID())
print("Time: " .. os.date())
print("")

-- Set label if not set
if not os.getComputerLabel() then
    os.setComputerLabel("AutoTurtle-" .. os.getComputerID())
end

-- Check fuel
local fuel = turtle.getFuelLevel()
print("Fuel: " .. fuel)
if fuel < 500 then
    print("⚠ Warning: Low fuel!")
    print("Place fuel in inventory and run: turtle.refuel()")
end

-- Check for updates every 24 hours
local lastUpdateFile = "data/last_update.txt"
local updateInterval = 86400  -- 24 hours in seconds

if fs.exists(lastUpdateFile) then
    local file = fs.open(lastUpdateFile, "r")
    local lastUpdate = tonumber(file.readLine()) or 0
    file.close()
    
    local currentTime = os.time()
    if currentTime - lastUpdate > updateInterval then
        print("Checking for GitHub updates...")
        shell.run("github_manager.lua", "1")
        
        -- Update timestamp
        local file = fs.open(lastUpdateFile, "w")
        file.writeLine(tostring(currentTime))
        file.close()
    end
else
    -- First time setup
    print("First boot - downloading scripts...")
    shell.run("github_manager.lua", "1")
    
    local file = fs.open(lastUpdateFile, "w")
    file.writeLine(tostring(os.time()))
    file.close()
end

-- Main menu
sleep(2)
term.clear()
term.setCursorPos(1, 1)

print("=== Standalone Turtle Control ===")
print("1. Start Player Follower")
print("2. Start Patrol Mode")
print("3. Check GitHub Updates")
print("4. Fuel Status")
print("5. Run Mining Program")
print("6. Shutdown")
print("")

while true do
    write("Choice: ")
    local choice = read()
    
    if choice == "1" then
        shell.run("scripts/player_follower.lua")
    elseif choice == "2" then
        shell.run("scripts/patrol_follower.lua")
    elseif choice == "3" then
        shell.run("github_manager.lua", "1")
    elseif choice == "4" then
        print("Fuel: " .. turtle.getFuelLevel())
        print("Max: " .. turtle.getFuelLimit())
    elseif choice == "5" then
        shell.run("scripts/miner.lua")
    elseif choice == "6" then
        print("Shutting down...")
        os.sleep(2)
        os.shutdown()
    end
    
    print("")
end
