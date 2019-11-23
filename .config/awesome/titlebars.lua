-- global core api used:
    -- client

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")
local titlebars = {}

local naughty = require("naughty")

function titlebars.normal_tbar( args )
    local c = args.client
    local buttons = args.buttons
    local left = {
        -- awful.titlebar.widget.iconwidget(c),
        buttons = buttons,
        layout  = wibox.layout.fixed.horizontal,
    }

    local middle = {
        {
            align = "center",
            font = beautiful.font,
            widget = awful.titlebar.widget.titlewidget(c),
        },
        buttons = buttons,
        layout  = wibox.layout.flex.horizontal,
    }

    local right = {
        -- awful.titlebar.widget.floatingbutton (c),
        -- awful.titlebar.widget.stickybutton   (c),
        -- awful.titlebar.widget.ontopbutton    (c),
        layout = wibox.layout.fixed.horizontal,
        {
            widget = wibox.container.margin,
            top = 7,
            bottom = 7,
            left = 0,
            right = 10,
            {
                layout = wibox.layout.fixed.horizontal,
                awful.titlebar.widget.minimizebutton(c)
            }
        },
        {
            widget = wibox.container.place,
            {
                widget = wibox.container.margin,
                top = 7,
                bottom = 7,
                left = 0,
                right = 10,
                {
                    layout = wibox.layout.fixed.horizontal,
                    awful.titlebar.widget.maximizedbutton(c),
                }
            }
        },
        {
            widget = wibox.container.place,
            {
                widget = wibox.container.margin,
                top = 7,
                bottom = 7,
                left = 0,
                right = 10,
                {
                    layout = wibox.layout.fixed.horizontal,
                    awful.titlebar.widget.closebutton(c),
                }
            },
        },
    }

    local titlebar = {
        layout = wibox.layout.fixed.vertical,
        {
            widget = wibox.widget.separator,
            color  = '#b8d2f82a',
            forced_height = 1,
        },
        {
            widget = wibox.container.margin,
            bottom = 1,
            {
                layout = wibox.layout.align.horizontal,
                left,
                middle,
                right,
            },
        },
    }
    return titlebar
end

return titlebars
