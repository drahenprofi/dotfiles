local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi

local button = require("lib.button")

local create_shortcut = function(c, icon, location)
    local shortcut = button.create_text(beautiful.fg_normal .. "E6", beautiful.red, icon, "FiraMono Nerd Font 12", function()
        awful.spawn.with_shell("xdotool key ctrl+l; xdotool type --delay 0 "..location.."; xdotool key Return;")
    end)

    shortcut.forced_width = dpi(32)
    shortcut.forced_height = dpi(32)

    return shortcut
end

local get_widget = function(c)

    return wibox.widget {
        {
            {
                nil,
                {
                    nil,
                    {
                        create_shortcut(c, "", "/home/parndt"),
                        create_shortcut(c, "", "trash:///"),
                        create_shortcut(c, "", "/data"),
                        {
                            -- separator
                            bg = beautiful.red,
                            forced_height = dpi(1), 
                            widget = wibox.container.background
                        }, 
                        create_shortcut(c, "", "/data/downloads"),
                        create_shortcut(c, "", "/data/documents"),
                        create_shortcut(c, "", "/data/pictures"),
                        create_shortcut(c, "ﱘ", "/data/music"),
                        create_shortcut(c, "", "/data/uni"),
                        spacing = dpi(10),
                        layout = wibox.layout.fixed.vertical
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                expand = "none", 
                layout = wibox.layout.align.vertical
            }, 
            bg = beautiful.bg_light,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false, true, false, false, dpi(50))
            end,
            widget = wibox.container.background, 
        }, 
        left = dpi(2),
        widget = wibox.container.margin
    }
end

return get_widget