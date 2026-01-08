-- beautiful_cities.lua
print("=== Beautiful City Display ===")
print("")

-- Find monitor
local monitor = peripheral.find("monitor")
local screen = monitor or term

if monitor then
    monitor.setTextScale(1.5)
    width, height = monitor.getSize()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
else
    width, height = term.getSize()
    term.setBackgroundColor(colors.black)
    term.clear()
end

-- SET YOUR CURRENT BRAZIL TIME HERE:
local brazilHour = 14      -- 2 PM Brazil time
local brazilMinute = 30
local brazilSecond = 0
local brazilDay = 9
local brazilMonth = 1      -- January
local brazilYear = 2024

-- Month names
local monthNames = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"}

-- Function to calculate Vladivostok time
local function getVladivostokTime(brHour, brMin, brSec, day, month, year)
    -- Brazil UTC-3 to Vladivostok UTC+11 = 14 hour difference
    local vladHour = (brHour + 14) % 24
    local vladDay = day
    local vladMonth = month
    local vladYear = year
    
    if vladHour < brHour then
        vladDay = day + 1
        if vladDay > 31 then
            vladDay = 1
            vladMonth = month + 1
            if vladMonth > 12 then
                vladMonth = 1
                vladYear = year + 1
            end
        end
    end
    
    return {
        hour = vladHour,
        minute = brMin,
        second = brSec,
        day = vladDay,
        month = vladMonth,
        year = vladYear
    }
end

-- Get initial Vladivostok time
local vladTime = getVladivostokTime(brazilHour, brazilMinute, brazilSecond,
                                    brazilDay, brazilMonth, brazilYear)

-- Weather data
local weatherData = {
    sumare = {
        condition = "SUNNY",
        temp = 28,
        humidity = 65,
        wind = "5 km/h",
        icon = "☀",
        color = colors.yellow,
        bgColor = colors.orange
    },
    vladivostok = {
        condition = "SNOW",
        temp = -8,
        humidity = 85,
        wind = "12 km/h",
        icon = "❄",
        color = colors.cyan,
        bgColor = colors.blue
    }
}

-- Draw a box
local function drawBox(x, y, w, h, color)
    if monitor then
        -- Draw top border
        monitor.setBackgroundColor(color)
        monitor.setCursorPos(x, y)
        monitor.write(string.rep(" ", w))
        
        -- Draw sides
        for i = 1, h-2 do
            monitor.setCursorPos(x, y + i)
            monitor.write(" ")
            monitor.setCursorPos(x + w - 1, y + i)
            monitor.write(" ")
        end
        
        -- Draw bottom border
        monitor.setCursorPos(x, y + h - 1)
        monitor.write(string.rep(" ", w))
        
        monitor.setBackgroundColor(colors.black)
    end
end

-- Draw a filled box
local function drawFilledBox(x, y, w, h, color)
    if monitor then
        monitor.setBackgroundColor(color)
        for i = 0, h-1 do
            monitor.setCursorPos(x, y + i)
            monitor.write(string.rep(" ", w))
        end
        monitor.setBackgroundColor(colors.black)
    end
end

