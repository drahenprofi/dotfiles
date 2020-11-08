local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apps = require("config.apps")
local sidebarbox = require("widgets.dashboard.sidebar.sidebarbox")

local browser = sidebarbox(beautiful.yellow, beautiful.yellow_light, "", apps.browser)
local terminal = sidebarbox(beautiful.fg_normal, beautiful.fg_focus, "", apps.terminal)
local fileexplorer = sidebarbox(beautiful.blue, beautiful.blue_light, "", apps.fileexplorer)
local intellij = sidebarbox(beautiful.red, beautiful.red_light, "", "intellij-idea-ultimate-edition")
local spotify = sidebarbox(beautiful.green, beautiful.green_light, "", "spotify")

return wibox.widget {
    {
        nil, 
        {
            nil, 
            {
                browser, 
                terminal, 
                fileexplorer, 
                intellij, 
                spotify,
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