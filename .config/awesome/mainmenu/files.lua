local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local button = require("mainmenu.button")

local files = wibox.widget {
    {
        button.create_text("HOME", "Roboto Bold 12", function() awful.spawn("thunar /home/parndt") end), 
        button.create_text("UNI", "Roboto Bold 12", function() awful.spawn("thunar /home/parndt/uni") end), 
        button.create_text("DOWNLOADS", "Roboto Bold 12", function() awful.spawn("thunar /home/parndt/data/downloads") end), 
        layout = wibox.layout.align.vertical
    }, 
    widget = wibox.container.background
}

return files