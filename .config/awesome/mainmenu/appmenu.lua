local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("mainmenu.button")

local firefox = button.create(42, 42, beautiful.firefox_icon, function() awful.spawn("firefox") end)
local spotify = button.create(42, 42, beautiful.spotify_icon, function() awful.spawn("spotify") end)
local intellij = button.create(42, 42, beautiful.intellij_icon, function() awful.spawn("intellij-idea-ultimate-edition") end)

local appmenu = wibox.widget {
    {
        {
            firefox,
            layout = wibox.layout.align.horizontal
        },
        bottom = dpi(10),
        widget = wibox.container.margin,
    }, 
    {
        {
            spotify, 
            layout = wibox.layout.align.horizontal
        },
        bottom = dpi(10),
        widget = wibox.container.margin,
    }, 
    {
        intellij, 
        layout = wibox.layout.align.horizontal
    }, 
    layout = wibox.layout.align.vertical
}

return appmenu