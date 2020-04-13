local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local builder = {}

height = 400 
width = 400

local menuWidget = wibox.layout.grid()
menuWidget.spacing = 10
menuWidget.forced_num_rows = 2

local popupWidget = wibox.widget {
    {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = 1,
    },
    {
        menuWidget, 
        margins = 10, 
        widget = wibox.container.margin
    }, 
    layout = wibox.layout.fixed.vertical
}

local popup = awful.popup {
    widget = popupWidget, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end,
    visible = false, 
    ontop = true, 
    forced_width = 0, 
    x = 5, 
    y = awful.screen.focused().geometry.height / 2
}

popup:connect_signal("button::press", function() popup.visible = false end)

local buildEntry = function(l)
    local entry = wibox.widget {
        {
            {
                font = "Roboto Bold 12",
                markup = l[1], 
                widget = wibox.widget.textbox
            },
            {
                font = "Roboto Bold 12",
                markup = l[2], 
                widget = wibox.widget.textbox
            },
            spacing = 10, 
            layout = wibox.layout.fixed.vertical
        }, 
        bg = beautiful.bg_light, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        widget = wibox.container.background
    }

    entry:connect_signal("button::press", function() 
        awful.spawn(l[2])
        popup.visible = false
    end)

    return entry
end

builder.buildPopup = function(menu)
    menuWidget:reset(menuWidget)
    popup.visible = true


    for _, l in pairs(menu) do
        menuWidget:add(buildEntry(l))
    end

    return popup
end

return builder