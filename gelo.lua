-- simple_freeze.lua
-- Super simple freeze script

print("=== SIMPLE FREEZE ===")

-- Just generate the commands for you to copy
local function generateFreezeCommands(player)
    term.clear()
    print("=== FREEZE COMMANDS ===")
    print("\nCopy these commands to chat (as OP):")
    print("\n--- FREEZE " .. player .. " ---")
    print("/effect give " .. player .. " minecraft:slowness 30 255")
    print("/effect give " .. player .. " minecraft:mining_fatigue 30 255")
    print("/effect give " .. player .. " minecraft:jump_boost 30 128")
    print("/tell " .. player .. " You are frozen for 30 seconds!")
    print("/say " .. player .. " has been frozen!")
    
    print("\n--- AFTER 30 SECONDS ---")
    print("/effect clear " .. player .. " minecraft:slowness")
    print("/effect clear " .. player .. " minecraft:mining_fatigue")
    print("/effect clear " .. player .. " minecraft:jump_boost")
    print("/tell " .. player .. " You are now unfrozen!")
    print("/say " .. player .. " has been unfrozen!")
    
    print("\nPress any key...")
    os.pullEvent("key")
end

-- Main loop
while true do
    term.clear()
    print("=== PLAYER FREEZER ===")
    print("\nEnter player name to freeze:")
    print("(or 'exit' to quit)")
    
    term.write("> ")
    local player = read()
    
    if player:lower() == "exit" then
        print("Goodbye!")
        break
    elseif player ~= "" then
        generateFreezeCommands(player)
    end
end
