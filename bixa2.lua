-- vasya_bounce.lua
local mon = peripheral.find("monitor")
local w, h

if mon then
    mon.setTextScale(2)
    w, h = mon.getSize()
    mon.setBackgroundColor(colors.black)
    mon.clear()
else
    w, h = term.getSize()
    term.setBackgroundColor(colors.black)
    term.clear()
end

local text = "VASYA IS GAY"
local colors = {colors.red, colors.yellow, colors.green, colors.blue, colors.purple, colors.pink}

local x, y = 1, 1
local dx, dy = 1, 1
local colorIndex = 1

print("VASYA IS GAY - Bouncing!")
print("Press any key to stop")

while true do
    -- Clear old text
    if mon then
        mon.setCursorPos(x, y)
        mon.write("            ")
    else
        term.setCursorPos(x, y)
        write("            ")
    end
    
    -- Move
    x = x + dx
    y = y + dy
    
    -- Bounce off edges
    if x <= 1 then
        dx = 1
        colorIndex = colorIndex + 1
        if colorIndex > #colors then colorIndex = 1 end
    end
    
    if x + #text > w then
        dx = -1
        colorIndex = colorIndex + 1
        if colorIndex > #colors then colorIndex = 1 end
    end
    
    if y <= 1 then
        dy = 1
        colorIndex = colorIndex + 1
        if colorIndex > #colors then colorIndex = 1 end
    end
    
    if y > h then
        dy = -1
        colorIndex = colorIndex + 1
        if colorIndex > #colors then colorIndex = 1 end
    end
    
    -- Draw new text
    if mon then
        mon.setCursorPos(x, y)
        mon.setTextColor(colors[colorIndex])
        mon.write(text)
    else
        term.setCursorPos(x, y)
        term.setTextColor(colors[colorIndex])
        write(text)
    end
    
    -- Check for key press (exit)
    local event = os.pullEventRaw(0.1)
    if event == "key" then break end
end

-- Clean up
if mon then
    mon.clear()
    mon.setCursorPos(1, 1)
else
    term.clear()
    term.setCursorPos(1, 1)
end
print("Done!")
