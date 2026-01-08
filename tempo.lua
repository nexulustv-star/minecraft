-- cities_compact.lua
local m = peripheral.find("monitor") or term
m.clear()

local cities = {
    {name = "SUMARE", country = "BR", tz = -3, temp = "25°C", weather = "SUNNY"},
    {name = "VLADIVOSTOK", country = "RU", tz = 11, temp = "-5°C", weather = "SNOW"}
}

local weathers = {
    "SUNNY", "CLOUDY", "RAIN", "STORM", "SNOW", "FOG"
}

local i = 1

print("Dual City Monitor")
print("Updating...")

while true do
    m.clear()
    
    -- Sumaré
    m.setCursorPos(2, 2)
    m.write("SUMARE, SP")
    
    m.setCursorPos(2, 3)
    m.write("BRAZIL (UTC-3)")
    
    -- Current Brazil time
    local time = os.time()
    local brHour = (time - 3*3600) % 24
    local brTime = string.format("%02d:%02d", brHour, math.floor((time%3600)/60))
    
    m.setCursorPos(2, 5)
    m.write(brTime .. " BRT")
    
    m.setCursorPos(2, 7)
    m.write(weathers[(i % #weathers) + 1])
    
    m.setCursorPos(2, 8)
    m.write("22°C to 32°C")
    
    -- Vladivostok
    m.setCursorPos(25, 2)
    m.write("VLADIVOSTOK")
    
    m.setCursorPos(25, 3)
    m.write("RUSSIA (UTC+11)")
    
    -- Current Russia time
    local ruHour = (time + 11*3600) % 24
    local ruTime = string.format("%02d:%02d", ruHour, math.floor((time%3600)/60))
    
    m.setCursorPos(25, 5)
    m.write(ruTime .. " VLAT")
    
    m.setCursorPos(25, 7)
    m.write(weathers[((i+2) % #weathers) + 1])
    
    m.setCursorPos(25, 8)
    m.write("-15°C to 5°C")
    
    -- Time difference
    m.setCursorPos(10, 10)
    m.write("Difference: 14 hours")
    
    -- Update counter
    i = i + 1
    
    sleep(15)  -- Update every 15 seconds
end
