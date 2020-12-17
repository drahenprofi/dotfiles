local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi

local button = require("lib.button")

local create_shortcut = function(c, icon, location)
    local shortcut = button.create_text(beautiful.fg_dark, beautiful.fg_focus, icon, "Fira Mono 24", function()
        --awful.spawn("thunar "..location, false)
        awful.spawn.easy_async_with_shell("xdotool key ctrl+l", function()
            awful.spawn.easy_async_with_shell("xdotool type --delay 0 " .. location, function() 
                awful.spawn.with_shell("xdotool key Return")
            end)
        end)
    end)

    shortcut.forced_width = dpi(32)
    shortcut.forced_height = dpi(32)

    return shortcut
end

local create_thunar_titlebar = function (c)

    awful.titlebar(c, { position = "left", size = dpi(64), bg_normal = beautiful.bg_normal }):setup {
        {
            nil,
            {
                nil,
                {
                    create_shortcut(c, "", "/home/parndt"),
                    create_shortcut(c, "", "trash:///"),
                    create_shortcut(c, "", "/data"),
                    create_shortcut(c, "", "/data/downloads"),
                    create_shortcut(c, "", "/data/documents"),
                    create_shortcut(c, "", "/data/music"),
                    create_shortcut(c, "", "/data/pictures"),
                    create_shortcut(c, "", "/data/uni/BA"),
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
    }
end

-- Add the titlebar whenever a new music client is spawned
table.insert(awful.rules.rules, {
    rule_any = {class={"Thunar"}, instance = {"Thunar"}},
    properties = {},
    callback = create_thunar_titlebar 
})

