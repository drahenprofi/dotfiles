local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

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
local battery = require("widgets.topbar.widgets.battery")
local taglist = require("widgets.topbar.widgets.taglist")
local calendar = require("widgets.topbar.widgets.calendar")
local session = require("widgets.topbar.widgets.session")
--local volume = require("widgets.topbar.widgets.volume")
local workspaces = require("widgets.topbar.widgets.workspaces") 
local spotify = require("widgets.topbar.widgets.spotify")

local rofi_launcher = button.create_image_onclick(beautiful.search_grey_icon, beautiful.search_icon, function()
    awful.spawn("/home/parndt/.config/rofi/launch.sh")
end)

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
            --widget(workspaces),
            widget(bar_taglist),
            layout = wibox.layout.fixed.horizontal, 
        }, 
        {   -- Middle
            widget(spotify()),
            layout = wibox.layout.fixed.horizontal, 
        },
        {   -- Right 
            widget(battery()), 
            widget(wibox.widget {
                widget = wibox.container.margin,
                top = 1, 
                bottom = 1, 
                {
                    systray, 
                    layout = wibox.layout.fixed.horizontal, 
                }
            }),
            --widget(volume),
            widget(calendar), 
            widget(rofi_launcher), 
            layout = wibox.layout.fixed.horizontal, 
        }
    }
end)