-- vasya_rainbow.lua
local screen = peripheral.find("monitor") or term
screen.clear()

if peripheral.getType(screen) == "monitor" then
    screen.setTextScale(1.0)  -- Normal text size
end

local texts = {
    "VASYA IS GAY",
    "VASYA = GAY", 
    "GAY VASYA",
    "VASYA GAY"
}

local colors = {
    colors.red,
    colors.yellow,
    colors.green,
    colors.blue,
    colors.purple,
    colors.cyan,
    colors.orange,
    colors.pink
}

local msgIndex = 1

while true do
    screen.clear()
    screen.setBackgroundColor(colors.black)
    
    local text = texts[msgIndex]
    local x = 5  -- Fixed position
    local y = 5
    
    -- Draw each character with random color
    for i = 1, #text do
        local char = text:sub(i, i)
        local col = colors[math.random(#colors)]
        
        screen.setCursorPos(x + i - 1, y)
        screen.setTextColor(col)
        screen.write(char)
    end
    
    sleep(2.5)
    
    msgIndex = msgIndex + 1
    if msgIndex > #texts then msgIndex = 1 end
end
