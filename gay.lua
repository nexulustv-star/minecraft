-- vasya_display.lua
print("=== Vasya Display ===")
print("Loading animated text...")

-- Find monitor
local monitor = peripheral.find("monitor")
local usingMonitor = true

if not monitor then
    print("No monitor found! Using computer screen.")
    usingMonitor = false
end

-- Setup display
local width, height
if usingMonitor then
    monitor.setTextScale(2)  -- Large text
    width, height = monitor.getSize()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
else
    width, height = term.getSize()
    term.setBackgroundColor(colors.black)
    term.clear()
end

print("Display size: " .. width .. "x" .. height)

-- Main text to display
local messages = {
    "VASYA IS GAY",
    "VASYA = GAY",
    "GAY VASYA",
    "VASYA ♥ BOYS"
}

-- Color palette (rainbow colors)
local rainbowColors = {
    colors.red,
    colors.orange,
    colors.yellow,
    colors.green,
    colors.blue,
    colors.purple,
    colors.pink,
    colors.white
}

-- Animation effects
local effects = {
    "bounce",
    "scroll",
    "rotate",
    "rainbow",
    "pulse",
    "fireworks",
    "typewriter",
    "matrix"
}

-- Function to write to display
local function writeToDisplay(x, y, text, color)
    if usingMonitor then
        monitor.setCursorPos(x, y)
        if color then monitor.setTextColor(color) end
        monitor.write(text)
    else
        term.setCursorPos(x, y)
        if color then term.setTextColor(color) end
        write(text)
    end
end

-- Function to clear display
local function clearDisplay()
    if usingMonitor then
        monitor.clear()
    else
        term.clear()
    end
end

-- Function to clear a specific area
local function clearArea(x, y, width, height)
    for i = 0, height - 1 do
        if usingMonitor then
            monitor.setCursorPos(x, y + i)
            monitor.write(string.rep(" ", width))
        else
            term.setCursorPos(x, y + i)
            write(string.rep(" ", width))
        end
    end
end

