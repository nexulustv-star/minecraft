-- modern_display.lua
local m = peripheral.find("monitor") or term
m.clear()

-- Colors for modern look
local colors = {
    background = colors.black,
    primary = colors.cyan,
    secondary = colors.purple,
    accent = colors.orange,
    text = colors.white,
    success = colors.green,
    warning = colors.yellow
}

-- City data
local cities = {
    {
        name = "SUMARÉ",
        country = "BR",
        tz = -3,
        time = "14:30:00",
        date = "09 JAN 2024",
        weather = "☀ SUNNY",
        temp = "28°C",
        color = colors.yellow
    },
    {
        name = "VLADIVOSTOK",
        country = "RU",
        tz = 11,
        time = "04:30:00",
        date = "10 JAN 2024",
        weather = "❄ SNOW",
        temp = "-8°C",
        color = colors.cyan
    }
}

-- Draw modern card
local function drawCard(city, x, y, w, h)
    -- Card background
    m.setBackgroundColor(colors.gray)
    for i = 0, h-1 do
        m.setCursorPos(x, y + i)
        m.write(string.rep(" ", w))
    end
    
    -- Top accent bar
    m.setBackgroundColor(city.color)
    m.setCursorPos(x, y)
    m.write(string.rep(" ", w))
    
    -- City name
    m.setBackgroundColor(colors.gray)
    m.setTextColor(colors.white)
    m.setCursorPos(x + 2, y + 1)
    m.write(city.name)
    
    m.setTextColor(colors.lightGray)
    m.setCursorPos(x + w - 4, y + 1)
    m.write(city.country)
    
    -- Time (large)
    m.setTextColor(colors.white)
    m.setCursorPos(x + 2, y + 3)
    m.write(city.time)
    
    -- Date
    m.setTextColor(colors.lightGray)
    m.setCursorPos(x + 2, y + 4)
    m.write(city.date)
    
    -- Weather
    m.setTextColor(city.color)
    m.setCursorPos(x + 2, y + 6)
    m.write(city.weather)
    
    -- Temperature
    m.setCursorPos(x + w - 6, y + 6)
    m.write(city.temp)
    
    m.setBackgroundColor(colors.black)
end

-- Update time
local function updateTime()
    local second = 0
    while true do
        -- Update Brazil time
        cities[1].time = string.format("14:%02d:%02d", 30 + math.floor(second/60), second % 60)
        
        -- Update Russia time (14 hours ahead)
        local ruHour = (14 + math.floor(second/3600)) % 24
        local ruMin = (30 + math.floor((second%3600)/60)) % 60
        local ruSec = second % 60
        cities[2].time = string.format("%02d:%02d:%02d", ruHour, ruMin, ruSec)
        
        -- Clear and draw
        m.clear()
        
        -- Header
        m.setTextColor(colors.primary)
        m.setCursorPos(5, 2)
        m.write("╔══════════════════════════════════╗")
        m.setCursorPos(5, 3)
        m.write("║       WORLD TIME DISPLAY        ║")
        m.setCursorPos(5, 4)
        m.write("╚══════════════════════════════════╝")
        
        -- Cards
        drawCard(cities[1], 5, 6, 18, 9)
        drawCard(cities[2], 25, 6, 18, 9)
        
        -- Connection line
        m.setTextColor(colors.secondary)
        m.setCursorPos(23, 10)
        m.write("←14h→")
        
        -- Footer
        m.setTextColor(colors.lightGray)
        m.setCursorPos(10, 16)
        m.write("LIVE UPDATE • " .. os.date("%H:%M:%S"))
        
        second = second + 1
        sleep(1)
    end
end

print("Modern display starting...")
updateTime()
