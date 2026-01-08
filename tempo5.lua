-- correct_time_fixed.lua
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

-- SET YOUR CURRENT BRAZIL TIME HERE:
local brazilHour = 14    -- 2 PM Brazil time
local brazilMinute = 30
local brazilSecond = 0
local currentDay = 9
local currentMonth = 1    -- January
local currentYear = 2024

print("Brazil time set to: " .. brazilHour .. ":" .. brazilMinute)
print("Calculating Vladivostok time...")

-- Function to calculate Vladivostok time correctly
local function calculateVladivostokTime(brHour, brMin, brSec, day, month, year)
    -- Brazil is UTC-3, Vladivostok is UTC+11
    -- Difference = 14 hours (11 - (-3))
    
    -- Convert Brazil time to UTC
    local utcHour = (brHour + 3) % 24
    local utcDay = day
    local utcMonth = month
    local utcYear = year
    
    -- If UTC hour < Brazil hour, it's next day
    if utcHour < brHour then
        utcDay = utcDay + 1
        -- Handle month/year rollover (simplified)
        if utcDay > 30 then
            utcDay = 1
            utcMonth = utcMonth + 1
            if utcMonth > 12 then
                utcMonth = 1
                utcYear = year + 1
            end
        end
    end
    
    -- Convert UTC to Vladivostok time (UTC+11)
    local vladHour = (utcHour + 11) % 24
    local vladDay = utcDay
    local vladMonth = utcMonth
    local vladYear = utcYear
    
    -- If Vladivostok hour < UTC hour, it's next day
    if vladHour < utcHour then
        vladDay = vladDay + 1
        if vladDay > 30 then
            vladDay = 1
            vladMonth = vladMonth + 1
            if vladMonth > 12 then
                vladMonth = 1
                vladYear = vladYear + 1
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

-- Calculate initial Vladivostok time
local vladTime = calculateVladivostokTime(brazilHour, brazilMinute, brazilSecond, 
                                          currentDay, currentMonth, currentYear)

-- Month names
local monthNames = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
}

