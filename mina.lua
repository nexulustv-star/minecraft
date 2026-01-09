-- safe_miner.lua
-- Safe turtle miner with lava detection

print("=== SAFE TURTLE MINER ===")

if not turtle then
    print("Run on turtle!")
    return
end

-- Dangerous blocks to avoid
local dangerous = {
    "minecraft:lava",
    "minecraft:flowing_lava",
    "minecraft:fire",
    "minecraft:magma_block",
    "minecraft:bedrock"
}

-- Check if block is dangerous
local function isDangerous()
    local success, data = turtle.inspect()
    if success then
        for _, danger in ipairs(dangerous) do
            if data.name == danger then
                return true
            end
        end
    end
    return false
end

-- Safe mining function
local function safeMine()
    local mined = 0
    
    print("Safe mining started")
    print("Will avoid lava and bedrock")
    
    while true do
        -- Check fuel
        if turtle.getFuelLevel() < 50 then
            turtle.select(1)
            if not turtle.refuel(1) then
                print("Need fuel in slot 1!")
                break
            end
        end
        
        -- Check forward
        if turtle.detect() then
            if isDangerous() then
                print("Danger ahead! Turning...")
                turtle.turnLeft()
            else
                turtle.dig()
                mined = mined + 1
            end
        end
        
        -- Try to move forward
        if turtle.forward() then
            -- Check above and below
            if turtle.detectUp() and not isDangerous() then
                turtle.digUp()
            end
            if turtle.detectDown() and not isDangerous() then
                turtle.digDown()
            end
        else
            -- Try different direction
            turtle.turnLeft()
        end
        
        -- Check inventory
        local slotsUsed = 0
        for i = 1, 16 do
            if turtle.getItemCount(i) > 0 then
                slotsUsed = slotsUsed + 1
            end
        end
        
        if slotsUsed >= 15 then
            print("Inventory almost full")
            break
        end
        
        -- Status update
        if mined % 10 == 0 then
            print("Mined: " .. mined .. " blocks")
        end
        
        os.sleep(0.2)
    end
    
    print("Mining stopped")
    print("Total mined: " .. mined .. " blocks")
end

-- Main
print("\nOptions:")
print("[1] Start safe mining")
print("[2] Check fuel: " .. turtle.getFuelLevel())
print("[3] Show inventory")
print("[0] Exit")

local choice = read()
if choice == "1" then
    safeMine()
elseif choice == "2" then
    print("Fuel: " .. turtle.getFuelLevel())
elseif choice == "3" then
    print("Inventory:")
    for i = 1, 16 do
        local count = turtle.getItemCount(i)
        if count > 0 then
            local item = turtle.getItemDetail(i)
            print("Slot " .. i .. ": " .. (item and item.name or "Unknown") .. " x" .. count)
        end
    end
end
