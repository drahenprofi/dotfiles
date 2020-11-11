local wibox = require("wibox")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apps = require("config.apps")
local sidebarbox = require("widgets.dashboard.sidebar.sidebarbox-app")

local browser = sidebarbox(beautiful.yellow, beautiful.yellow_light, "", apps.browser)
local fileexplorer = sidebarbox(beautiful.blue, beautiful.blue_light, "", apps.fileexplorer)
local terminal = sidebarbox(beautiful.fg_normal, beautiful.fg_focus, "", apps.terminal)
local intellij = sidebarbox(beautiful.red, beautiful.red_light, "", "intellij-idea-ultimate-edition")
local gimp = sidebarbox(beautiful.cyan, beautiful.cyan_light, "", "gimp")
local spotify = sidebarbox(beautiful.green, beautiful.green_light, "", "spotify")

return wibox.widget {
    {
        nil, 
        {
            nil, 
            {
                browser, 
                fileexplorer, 
                terminal, 
                intellij, 
                gimp,
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
    widget = wibox.container.background, 
}