-- 1. BOUNCE EFFECT
local function bounceEffect()
    print("Starting BOUNCE effect...")
    
    local text = messages[1]
    local textLength = #text
    local x, y = 1, 1
    local dx, dy = 1, 1  -- Movement direction
    local colorIndex = 1
    
    while true do
        -- Clear previous position
        clearArea(x, y, textLength, 1)
        
        -- Move
        x = x + dx
        y = y + dy
        
        -- Bounce off edges
        if x <= 1 or x + textLength > width then
            dx = -dx
            colorIndex = (colorIndex % #rainbowColors) + 1
        end
        
        if y <= 1 or y > height then
            dy = -dy
            colorIndex = (colorIndex % #rainbowColors) + 1
        end
        
        -- Draw at new position
        writeToDisplay(x, y, text, rainbowColors[colorIndex])
        
        -- Show effect name
        writeToDisplay(1, 1, "BOUNCE", colors.gray)
        
        -- Check for key press
        local event = os.pullEventRaw(0.05)
        if event == "key" then
            break
        end
    end
end

-- 2. SCROLL EFFECT
local function scrollEffect()
    print("Starting SCROLL effect...")
    
    local texts = {
        ">>> VASYA IS GAY <<<",
        ">>> VASYA = GAY <<<",
        ">>> GAY VASYA <<<"
    }
    
    local textIndex = 1
    local x = width  -- Start from right side
    
    while true do
        local text = texts[textIndex]
        
        -- Clear line
        if usingMonitor then
            monitor.setCursorPos(1, math.floor(height / 2))
            monitor.write(string.rep(" ", width))
        else
            term.setCursorPos(1, math.floor(height / 2))
            write(string.rep(" ", width))
        end
        
        -- Draw scrolling text
        writeToDisplay(x, math.floor(height / 2), text, rainbowColors[(textIndex % #rainbowColors) + 1])
        
        -- Move left
        x = x - 1
        
        -- Change text when off screen
        if x + #text < 1 then
            x = width
            textIndex = (textIndex % #texts) + 1
        end
        
        -- Show effect name
        writeToDisplay(1, 1, "SCROLL", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.1)
        if event == "key" then
            break
        end
    end
end

-- 3. RAINBOW EFFECT
local function rainbowEffect()
    print("Starting RAINBOW effect...")
    
    local text = "VASYA IS GAY"
    local centerX = math.floor((width - #text) / 2)
    local centerY = math.floor(height / 2)
    
    while true do
        -- Cycle through each character with different colors
        for charIndex = 1, #text do
            local char = text:sub(charIndex, charIndex)
            local colorIndex = (charIndex % #rainbowColors) + 1
            
            writeToDisplay(centerX + charIndex - 1, centerY, char, rainbowColors[colorIndex])
        end
        
        -- Rotate colors
        local firstColor = table.remove(rainbowColors, 1)
        table.insert(rainbowColors, firstColor)
        
        -- Show effect name
        writeToDisplay(1, 1, "RAINBOW", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.2)
        if event == "key" then
            break
        end
    end
end

-- 4. PULSE EFFECT
local function pulseEffect()
    print("Starting PULSE effect...")
    
    local texts = messages
    local textIndex = 1
    local pulseSize = 1
    
    while true do
        clearDisplay()
        
        local text = texts[textIndex]
        local scale = 1 + (math.sin(pulseSize) * 0.5)  -- Pulse between 1x and 1.5x
        
        -- Calculate position with pulse
        local displayText = text
        if scale > 1 then
            displayText = " " .. text .. " "
        end
        
        local x = math.floor((width - #displayText) / 2)
        local y = math.floor(height / 2)
        
        -- Draw with pulsing color
        local colorIndex = math.floor(pulseSize) % #rainbowColors + 1
        writeToDisplay(x, y, displayText, rainbowColors[colorIndex])
        
        -- Add pulsing border
        for i = -1, 1 do
            for j = -1, 1 do
                if i ~= 0 or j ~= 0 then
                    writeToDisplay(x + i, y + j, displayText, colors.gray)
                end
            end
        end
        
        pulseSize = pulseSize + 0.1
        
        -- Change text every few pulses
        if math.floor(pulseSize) % 10 == 0 then
            textIndex = (textIndex % #texts) + 1
        end
        
        -- Show effect name
        writeToDisplay(1, 1, "PULSE", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.05)
        if event == "key" then
            break
        end
    end
end

-- 5. FIREWORKS EFFECT
local function fireworksEffect()
    print("Starting FIREWORKS effect...")
    
    local particles = {}
    
    while true do
        clearDisplay()
        
        -- Occasionally create new firework
        if math.random(1, 10) == 1 then
            local firework = {
                x = math.random(5, width - 5),
                y = height,
                speed = math.random(2, 4),
                color = rainbowColors[math.random(#rainbowColors)],
                particles = {}
            }
            
            -- Create explosion particles
            for i = 1, 20 do
                table.insert(firework.particles, {
                    x = firework.x,
                    y = firework.y,
                    dx = (math.random() - 0.5) * 2,
                    dy = (math.random() - 0.5) * 2,
                    life = 30,
                    color = rainbowColors[math.random(#rainbowColors)]
                })
            end
            
            table.insert(particles, firework)
        end
        
        -- Update and draw particles
        for i = #particles, 1, -1 do
            local fw = particles[i]
            
            -- Move firework up
            fw.y = fw.y - fw.speed
            
            -- Draw VASYA text at firework position
            if fw.y > 0 and fw.y <= height then
                local text = "VASYA"
                writeToDisplay(fw.x - math.floor(#text / 2), fw.y, text, fw.color)
            end
            
            -- Update explosion particles
            for j, p in ipairs(fw.particles) do
                p.x = p.x + p.dx
                p.y = p.y + p.dy
                p.life = p.life - 1
                
                if p.life > 0 and p.x >= 1 and p.x <= width and p.y >= 1 and p.y <= height then
                    writeToDisplay(math.floor(p.x), math.floor(p.y), "*", p.color)
                end
            end
            
            -- Remove dead fireworks
            if fw.y < -5 then
                table.remove(particles, i)
            end
        end
        
        -- Show text in center
        local text = "IS GAY"
        writeToDisplay(math.floor((width - #text) / 2), math.floor(height / 2), text, rainbowColors[math.random(#rainbowColors)])
        
        -- Show effect name
        writeToDisplay(1, 1, "FIREWORKS", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.05)
        if event == "key" then
            break
        end
    end
end

-- 6. MATRIX EFFECT
local function matrixEffect()
    print("Starting MATRIX effect...")
    
    local columns = {}
    local chars = "VASYAGAY0123456789"
    
    -- Initialize columns
    for i = 1, width do
        columns[i] = {
            position = math.random(-height, 0),
            speed = math.random(1, 3),
            length = math.random(5, 15)
        }
    end
    
    while true do
        clearDisplay()
        
        -- Draw each column
        for x = 1, width do
            local col = columns[x]
            
            -- Move column down
            col.position = col.position + col.speed * 0.3
            
            -- Draw characters in this column
            for i = 0, col.length do
                local y = math.floor(col.position) - i
                
                if y >= 1 and y <= height then
                    -- Fade brightness
                    local brightness = 1 - (i / col.length)
                    
                    local char
                    if i == 0 then
                        char = "VASYA"[math.random(1, 5)]
                    else
                        char = chars:sub(math.random(1, #chars), math.random(1, #chars))
                    end
                    
                    local color
                    if brightness > 0.7 then
                        color = colors.green
                    elseif brightness > 0.4 then
                        color = colors.lime
                    else
                        color = colors.gray
                    end
                    
                    writeToDisplay(x, y, char, color)
                end
            end
            
            -- Reset column when off screen
            if col.position - col.length > height then
                col.position = math.random(-height, 0)
                col.length = math.random(5, 15)
                col.speed = math.random(1, 3)
            end
        end
        
        -- Show "IS GAY" in the middle
        local text = "IS GAY"
        writeToDisplay(math.floor((width - #text) / 2), math.floor(height / 2), text, colors.white)
        
        -- Show effect name
        writeToDisplay(1, 1, "MATRIX", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.05)
        if event == "key" then
            break
        end
    end
end

-- 7. ROTATING EFFECT
local function rotatingEffect()
    print("Starting ROTATING effect...")
    
    local text = "VASYA IS GAY"
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)
    local angle = 0
    local radius = math.min(width, height) / 3
    
    while true do
        clearDisplay()
        
        -- Draw rotating text
        for i = 1, #text do
            local char = text:sub(i, i)
            local charAngle = angle + (i * math.pi * 2 / #text)
            
            local x = centerX + math.cos(charAngle) * radius - 0.5
            local y = centerY + math.sin(charAngle) * radius
            
            writeToDisplay(math.floor(x), math.floor(y), char, rainbowColors[(i % #rainbowColors) + 1])
        end
        
        angle = angle + 0.1
        
        -- Draw center text
        writeToDisplay(centerX - 1, centerY, "♥", colors.red)
        
        -- Show effect name
        writeToDisplay(1, 1, "ROTATING", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.05)
        if event == "key" then
            break
        end
    end
end

-- 8. TYPEWRITER EFFECT
local function typewriterEffect()
    print("Starting TYPEWRITER effect...")
    
    local fullText = "VASYA IS VERY VERY GAY AND EVERYONE KNOWS IT!"
    local displayedText = ""
    local x = math.floor((width - #fullText) / 2)
    local y = math.floor(height / 2)
    local charIndex = 1
    
    while true do
        clearDisplay()
        
        -- Type out text character by character
        if charIndex <= #fullText then
            displayedText = displayedText .. fullText:sub(charIndex, charIndex)
            charIndex = charIndex + 1
        else
            -- Reset when done
            displayedText = ""
            charIndex = 1
        end
        
        -- Draw text
        for i = 1, #displayedText do
            local char = displayedText:sub(i, i)
            writeToDisplay(x + i - 1, y, char, rainbowColors[(i % #rainbowColors) + 1])
        end
        
        -- Draw blinking cursor
        if charIndex <= #fullText then
            writeToDisplay(x + #displayedText, y, "_", colors.white)
        end
        
        -- Show effect name
        writeToDisplay(1, 1, "TYPEWRITER", colors.gray)
        
        -- Check for exit
        local event = os.pullEventRaw(0.2)
        if event == "key" then
            break
        end
    end
end

-- Main menu
local function showMenu()
    clearDisplay()
    
    -- Draw header
    local header = [[
╔══════════════════════════════╗
║     VASYA IS GAY DISPLAY     ║
╚══════════════════════════════╝
    ]]
    
    local lines = {}
    for line in header:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    for i, line in ipairs(lines) do
        local x = math.floor((width - #line) / 2)
        writeToDisplay(x, i, line, colors.blue)
    end
    
    -- Show menu options
    local options = {
        "1. BOUNCE - Text bounces around",
        "2. SCROLL - Text scrolls across",
        "3. RAINBOW - Rainbow colors",
        "4. PULSE - Pulsing text effect",
        "5. FIREWORKS - Exploding text",
        "6. MATRIX - Matrix-style fall",
        "7. ROTATING - Circular rotation",
        "8. TYPEWRITER - Typing effect",
        "9. ALL EFFECTS - Cycle through all",
        "0. EXIT"
    }
    
    local startY = #lines + 2
    for i, option in ipairs(options) do
        writeToDisplay(2, startY + i, option, colors.white)
    end
    
    -- Show current display info
    writeToDisplay(1, height, "Display: " .. (usingMonitor and "MONITOR" or "TERMINAL") .. 
                   " (" .. width .. "x" .. height .. ")", colors.gray)
end

-- Function to run all effects in sequence
local function runAllEffects()
    local allEffects = {
        bounceEffect,
        scrollEffect,
        rainbowEffect,
        pulseEffect,
        fireworksEffect,
        matrixEffect,
        rotatingEffect,
        typewriterEffect
    }
    
    for i, effect in ipairs(allEffects) do
        clearDisplay()
        writeToDisplay(math.floor(width/2)-5, math.floor(height/2), 
                      "Effect " .. i .. "/" .. #allEffects, colors.yellow)
        sleep(1)
        
        effect()
        
        -- Brief pause between effects
        clearDisplay()
        writeToDisplay(math.floor(width/2)-5, math.floor(height/2), 
                      "Next effect...", colors.green)
        sleep(1)
    end
end

-- Main program loop
local running = true

while running do
    showMenu()
    
    writeToDisplay(2, height - 1, "Select effect (0-9): ", colors.yellow)
    
    if usingMonitor then
        monitor.setCursorPos(24, height - 1)
    else
        term.setCursorPos(24, height - 1)
    end
    
    local choice = read()
    
    if choice == "0" then
        running = false
    elseif choice == "1" then
        bounceEffect()
    elseif choice == "2" then
        scrollEffect()
    elseif choice == "3" then
        rainbowEffect()
    elseif choice == "4" then
        pulseEffect()
    elseif choice == "5" then
        fireworksEffect()
    elseif choice == "6" then
        matrixEffect()
    elseif choice == "7" then
        rotatingEffect()
    elseif choice == "8" then
        typewriterEffect()
    elseif choice == "9" then
        runAllEffects()
    end
    
    -- Clear screen before returning to menu
    clearDisplay()
end

-- Clean exit
clearDisplay()
writeToDisplay(math.floor(width/2)-5, math.floor(height/2), "GOODBYE!", colors.green)
sleep(1)

if usingMonitor then
    monitor.clear()
    monitor.setCursorPos(1, 1)
else
    term.clear()
    term.setCursorPos(1, 1)
end

print("Vasya display closed.")
