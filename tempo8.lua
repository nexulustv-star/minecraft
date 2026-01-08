-- simple_fix.lua
local screen = peripheral.find("monitor") or term
screen.clear()

-- Brazil time (you set this)
local brHour = 14  -- 2 PM
local brMin = 30
local brSec = 0

-- Calculate Vladivostok time CORRECTLY:
-- Brazil UTC-3 = 14:30
-- UTC = 17:30 (14:30 + 3)
-- Vladivostok UTC+11 = 04:30 (17:30 + 11 = 28:30 → 04:30 next day)

local vladHour = (brHour + 14) % 24  -- 14 hour difference
local vladDay = 9  -- Same day
if vladHour < brHour then
    vladDay = 10  -- Next day in Russia
end

print("Brazil: " .. brHour .. ":" .. brMin)
print("Vladivostok: " .. vladHour .. ":" .. brMin)
print("")

while true do
    screen.clear()
    
    -- Brazil
    screen.setCursorPos(2, 2)
    screen.write("BRAZIL (UTC-3)")
    screen.setCursorPos(2, 3)
    screen.write(string.format("%02d:%02d:%02d", brHour, brMin, brSec))
    screen.setCursorPos(2, 4)
    screen.write("9 Jan 2024")
    
    -- Vladivostok
    screen.setCursorPos(25, 2)
    screen.write("RUSSIA (UTC+11)")
    screen.setCursorPos(25, 3)
    screen.write(string.format("%02d:%02d:%02d", vladHour, brMin, brSec))
    screen.setCursorPos(25, 4)
    screen.write(string.format("%d Jan 2024", vladDay))
    
    if vladDay == 10 then
        screen.setCursorPos(25, 5)
        screen.write("(Next Day)")
    end
    
    -- Update seconds
    brSec = brSec + 1
    if brSec >= 60 then
        brSec = 0
        brMin = brMin + 1
        if brMin >= 60 then
            brMin = 0
            brHour = (brHour + 1) % 24
            vladHour = (vladHour + 1) % 24
            
            -- Check day change
            if brHour == 0 then
                vladDay = 10
            end
        end
    end
    
    sleep(1)
end
