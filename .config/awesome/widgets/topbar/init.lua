local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi

local apps = require("config.apps")

local color_solid = beautiful.bg_normal 

local button = require("lib.button")

local widget = function(inner_widget)
    return wibox.widget {
        widget = wibox.container.margin,
        top = dpi(beautiful.bar_item_padding + 2), 
        bottom = dpi(beautiful.bar_item_padding + 2),
        left = dpi(6),
        right = dpi(6),
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

beautiful.systray_icon_spacing = dpi(12)
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
        spacing = dpi(10),
        expand = "none",
        {   -- Left
            widget(session), 
            bar_taglist,
            spacing = dpi(6),
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
                top = dpi(1), 
                bottom = dpi(1), 
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