-- Display function
local function display()
    if monitor then
        monitor.clear()
        
        -- Header
        monitor.setTextColor(colors.cyan)
        monitor.setCursorPos(math.floor(width/2 - 8), 1)
        monitor.write("WORLD TIME CLOCK")
        
        -- Separator
        monitor.setCursorPos(1, 2)
        monitor.write(string.rep("=", width))
        
        -- LEFT: SUMARÉ, BRAZIL
        monitor.setTextColor(colors.yellow)
        monitor.setCursorPos(5, 4)
        monitor.write("SUMARÉ, SÃO PAULO")
        
        monitor.setTextColor(colors.lightGray)
        monitor.setCursorPos(5, 5)
        monitor.write("BRAZIL (UTC-3)")
        
        -- Brazil time (LARGE)
        monitor.setTextColor(colors.green)
        monitor.setCursorPos(5, 7)
        monitor.write(string.format("%02d:%02d:%02d", 
            brazilHour, brazilMinute, brazilSecond))
        
        monitor.setCursorPos(5, 8)
        monitor.write("BRT")
        
        -- Brazil date
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(5, 10)
        monitor.write(string.format("%02d %s %04d",
            currentDay, monthNames[currentMonth], currentYear))
        
        -- Brazil weather
        monitor.setTextColor(colors.orange)
        monitor.setCursorPos(5, 12)
        monitor.write("Sunny, 28°C")
        
        -- RIGHT: VLADIVOSTOK, RUSSIA
        monitor.setTextColor(colors.yellow)
        monitor.setCursorPos(width - 20, 4)
        monitor.write("VLADIVOSTOK")
        
        monitor.setTextColor(colors.lightGray)
        monitor.setCursorPos(width - 20, 5)
        monitor.write("RUSSIA (UTC+11)")
        
        -- Vladivostok time (LARGE) - SHOULD BE ~4:30 AM
        monitor.setTextColor(colors.green)
        monitor.setCursorPos(width - 20, 7)
        monitor.write(string.format("%02d:%02d:%02d",
            vladTime.hour, vladTime.minute, vladTime.second))
        
        monitor.setCursorPos(width - 20, 8)
        monitor.write("VLAT")
        
        -- Vladivostok date
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(width - 20, 10)
        monitor.write(string.format("%02d %s %04d",
            vladTime.day, monthNames[vladTime.month], vladTime.year))
        
        -- Check if different day
        if vladTime.day ~= currentDay then
            monitor.setTextColor(colors.purple)
            monitor.setCursorPos(width - 20, 11)
            monitor.write("(Next Day)")
        end
        
        -- Vladivostok weather
        monitor.setTextColor(colors.cyan)
        monitor.setCursorPos(width - 20, 12)
        monitor.write("Snow, -8°C")
        
        -- Time difference
        monitor.setTextColor(colors.purple)
        monitor.setCursorPos(math.floor(width/2 - 7), height - 3)
        monitor.write("TIME DIFFERENCE: 14 HOURS")
        
        -- Bottom info
        monitor.setTextColor(colors.gray)
        monitor.setCursorPos(1, height)
        monitor.write(string.format("Brazil: %02d:%02d | Russia: %02d:%02d",
            brazilHour, brazilMinute, vladTime.hour, vladTime.minute))
        
    else
        -- Terminal display
        term.clear()
        term.setCursorPos(1, 1)
        
        term.setTextColor(colors.green)
        print("=== CORRECT TIME ===")
        print("")
        
        term.setTextColor(colors.yellow)
        print("SUMARÉ, BRAZIL (UTC-3)")
        term.setTextColor(colors.green)
        print(string.format("Time: %02d:%02d:%02d BRT",
            brazilHour, brazilMinute, brazilSecond))
        term.setTextColor(colors.white)
        print(string.format("Date: %02d %s %04d",
            currentDay, monthNames[currentMonth], currentYear))
        term.setTextColor(colors.orange)
        print("Weather: Sunny, 28°C")
        
        print("")
        
        term.setTextColor(colors.yellow)
        print("VLADIVOSTOK, RUSSIA (UTC+11)")
        term.setTextColor(colors.green)
        print(string.format("Time: %02d:%02d:%02d VLAT",
            vladTime.hour, vladTime.minute, vladTime.second))
        term.setTextColor(colors.white)
        print(string.format("Date: %02d %s %04d",
            vladTime.day, monthNames[vladTime.month], vladTime.year))
        
        if vladTime.day ~= currentDay then
            term.setTextColor(colors.purple)
            print("(Next Day in Russia)")
        end
        
        term.setTextColor(colors.cyan)
        print("Weather: Snow, -8°C")
        
        print("")
        term.setTextColor(colors.purple)
        print("Time difference: 14 hours")
        
        term.setTextColor(colors.gray)
        print("\nPress Ctrl+T to stop")
    end
end

-- Update time every second
local function updateTime()
    while true do
        -- Update Brazil seconds
        brazilSecond = brazilSecond + 1
        
        -- Handle Brazil time rollover
        if brazilSecond >= 60 then
            brazilSecond = 0
            brazilMinute = brazilMinute + 1
            
            if brazilMinute >= 60 then
                brazilMinute = 0
                brazilHour = (brazilHour + 1) % 24
                
                if brazilHour == 0 then  -- Midnight in Brazil
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
        
        -- Recalculate Vladivostok time
        vladTime = calculateVladivostokTime(brazilHour, brazilMinute, brazilSecond,
                                           currentDay, currentMonth, currentYear)
        
        -- Display
        display()
        
        -- Wait 1 second
        sleep(1)
    end
end

-- Show initial calculation
print("")
print("Brazil: " .. brazilHour .. ":" .. brazilMinute .. " BRT")
print("Vladivostok: " .. vladTime.hour .. ":" .. vladTime.minute .. " VLAT")
print("")

-- Start the clock
updateTime()
