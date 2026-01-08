-- cities_real_time.lua
local m = peripheral.find("monitor") or term
m.clear()

-- City data
local cities = {
    {
        name = "SUMARE",
        country = "BRAZIL",
        timezone = -3,  -- UTC-3 (BRT)
        weather = "SUNNY",
        tempRange = "22°C-32°C"
    },
    {
        name = "VLADIVOSTOK",
        country = "RUSSIA",
        timezone = 11,  -- UTC+11 (VLAT)
        weather = "SNOW",
        tempRange = "-15°C-5°C"
    }
}

-- Weather options
local weatherOptions = {"SUNNY", "CLOUDY", "RAIN", "STORM", "SNOW", "FOG"}

print("Dual City Monitor - Real Time")
print("Updating every second...")

-- Function to get city time
local function getCityTime(timezone)
    local time = os.time()
    local hour = (time + (timezone * 3600)) % 24
    local minute = math.floor((time % 3600) / 60)
    local second = time % 60
    return string.format("%02d:%02d:%02d", hour, minute, second)
end

-- Function to get city date
local function getCityDate(timezone)
    local time = os.time()
    local adjustedTime = time + (timezone * 3600)
    local day = math.floor(adjustedTime / 86400) % 30 + 1
    local month = math.floor(adjustedTime / 2592000) % 12 + 1
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    return string.format("%02d %s", day, months[month])
end

-- Main display loop
while true do
    m.clear()
    
    -- Get current UNIX time once per loop
    local currentTime = os.time()
    
    -- Display Sumaré (left side)
    m.setCursorPos(2, 2)
    m.write("SUMARE, SP")
    
    m.setCursorPos(2, 3)
    m.write("BRAZIL")
    
    -- Brazil time (real-time)
    m.setCursorPos(2, 5)
    m.write(getCityTime(-3) .. " BRT")
    
    -- Brazil date
    m.setCursorPos(2, 6)
    m.write(getCityDate(-3))
    
    -- Brazil weather (changes occasionally)
    m.setCursorPos(2, 8)
    if math.random(1, 20) == 1 then  -- Random weather change
        cities[1].weather = weatherOptions[math.random(1, #weatherOptions)]
    end
    m.write(cities[1].weather)
    
    m.setCursorPos(2, 9)
    m.write(cities[1].tempRange)
    
    -- Display Vladivostok (right side)
    m.setCursorPos(25, 2)
    m.write("VLADIVOSTOK")
    
    m.setCursorPos(25, 3)
    m.write("RUSSIA")
    
    -- Russia time (real-time)
    m.setCursorPos(25, 5)
    m.write(getCityTime(11) .. " VLAT")
    
    -- Russia date
    m.setCursorPos(25, 6)
    m.write(getCityDate(11))
    
    -- Russia weather (changes occasionally)
    m.setCursorPos(25, 8)
    if math.random(1, 20) == 1 then  -- Random weather change
        cities[2].weather = weatherOptions[math.random(1, #weatherOptions)]
    end
    m.write(cities[2].weather)
    
    m.setCursorPos(25, 9)
    m.write(cities[2].tempRange)
    
    -- Time difference
    m.setCursorPos(10, 12)
    local diffHours = 11 - (-3)  -- 14 hours difference
    m.write("TIME DIFFERENCE: " .. diffHours .. " HOURS")
    
    -- Current UTC time
    m.setCursorPos(10, 14)
    m.write("UTC: " .. os.date("!%H:%M:%S"))
    
    -- Update time
    m.setCursorPos(10, 16)
    m.write("UPDATED: " .. os.date("%H:%M:%S"))
    
    -- Wait 1 second for real-time updates
    sleep(1)
end
