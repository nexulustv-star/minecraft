-- simple_colors.lua
local screen = peripheral.find("monitor") or term
screen.clear()

-- Brazil time
local brHour = 14
local brMin = 49
local brSec = 0

-- Vladivostok time
local vladHour = 4
local vladMin = 49
local vladSec = 0

print("Colored world clock starting...")

while true do
    screen.clear()
    
    -- TITLE
    screen.setTextColor(colors.cyan)
    screen.setCursorPos(10, 1)
    screen.write("WORLD TIME DISPLAY")
    
    screen.setTextColor(colors.gray)
    screen.setCursorPos(1, 2)
    screen.write("========================================")
    
    -- BRAZIL (YELLOW/GREEN THEME)
    screen.setTextColor(colors.yellow)
    screen.setCursorPos(3, 4)
    screen.write("SUMARE, BRAZIL")
    
    screen.setTextColor(colors.lightGray)
    screen.setCursorPos(3, 5)
    screen.write("UTC-3")
    
    screen.setTextColor(colors.green)
    screen.setCursorPos(3, 7)
    screen.write(string.format("%02d:%02d:%02d", brHour, brMin, brSec))
    
    screen.setTextColor(colors.white)
    screen.setCursorPos(3, 8)
    screen.write("08 JAN 2024")
    
    screen.setTextColor(colors.orange)
    screen.setCursorPos(3, 10)
    screen.write("SUNNY 28°C")
    
    screen.setTextColor(colors.lightBlue)
    screen.setCursorPos(3, 11)
    screen.write("H:65% W:5km/h")
    
    -- SEPARATOR
    screen.setTextColor(colors.purple)
    screen.setCursorPos(20, 4)
    screen.write("|")
    screen.setCursorPos(20, 5)
    screen.write("|")
    screen.setCursorPos(20, 6)
    screen.write("|")
    screen.setCursorPos(20, 7)
    screen.write("|")
    screen.setCursorPos(20, 8)
    screen.write("|")
    screen.setCursorPos(20, 9)
    screen.write("|")
    screen.setCursorPos(20, 10)
    screen.write("|")
    screen.setCursorPos(20, 11)
    screen.write("|")
    
    -- VLADIVOSTOK (CYAN/BLUE THEME)
    screen.setTextColor(colors.cyan)
    screen.setCursorPos(22, 4)
    screen.write("VLADIVOSTOK, RUSSIA")
    
    screen.setTextColor(colors.lightGray)
    screen.setCursorPos(22, 5)
    screen.write("UTC+11")
    
    screen.setTextColor(colors.green)
    screen.setCursorPos(22, 7)
    screen.write(string.format("%02d:%02d:%02d", vladHour, vladMin, vladSec))
    
    screen.setTextColor(colors.white)
    screen.setCursorPos(22, 8)
    screen.write("09 JAN 2024")
    
    screen.setTextColor(colors.purple)
    screen.setCursorPos(22, 9)
    screen.write("(+1 DAY)")
    
    screen.setTextColor(colors.cyan)
    screen.setCursorPos(22, 10)
    screen.write("SNOWY -12°C")
    
    screen.setTextColor(colors.lightBlue)
    screen.setCursorPos(22, 11)
    screen.write("H:85% W:12km/h")
    
    -- BOTTOM
    screen.setTextColor(colors.magenta)
    screen.setCursorPos(10, 13)
    screen.write("TIME DIFFERENCE: 14 HOURS")
    
    screen.setTextColor(colors.gray)
    screen.setCursorPos(10, 15)
    screen.write("Live: " .. os.date("%H:%M:%S"))
    
    -- Update seconds
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
        end
    end
    
    sleep(1)
end
