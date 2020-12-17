-- global core api used:
    -- client

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local getTitlebar = function(args)
    local c = args.client
    local buttons = args.buttons
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
        widget = wibox.container.margin,
        bottom = 1,
        {
            layout = wibox.layout.align.horizontal,
            left,
            middle,
            right,
        }
    }

    return titlebar
end

local getTitlebarNormal = function(args)
    local titlebar = {
        {
            widget = wibox.widget.separator,
            color  = '#b8d2f82a',
            forced_height = 1,
        },
        getTitlebar(args), 
        layout = wibox.layout.fixed.vertical
    }

    return titlebar
end

local getTitlebarMaximized = function(args) return getTitlebar(args) end

local drawTitlebar = function(c)
    -- buttons for the titlebar
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

    local top_titlebar = awful.titlebar(c, {
        size = beautiful.titlebar_height,
        font = beautiful.font,
        bg_normal = beautiful.titlebar_bg_normal,
        bg_urgent = beautiful.titlebar_bg_urgent,
        fg_normal = beautiful.titlebar_fg_normal,
        fg_urgent = beautiful.titlebar_fg_urgent,
    })

    if c.maximized then
        top_titlebar:setup(
            getTitlebarMaximized({
                client = c,
                buttons = buttons,
            })
        )
    else
        top_titlebar:setup(
            getTitlebarNormal({
                client = c,
                buttons = buttons,
            })
        )
    end
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    c.draw_titlebar = true
    drawTitlebar(c)
end)

client.connect_signal("property::maximized", function(c)
    if c.draw_titlebar then 
        drawTitlebar(c) 
    end
end)