-- Draw centered text
local function drawCentered(text, y, color)
    if monitor then
        monitor.setTextColor(color)
        local x = math.floor((width - #text) / 2)
        monitor.setCursorPos(x, y)
        monitor.write(text)
    else
        term.setTextColor(color)
        local x = math.floor((width - #text) / 2)
        term.setCursorPos(x, y)
        write(text)
    end
end

-- Draw city display
local function drawCity(city, x, y, isLeft)
    local data = weatherData[city]
    local timeData = city == "sumare" and 
        {hour = brazilHour, minute = brazilMinute, second = brazilSecond,
         day = brazilDay, month = brazilMonth, year = brazilYear} or
        vladTime
    
    local cityName = city == "sumare" and "SUMARÉ" or "VLADIVOSTOK"
    local country = city == "sumare" and "BRAZIL" or "RUSSIA"
    local timezone = city == "sumare" and "UTC-3" or "UTC+11"
    
    -- City box
    local boxWidth = math.floor(width / 2) - 4
    local boxHeight = 12
    
    drawBox(x, y, boxWidth, boxHeight, data.bgColor)
    
    -- City header with gradient effect
    if monitor then
        monitor.setBackgroundColor(data.bgColor)
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(x + 2, y + 1)
        monitor.write("╔" .. string.rep("═", boxWidth - 4) .. "╗")
        
        monitor.setCursorPos(x + 2, y + 2)
        monitor.write("║ " .. cityName .. string.rep(" ", boxWidth - #cityName - 5) .. "║")
        
        monitor.setCursorPos(x + 2, y + 3)
        monitor.write("║ " .. country .. string.rep(" ", boxWidth - #country - 5) .. "║")
        
        monitor.setCursorPos(x + 2, y + 4)
        monitor.write("╚" .. string.rep("═", boxWidth - 4) .. "╝")
        
        monitor.setBackgroundColor(colors.black)
    end
    
    -- Time display (large)
    local timeStr = string.format("%02d:%02d:%02d", 
        timeData.hour, timeData.minute, timeData.second)
    
    if monitor then
        monitor.setTextColor(data.color)
        monitor.setCursorPos(x + math.floor((boxWidth - #timeStr) / 2), y + 6)
        monitor.write(timeStr)
        
        -- Timezone
        monitor.setTextColor(colors.lightGray)
        monitor.setCursorPos(x + math.floor((boxWidth - #timezone) / 2), y + 7)
        monitor.write(timezone)
        
        -- Date
        local dateStr = string.format("%02d %s %04d",
            timeData.day, monthNames[timeData.month], timeData.year)
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(x + math.floor((boxWidth - #dateStr) / 2), y + 8)
        monitor.write(dateStr)
        
        -- Weather icon and condition
        monitor.setTextColor(data.color)
        monitor.setCursorPos(x + 4, y + 10)
        monitor.write(data.icon .. " " .. data.condition)
        
        -- Temperature
        local tempStr = string.format("%d°C", data.temp)
        monitor.setTextColor(colors.orange)
        monitor.setCursorPos(x + boxWidth - #tempStr - 4, y + 10)
        monitor.write(tempStr)
        
        -- Additional info
        monitor.setTextColor(colors.lightBlue)
        monitor.setCursorPos(x + 4, y + 11)
        monitor.write("H:" .. data.humidity .. "% W:" .. data.wind)
    end
end

-- Draw separator
local function drawSeparator()
    if monitor then
        monitor.setTextColor(colors.purple)
        monitor.setCursorPos(math.floor(width/2) - 1, 3)
        monitor.write("││")
        for y = 4, height - 3 do
            monitor.setCursorPos(math.floor(width/2) - 1, y)
            monitor.write("  ")
        end
        monitor.setCursorPos(math.floor(width/2) - 1, height - 2)
        monitor.write("││")
    end
end

-- Draw header
local function drawHeader()
    if monitor then
        -- Top border
        monitor.setBackgroundColor(colors.blue)
        monitor.setCursorPos(1, 1)
        monitor.write(string.rep(" ", width))
        
        -- Title
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(math.floor(width/2 - 8), 1)
        monitor.write(" WORLD CLOCK ")
        
        monitor.setBackgroundColor(colors.black)
        
        -- Underline
        monitor.setTextColor(colors.cyan)
        monitor.setCursorPos(1, 2)
        monitor.write("╠" .. string.rep("═", width - 2) .. "╣")
    end
end

-- Draw footer
local function drawFooter()
    if monitor then
        -- Time difference
        monitor.setTextColor(colors.purple)
        monitor.setCursorPos(math.floor(width/2 - 10), height - 2)
        monitor.write(" TIME DIFFERENCE: 14 HOURS ")
        
        -- Bottom border
        monitor.setCursorPos(1, height - 1)
        monitor.write("╠" .. string.rep("═", width - 2) .. "╣")
        
        -- Status
        monitor.setTextColor(colors.gray)
        monitor.setCursorPos(2, height)
        monitor.write("LIVE • UPDATING • " .. os.date("%H:%M:%S"))
    end
end

-- Main display function
local function display()
    if monitor then
        monitor.clear()
        
        drawHeader()
        
        -- Calculate positions
        local leftX = 3
        local rightX = math.floor(width/2) + 2
        
        -- Draw cities
        drawCity("sumare", leftX, 4, true)
        drawCity("vladivostok", rightX, 4, false)
        
        drawSeparator()
        drawFooter()
        
    else
        -- Terminal display
        term.clear()
        term.setCursorPos(1, 1)
        
        term.setTextColor(colors.cyan)
        print("╔════════════════════════════════════════╗")
        term.setCursorPos(1, 2)
        term.write("║         WORLD CLOCK           ║")
        term.setCursorPos(1, 3)
        term.write("╚════════════════════════════════════════╝")
        print("")
        
        -- Sumaré
        term.setTextColor(colors.yellow)
        print("╔══════════════════════════════╗")
        print("║      SUMARE, BRAZIL          ║")
        print("║      UTC-3                   ║")
        print("╠══════════════════════════════╣")
        
        term.setTextColor(colors.green)
        print(string.format("║   TIME: %02d:%02d:%02d BRT        ║",
            brazilHour, brazilMinute, brazilSecond))
        
        term.setTextColor(colors.white)
        print(string.format("║   DATE: %02d %s %04d           ║",
            brazilDay, monthNames[brazilMonth], brazilYear))
        
        term.setTextColor(colors.orange)
        print("║   WEATHER: SUNNY 28°C        ║")
        print("╚══════════════════════════════╝")
        print("")
        
        -- Vladivostok
        term.setTextColor(colors.cyan)
        print("╔══════════════════════════════╗")
        print("║      VLADIVOSTOK, RUSSIA     ║")
        print("║      UTC+11                  ║")
        print("╠══════════════════════════════╣")
        
        term.setTextColor(colors.green)
        print(string.format("║   TIME: %02d:%02d:%02d VLAT       ║",
            vladTime.hour, vladTime.minute, vladTime.second))
        
        term.setTextColor(colors.white)
        print(string.format("║   DATE: %02d %s %04d           ║",
            vladTime.day, monthNames[vladTime.month], vladTime.year))
        
        if vladTime.day ~= brazilDay then
            term.setTextColor(colors.purple)
            print("║   (NEXT DAY)                 ║")
        end
        
        term.setTextColor(colors.cyan)
        print("║   WEATHER: SNOW -8°C         ║")
        print("╚══════════════════════════════╝")
        print("")
        
        term.setTextColor(colors.purple)
        print("⏰ TIME DIFFERENCE: 14 HOURS ⏰")
        
        term.setTextColor(colors.gray)
        print("\nPress Ctrl+T to stop")
    end
end

-- Update time
local function updateTime()
    while true do
        -- Update Brazil time
        brazilSecond = brazilSecond + 1
        
        if brazilSecond >= 60 then
            brazilSecond = 0
            brazilMinute = brazilMinute + 1
            
            if brazilMinute >= 60 then
                brazilMinute = 0
                brazilHour = (brazilHour + 1) % 24
                
                if brazilHour == 0 then
                    brazilDay = brazilDay + 1
                    if brazilDay > 31 then
                        brazilDay = 1
                        brazilMonth = brazilMonth + 1
                        if brazilMonth > 12 then
                            brazilMonth = 1
                            brazilYear = brazilYear + 1
                        end
                    end
                end
            end
        end
        
        -- Update Vladivostok time
        vladTime = getVladivostokTime(brazilHour, brazilMinute, brazilSecond,
                                     brazilDay, brazilMonth, brazilYear)
        
        -- Random weather changes (occasionally)
        if math.random(1, 50) == 1 then
            weatherData.sumare.temp = math.random(25, 32)
            weatherData.vladivostok.temp = math.random(-15, 5)
        end
        
        display()
        sleep(1)
    end
end

-- Start
print("Starting beautiful display...")
print("Brazil: " .. brazilHour .. ":" .. brazilMinute .. " BRT")
print("Vladivostok: " .. vladTime.hour .. ":" .. vladTime.minute .. " VLAT")
print("")

updateTime()
