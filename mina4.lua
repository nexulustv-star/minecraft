-- turtle_commander.lua
-- Main computer commands nearby turtles

print("=== TURTLE SWARM COMMANDER ===")

-- Find all turtles
local turtles = {}
for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "turtle" then
        table.insert(turtles, peripheral.wrap(name))
        print("Found turtle: " .. name)
    end
end

if #turtles == 0 then
    print("No turtles found!")
    print("Place turtles nearby and restart")
    return
end

-- Command all turtles
function commandAll(cmd, ...)
    print("Commanding all: " .. cmd)
    for i, turtle in ipairs(turtles) do
        local func = turtle[cmd]
        if func then
            func(...)
        end
    end
end

-- Setup mining operation
print("\n=== SETUP MINING OPERATION ===")
print("1. Place chest ABOVE this computer")
print("2. Each turtle mines 20x20 area")
print("3. Goes deeper every cycle")
print("4. Unloads to chest every 100 blocks")

print("\nReady? (y/n): ")
if read():lower() ~= "y" then return end

-- Send mining program to each turtle
local mining_code = [[
-- Worker turtle
local blocks_mined = 0
local depth_level = 0

function mineArea()
    -- Mine 20x20 area
    for x = 1, 20 do
        for z = 1, 20 do
            -- Mine forward
            if turtle.detect() then
                turtle.dig()
                blocks_mined = blocks_mined + 1
            end
            
            -- Move (except last in row)
            if z < 20 then
                while not turtle.forward() do
                    turtle.dig()
                end
            end
        end
        
        -- Turn around for next row
        if x < 20 then
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
        end
    end
    
    -- Return to start
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 19 do turtle.forward() end
    turtle.turnRight()
    turtle.turnRight()
end

function goDeeper()
    -- Go down 3 blocks
    for i = 1, 3 do
        while turtle.detectDown() do
            turtle.digDown()
        end
        turtle.down()
    end
    depth_level = depth_level + 1
end

function unloadToBase()
    -- Return to surface
    for i = 1, depth_level * 3 do
        turtle.up()
    end
    
    -- Unload all items up (to chest above master)
    for slot = 2, 16 do
        turtle.select(slot)
        turtle.dropUp()
    end
    
    -- Go back down
    for i = 1, depth_level * 3 do
        turtle.down()
    end
    
    blocks_mined = 0
    print("Unloaded at depth: " .. depth_level)
end

-- Main mining loop
while true do
    mineArea()
    
    -- Check if need to unload
    if blocks_mined >= 100 then
        unloadToBase()
    end
    
    -- Go deeper
    goDeeper()
    
    -- Wait for continue signal
    os.sleep(1)
end
]]

-- Save code to file and send to turtles
print("\nSending mining program to turtles...")
local file = fs.open("miner.lua", "w")
file.write(mining_code)
file.close()

-- Start all turtles
print("\nStarting all turtles...")
commandAll("turnRight")
os.sleep(1)
commandAll("turnLeft")

-- Monitor
print("\n=== MINING STARTED ===")
print(#turtles .. " turtles mining")
print("They will:")
print("- Mine 20x20 area each")
print("- Go deeper each cycle")
print("- Unload to chest above")
print("- Continue automatically")

print("\nPress Ctrl+T to exit monitor")
print("Turtles will continue mining")
