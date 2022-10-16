local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local get_titlebar = function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            awful.mouse.client.move(c)
            c:raise()
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )
    
    local left = {
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
        {
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal,
        }, 
        top = dpi(2), bottom = dpi(2), left = dpi(4),
        widget = wibox.container.margin
    }


    local titlebar = {
        {
            left,
            middle,
            right,
            layout = wibox.layout.align.horizontal,
        },
        --bg = beautiful.bg_normal,
        widget = wibox.container.background,
    }

    return titlebar
end

return get_titlebar