local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local button = require("lib.button")

local poweroff = button.create_text(
    beautiful.fg_normal, 
    beautiful.fg_focus, 
    "襤", 
    "Fira Code NerdFont 28",
    function() awful.spawn("poweroff") end
)
poweroff.forced_width = 32

local logout = button.create_text(
    beautiful.fg_normal, 
    beautiful.fg_focus, 
    "﫼", 
    "Fira Code NerdFont 28",
    function() awesome.quit()  end
)
logout.forced_width = 32

local reboot = button.create_text(
    beautiful.fg_normal, 
    beautiful.fg_focus, 
    "ﰇ", 
    "Fira Code NerdFont 28",
    function() awful.spawn("reboot") end
)
reboot.forced_width = 32

return wibox.widget {
    nil, 
    nil,
    {
        logout, 
        reboot, 
        poweroff,
        spacing = 24,
        layout = wibox.layout.fixed.horizontal
    },
    expand = "none",
    forced_width = 292,
    layout = wibox.layout.align.horizontal
}