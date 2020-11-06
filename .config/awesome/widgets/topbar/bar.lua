local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local apps = require("config.apps")

local color_solid = beautiful.bg_normal 

local button = require("components.button")

local widget = function(inner_widget)
    return wibox.widget {
        widget = wibox.container.margin,
        top = beautiful.bar_item_padding + 2, 
        bottom = beautiful.bar_item_padding + 2,
        left = 6,
        right = 6,
        {
            inner_widget,
            layout = wibox.layout.fixed.horizontal
        }
    }
end

-- Init widgets
------------------------------------------------
local session = require("widgets.topbar.session")
local taglist = require("widgets.topbar.taglist")
local battery = require("widgets.topbar.battery")
local clock = require("widgets.topbar.clock")
local spotify = require("widgets.topbar.spotify")
local launcher = require("widgets.topbar.launcher")

beautiful.systray_icon_spacing = 12
local systray = wibox.widget.systray()

------------------------------------------------
-- setup
------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    s.topbar = awful.wibar({
        screen = s,
        position = beautiful.bar_position, 
        height = beautiful.bar_height, 
        type = "dock",
        bg = color_solid,
    })

    local bar_taglist = taglist.init(s)

    s.topbar:setup {
        layout = wibox.layout.align.horizontal, 
        spacing = 10,
        expand = "none",
        {   -- Left
            widget(session), 
            widget(bar_taglist),
            layout = wibox.layout.fixed.horizontal, 
        }, 
        {   -- Middle
            widget(spotify()),
            layout = wibox.layout.fixed.horizontal, 
        },
        {   -- Right 
            widget(battery), 
            widget(wibox.widget {
                widget = wibox.container.margin,
                top = 1, 
                bottom = 1, 
                {
                    systray, 
                    layout = wibox.layout.fixed.horizontal, 
                }
            }),
            widget(clock), 
            widget(launcher), 
            layout = wibox.layout.fixed.horizontal, 
        }
    }
end)