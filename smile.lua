-- smiley_monitor.lua
local mon = peripheral.find("monitor")

if not mon then
    print("No monitor connected!")
    print("Place a monitor next to the computer")
    return
end

-- Set up monitor
mon.setTextScale(2)  -- Make text bigger
mon.setBackgroundColor(colors.black)
mon.setTextColor(colors.yellow)
mon.clear()

-- Get monitor size
local width, height = mon.getSize()

-- Calculate center position
local centerX = math.floor(width / 2)
local centerY = math.floor(height / 2)

-- Draw smiley face in center
mon.setCursorPos(centerX - 4, centerY - 3)
mon.write("  *******  ")
mon.setCursorPos(centerX - 4, centerY - 2)
mon.write(" *       * ")
mon.setCursorPos(centerX - 4, centerY - 1)
mon.write("*  O   O  *")
mon.setCursorPos(centerX - 4, centerY)
mon.write("*         *")
mon.setCursorPos(centerX - 4, centerY + 1)
mon.write("*   ___   *")
mon.setCursorPos(centerX - 4, centerY + 2)
mon.write(" * \\___/ * ")
mon.setCursorPos(centerX - 4, centerY + 3)
mon.write("  *******  ")

-- Add text below
mon.setTextColor(colors.white)
mon.setCursorPos(centerX - 5, centerY + 5)
mon.write("Have a nice day! :)")

print("Smiley displayed on monitor!")
