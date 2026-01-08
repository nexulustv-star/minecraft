-- colorful_display.lua
local s = peripheral.find("monitor") or term
s.clear()

-- Brazil time
local brHour = 14
local brMin = 49
local brSec = 0

-- Vladivostok time (fixed to 04:49)
local vladHour = 4
local vladMin = 49
local vladSec = 0
local vladDay = 10  -- Next day

print("Starting colorful display...")
print("Brazil: 14:49, Vladivostok: 04:49 (next day)")

-- Color scheme
local colors = {
    title = colors.cyan,
    city = colors.yellow,
    time = colors.green,
    date = colors.white,
    weather = colors.orange,
    temp = colors.red,
    details = colors.lightBlue,
    separator = colors.purple,
    difference = colors.magenta,
    update = colors.gray
}

while true do
    s.clear()
    
    -- TITLE WITH COLOR
    s.setTextColor(colors.title)
    s.setCursorPos(8, 1)
    s.write("╔══════════════════════╗")
    s.setCursorPos(8, 2)
    s.write("║    WORLD CLOCK       ║")
    s.setCursorPos(8, 3)
    s.write("╚══════════════════════╝")
    
    -- BRAZIL
    s.setTextColor(colors.city)
    s.setCursorPos(3, 5)
    s.write("🇧🇷 SUMARE")
    
    s.setTextColor(colors.time)
    s.setCursorPos(3, 6)
    s.write(string.format("%02d:%02d:%02d", brHour, brMin, brSec))
    
    s.setTextColor(colors.date)
    s.setCursorPos(3, 7)
    s.write("08 JAN 2024")
    
    s.setTextColor(colors.weather)
    s.setCursorPos(3, 9)
    s.write("SUNNY")
    
    s.setTextColor(colors.temp)
    s.setCursorPos(3, 10)
    s.write("28°C")
    
    s.setTextColor(colors.details)
    s.setCursorPos(3, 11)
    s.write("H:65% W:5km/h")
    
    -- SEPARATOR
    s.setTextColor(colors.separator)
    s.setCursorPos(20, 5)
    s.write("│")
    s.setCursorPos(20, 6)
    s.write("│")
    s.setCursorPos(20, 7)
    s.write("│")
    s.setCursorPos(20, 8)
    s.write("│")
    s.setCursorPos(20, 9)
    s.write("│")
    s.setCursorPos(20, 10)
    s.write("│")
    s.setCursorPos(20, 11)
    s.write("│")
    
    -- VLADIVOSTOK
    s.setTextColor(colors.city)
    s.setCursorPos(22, 5)
    s.write("🇷🇺 VLADIVOSTOK")
    
    s.setTextColor(colors.time)
    s.setCursorPos(22, 6)
    s.write(string.format("%02d:%02d:%02d", vladHour, vladMin, vladSec))
    
    s.setTextColor(colors.date)
    s.setCursorPos(22, 7)
    s.write("09 JAN 2024")
    
    s.setTextColor(colors.purple)  -- Next day indicator
    s.setCursorPos(22, 8)
    s.write("(NEXT DAY)")
    
    s.setTextColor(colors.cyan)  -- Different color for Russian weather
    s.setCursorPos(22, 9)
    s.write("SNOWY")
    
    s.setTextColor(colors.blue)  -- Different color for Russian temp
    s.setCursorPos(22, 10)
    s.write("-12°C")
    
    s.setTextColor(colors.lightBlue)
    s.setCursorPos(22, 11)
    s.write("H:85% W:12km/h")
    
    -- BOTTOM INFO
    s.setTextColor(colors.difference)
    s.setCursorPos(10, 13)
    s.write("14 HOUR DIFFERENCE")
    
    s.setTextColor(colors.update)
    s.setCursorPos(10, 15)
    s.write("Updated: " .. os.date("%H:%M:%S"))
    
    -- Update time
    brSec = brSec + 1
    vladSec = vladSec + 1
    
    if brSec >= 60 then
        brSec = 0
        brMin = brMin + 1
        vladSec = 0
        vladMin = vladMin + 1
        
        if brMin >= 60 then
            brMin = 0
            brHour = (brHour + 1) % 24
            vladMin = 0
            vladHour = (vladHour + 1) % 24
            
            if brHour == 0 then
                -- Day change logic
                vladDay = 10
            end
        end
    end
    
    sleep(1)
end
