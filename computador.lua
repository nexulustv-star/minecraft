-- control.lua
-- Main computer controller - place on MAIN computer

print("=== TURTLE MINING CONTROLLER ===")
print("Place chest ON TOP of this computer!")

-- Signal codes
local SIGNALS = {
    START = "front",    -- Pulse to start
    STOP = "back",      -- Constant to stop
    UNLOAD = "left",    -- Pulse to unload now
}

-- Send signal to all turtles
local function sendSignal(signal)
    print("Sending " .. signal .. " signal...")
    
    if signal == "START" then
        redstone.setOutput(SIGNALS.START, true)
        os.sleep(0.5)
        redstone.setOutput(SIGNALS.START, false)
        
    elseif signal == "STOP" then
        redstone.setOutput(SIGNALS.STOP, true)
        os.sleep(2)
        redstone.setOutput(SIGNALS.STOP, false)
        
    elseif signal == "UNLOAD" then
        for i = 1, 3 do
            redstone.setOutput(SIGNALS.UNLOAD, true)
            os.sleep(0.2)
            redstone.setOutput(SIGNALS.UNLOAD, false)
            os.sleep(0.2)
        end
    end
    
    print("Signal sent!")
end

-- Main menu
while true do
    term.clear()
    print("=== MAIN CONTROLLER ===")
    print("Chest must be ON TOP of computer")
    print("\n[1] START all turtles")
    print("[2] STOP all turtles")
    print("[3] UNLOAD now")
    print("[0] Exit")
    
    term.write("\nChoice: ")
    local choice = read()
    
    if choice == "0" then
        sendSignal("STOP")
        print("Goodbye!")
        break
        
    elseif choice == "1" then
        sendSignal("START")
        print("\nTurtles will:")
        print("1. Mine 20x20 area")
        print("2. Go down 3 blocks")
        print("3. Repeat")
        print("4. Unload every 100 blocks")
        print("\nPress any key...")
        os.pullEvent("key")
        
    elseif choice == "2" then
        sendSignal("STOP")
        print("\nStop signal sent!")
        os.sleep(2)
        
    elseif choice == "3" then
        sendSignal("UNLOAD")
        print("\nUnload signal sent!")
        os.sleep(2)
    end
end
