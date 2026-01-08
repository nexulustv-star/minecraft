-- correct_time.lua
print("=== Correct Time Display ===")
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

-- REAL current date and time (for simulation)
-- You can set these to actual current values
local currentYear = 2024
local currentMonth = 1    -- January = 1
local currentDay = 9      -- Today's day
local currentHour = 14    -- 2 PM
local currentMinute = 30  -- 30 minutes
local currentSecond = 0

-- Timezone offsets
local timezones = {
    sumare = -3,      -- Brazil (UTC-3)
    vladivostok = 11  -- Russia (UTC+11)
}

-- Month names
local monthNames = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

-- Day names
local dayNames = {
    "Sunday", "Monday", "Tuesday", "Wednesday", 
    "Thursday", "Friday", "Saturday"
}

-- Function to calculate correct date/time for a city
local function getCityDateTime(city)
    local offset = timezones[city]
    
    -- Calculate city time from our simulated current time
    local cityHour = (currentHour + offset) % 24
    local cityDay = currentDay
    local cityMonth = currentMonth
    local cityYear = currentYear
    
    -- Handle day rollover
    if cityHour < 0 then
        cityHour = cityHour + 24
        cityDay = cityDay - 1
        
        if cityDay < 1 then
            cityMonth = cityMonth - 1
            if cityMonth < 1 then
                cityMonth = 12
                cityYear = currentYear - 1
            end
            cityDay = 30  -- Simplified
        end
    elseif cityHour >= 24 then
        cityHour = cityHour - 24
        cityDay = cityDay + 1
        
        if cityDay > 30 then  -- Simplified month length
            cityDay = 1
            cityMonth = cityMonth + 1
            if cityMonth > 12 then
                cityMonth = 1
                cityYear = currentYear + 1
            end
        end
    end
    
    -- Calculate day of week (simplified)
    local totalDays = (currentYear - 2024) * 365 + (currentMonth - 1) * 30 + currentDay
    local dayOfWeek = dayNames[(totalDays % 7) + 1]
    
    return {
        hour = cityHour,
        minute = currentMinute,
        second = currentSecond,
        day = cityDay,
        month = cityMonth,
        monthName = monthNames[cityMonth],
        year = cityYear,
        dayName = dayOfWeek
    }
end

-- Function to format time as string
local function formatTime(datetime)
    return string.format("%02d:%02d:%02d", 
        datetime.hour, datetime.minute, datetime.second)
end

-- Function to format date as string
local function formatDate(datetime)
    return string.format("%s, %02d %s %04d",
        datetime.dayName, datetime.day, datetime.monthName, datetime.year)
end

-- Function to display city info
local function displayCity(city, x, y)
    local datetime = getCityDateTime(city)
    local cityName = ""
    local country = ""
    local timezone = ""
    
    if city == "sumare" then
        cityName = "SUMARÉ"
        country = "SÃO PAULO, BRAZIL"
        timezone = "BRT (UTC-3)"
    else
        cityName = "VLADIVOSTOK"
        country = "RUSSIA"
        timezone = "VLAT (UTC+11)"
    end
    
    -- City name
    screen.setTextColor(colors.yellow)
    screen.setCursorPos(x, y)
    screen.write(cityName)
    
    -- Country
    screen.setTextColor(colors.lightGray)
    screen.setCursorPos(x, y + 1)
    screen.write(country)
    
    -- Timezone
    screen.setCursorPos(x, y + 2)
    screen.write(timezone)
    
    -- Date
    screen.setTextColor(colors.cyan)
    screen.setCursorPos(x, y + 4)
    screen.write(formatDate(datetime))
    
    -- Time (large)
    screen.setTextColor(colors.green)
    screen.setCursorPos(x, y + 6)
    screen.write(formatTime(datetime))
    
    -- Current weather (simulated)
    screen.setTextColor(colors.orange)
    screen.setCursorPos(x, y + 8)
    if city == "sumare" then
        screen.write("Sunny, 28°C")
    else
        screen.write("Snow, -5°C")
    end
end

-- Main display function
local function display()
    if monitor then
        monitor.clear()
        
        -- Header
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(math.floor(width/2 - 10), 1)
        monitor.write("WORLD TIME COMPARISON")
        
        -- Separator
        monitor.setCursorPos(1, 2)
        monitor.write(string.rep("=", width))
        
        -- Display Sumaré (left)
        displayCity("sumare", 3, 4)
        
        -- Display Vladivostok (right)
        displayCity("vladivostok", math.floor(width/2 + 3), 4)
        
        -- Time difference
        monitor.setTextColor(colors.purple)
        monitor.setCursorPos(math.floor(width/2 - 10), height - 3)
        monitor.write("TIME DIFFERENCE: 14 HOURS")
        
        -- Update info
        monitor.setTextColor(colors.gray)
        monitor.setCursorPos(1, height)
        monitor.write("Simulated Date: " .. formatDate(getCityDateTime("sumare")))
        
    else
        -- Terminal display
        term.clear()
        term.setCursorPos(1, 1)
        
        term.setTextColor(colors.green)
        print("=== CORRECT TIME DISPLAY ===")
        print("")
        
        -- Sumaré
        local sumare = getCityDateTime("sumare")
        term.setTextColor(colors.yellow)
        print("SUMARÉ, SÃO PAULO, BRAZIL")
        term.setTextColor(colors.cyan)
        print(formatDate(sumare))
        term.setTextColor(colors.green)
        print(formatTime(sumare) .. " BRT (UTC-3)")
        term.setTextColor(colors.orange)
        print("Weather: Sunny, 28°C")
        
        print("")
        
        -- Vladivostok
        local vlad = getCityDateTime("vladivostok")
        term.setTextColor(colors.yellow)
        print("VLADIVOSTOK, RUSSIA")
        term.setTextColor(colors.cyan)
        print(formatDate(vlad))
        term.setTextColor(colors.green)
        print(formatTime(vlad) .. " VLAT (UTC+11)")
        term.setTextColor(colors.orange)
        print("Weather: Snow, -5°C")
        
        print("")
        term.setTextColor(colors.purple)
        print("Time difference: 14 hours")
        
        term.setTextColor(colors.gray)
        print("\n(Simulated time - Press Ctrl+T to stop)")
    end
end

-- Update time every second
local function updateClock()
    while true do
        -- Increment seconds
        currentSecond = currentSecond + 1
        
        -- Handle time rollover
        if currentSecond >= 60 then
            currentSecond = 0
            currentMinute = currentMinute + 1
            
            if currentMinute >= 60 then
                currentMinute = 0
                currentHour = currentHour + 1
                
                if currentHour >= 24 then
                    currentHour = 0
                    currentDay = currentDay + 1
                    
                    if currentDay > 30 then  -- Simplified
                        currentDay = 1
                        currentMonth = currentMonth + 1
                        
                        if currentMonth > 12 then
                            currentMonth = 1
                            currentYear = currentYear + 1
                        end
                    end
                end
            end
        end
        
        display()
        sleep(1)  -- Update every second
    end
end

-- Start the clock
print("Starting correct time display...")
print("Based on simulated date: " .. currentDay .. " " .. monthNames[currentMonth] .. " " .. currentYear)
print("Press Ctrl+T to stop")

updateClock()
