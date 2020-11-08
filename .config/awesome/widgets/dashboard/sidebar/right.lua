local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apps = require("config.apps")
local sidebarbox = require("widgets.dashboard.sidebar.sidebarbox")

local poweroff = sidebarbox(beautiful.fg_normal, beautiful.fg_focus, "襤", "poweroff")
local reboot = sidebarbox(beautiful.fg_normal, beautiful.fg_focus, "ﰇ", "reboot")
local logout = sidebarbox(beautiful.fg_normal, beautiful.fg_focus, "﫼", awesome.quit)

return wibox.widget {
    {
        nil, 
        {
            nil, 
            {
                poweroff,
                reboot, 
                logout,
                spacing = dpi(8),
                layout = wibox.layout.fixed.vertical
            }, 
            nil,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        nil, 
        expand = "none", 
        layout = wibox.layout.align.horizontal
    }, 
    forced_width = dpi(64),
    widget = wibox.container.background, 
}