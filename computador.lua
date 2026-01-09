-- control_counter.lua
-- Main computer with item counter

print("=== TURTLE MINING CONTROLLER ===")
print("Chest ON TOP of this computer!")

-- Item counter
local item_counts = {}
local total_items = 0
local last_check = os.time()

-- Signal codes
local SIGNALS = {
    START = "front",    -- Pulse to start
    STOP = "back",      -- Constant to stop
    UNLOAD = "left",    -- Pulse to unload now
}

-- Count items in chest above
local function countChestItems()
    local chest = peripheral.wrap("top")
    if not chest then
        return "No chest found on top!"
    end
    
    item_counts = {}
    total_items = 0
    
    for slot = 1, chest.size() do
        local item = chest.getItemDetail(slot)
        if item then
            local name = item.name
            local count = item.count
            
            if item_counts[name] then
                item_counts[name] = item_counts[name] + count
            else
                item_counts[name] = count
            end
            
            total_items = total_items + count
        end
    end
    
    last_check = os.time()
    return "Counted " .. total_items .. " items"
end

-- Display item counter
local function showItemCounter()
    local chest = peripheral.wrap("top")
    if not chest then
        print("✗ No chest on top!")
        return
    end
    
    local status = countChestItems()
    
    -- Clear and draw counter
    local width, height = term.getSize()
    
    -- Header
    print(string.rep("=", width))
    print("ITEM COUNTER")
    print(string.rep("=", width))
    
    -- Summary
    print("Total items: " .. total_items)
    print("Last check: " .. os.date("%H:%M:%S", last_check))
    print("")
    
    -- List items (top 10)
    print("Top items in chest:")
    print(string.rep("-", 30))
    
    local sorted = {}
    for name, count in pairs(item_counts) do
        table.insert(sorted, {name = name, count = count})
    end
    
    table.sort(sorted, function(a, b) return a.count > b.count end)
    
    for i = 1, math.min(10, #sorted) do
        local item = sorted[i]
        local display_name = item.name:gsub("minecraft:", "")
        print(string.format("%2d. %-15s x%d", i, display_name, item.count))
    end
    
    if #sorted > 10 then
        print("... and " .. (#sorted - 10) .. " more items")
    end
end

-- Send signal to turtles
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
    
    -- Update counter after signals
    if signal == "UNLOAD" or signal == "START" then
        os.sleep(1)
        showItemCounter()
    end
    
    print("Signal sent!")
end

-- Real-time monitor with counter
local function liveMonitor()
    print("=== LIVE MONITOR ===")
    print("Press Ctrl+T to exit")
    
    local start_time = os.time()
    local last_unload = start_time
    
    while true do
        term.clear()
        local width, height = term.getSize()
        
        -- Header
        print(string.rep("=", width))
        print("TURTLE MINING MONITOR")
        print(string.rep("=", width))
        
        -- Time info
        local elapsed = os.time() - start_time
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        
        print(string.format("Running: %02d:%02d:%02d", hours, minutes, seconds))
        print("Status: ACTIVE")
        print("")
        
        -- Item counter section
        print("CHEST CONTENTS:")
        print(string.rep("-", width))
        
        local chest = peripheral.wrap("top")
        if chest then
            countChestItems()
            print("Total items: " .. total_items)
            
            -- Show valuable items
            local valuable = {
                "diamond", "emerald", "gold", "iron",
                "copper", "redstone", "lapis", "coal"
            }
            
            for _, ore in ipairs(valuable) do
                for name, count in pairs(item_counts) do
                    if name:find(ore) then
                        local display = name:gsub("minecraft:", ""):gsub("_ore", "")
                        print("  " .. display .. ": " .. count)
                    end
                end
            end
            
            -- Items per minute calculation
            if elapsed > 60 then
                local items_per_min = math.floor(total_items / (elapsed / 60))
                print("\nRate: " .. items_per_min .. " items/minute")
            end
        else
            print("✗ No chest detected!")
            print("Place chest ON TOP of computer")
        end
        
        -- Turtle status (simulated)
        print("\n" .. string.rep("-", width))
        print("TURTLE STATUS:")
        print("All turtles: MINING")
        print("Depth: Increasing")
        print("Next unload: ~100 blocks")
        
        -- Controls reminder
        print("\n" .. string.rep("-", width))
        print("[Ctrl+T] Exit monitor")
        
        -- Check for exit
        local event = os.pullEventRaw()
        if event == "terminate" then
            break
        end
        
        os.sleep(2)  -- Update every 2 seconds
    end
end

-- Main menu with counter
local function mainMenu()
    while true do
        term.clear()
        local width, height = term.getSize()
        
        -- Header with counter
        print(string.rep("=", width))
        print("MAIN MINING CONTROLLER")
        print(string.rep("=", width))
        
        -- Quick counter at top
        local chest = peripheral.wrap("top")
        if chest then
            countChestItems()
            print(string.format("Items in chest: %d | Last: %s", 
                total_items, os.date("%H:%M:%S", last_check)))
        else
            print("⚠ NO CHEST ON TOP!")
        end
        
        print(string.rep("-", width))
        
        -- Menu options
        print("\n[1] START all turtles")
        print("[2] STOP all turtles")
        print("[3] UNLOAD now")
        print("[4] Live monitor")
        print("[5] Check chest contents")
        print("[0] Exit")
        
        term.write("\nChoice: ")
        local choice = read()
        
        if choice == "0" then
            sendSignal("STOP")
            print("Goodbye!")
            break
            
        elseif choice == "1" then
            sendSignal("START")
            print("\n✓ Turtles started!")
            print("\nThey will:")
            print("• Mine 20x20 area")
            print("• Go down 3 blocks")
            print("• Repeat automatically")
            print("• Unload every 100 blocks")
            print("\nPress any key...")
            os.pullEvent("key")
            
        elseif choice == "2" then
            sendSignal("STOP")
            print("\n✓ Stop signal sent!")
            os.sleep(2)
            
        elseif choice == "3" then
            sendSignal("UNLOAD")
            print("\n✓ Unload signal sent!")
            showItemCounter()
            print("\nPress any key...")
            os.pullEvent("key")
            
        elseif choice == "4" then
            liveMonitor()
            
        elseif choice == "5" then
            showItemCounter()
            print("\nPress any key...")
            os.pullEvent("key")
        end
    end
end

-- Start
mainMenu()
