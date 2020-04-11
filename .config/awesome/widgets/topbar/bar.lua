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
local layoutbox = require("widgets.topbar.widgets.layoutbox")
local battery = require("widgets.topbar.widgets.battery")
local taglist = require("widgets.topbar.widgets.taglist")
local calendar = require("widgets.topbar.widgets.calendar")
local session = require("widgets.topbar.widgets.session")
local notification = require("widgets.topbar.widgets.notification")
local volume = require("widgets.topbar.widgets.volume")

local rofi_launcher = button.create_image_onclick(beautiful.search_grey_icon, beautiful.search_icon, function()
    awful.spawn("/home/parndt/.config/rofi/launch.sh")
end)

beautiful.systray_icon_spacing = 6
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

    local battery_image, battery_text = battery.get()
    local bar_taglist = taglist.init(s)
    calendar.init(s)


    s.topbar:setup {
        layout = wibox.layout.align.horizontal, 
        spacing = 10,
        expand = "none",
        {   -- Left
            widget(session), 
            {

                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4,
                right = 4,
                {
                    widget = wibox.container.background,
                    bg = beautiful.misc2, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, beautiful.bar_item_radius)
                    end,
                    {
                        widget = wibox.container.margin,
                        top = 2, 
                        bottom = 2,
                        left = 6,
                        right = 6,
                        {
                            bar_taglist,
                            layout = wibox.layout.fixed.horizontal, 
                        }
                    }
                }
            },
            layout = wibox.layout.fixed.horizontal, 
        }, 
        {       
            layout = wibox.layout.fixed.horizontal, 
        },
        {   -- Right 
            widget(volume), 
            widget(wibox.widget {
                battery_image, 
                battery_text, 
                spacing = 2, 
                layout = wibox.layout.fixed.horizontal
            }), 
            {
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4, 
                right = 4, 
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_normal, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, beautiful.bar_item_radius)
                    end,
                    {
                        widget = wibox.container.margin,
                        top = 3, 
                        bottom = 3,
                        left = 7, 
                        right = 7, 
                        {
                            systray, 
                            layout = wibox.layout.fixed.horizontal, 
                        }
                    }
                }
            },
            widget(calendar.clock), 
            widget(rofi_launcher), 
            widget(layoutbox),
            widget(notification),
            layout = wibox.layout.fixed.horizontal, 
        }
    }
end)