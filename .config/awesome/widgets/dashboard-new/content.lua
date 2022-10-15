local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local avatar = require("widgets.dashboard-new.avatar")
local session = require("widgets.dashboard-new.session")
local config = require("widgets.dashboard-new.config")
local playerctl = require("widgets.dashboard-new.playerctl")
local sliders = require("widgets.dashboard-new.sliders")
local storage = require("widgets.dashboard-new.storage")
local calendar = require("widgets.dashboard-new.calendar")
local weather = require("widgets.dashboard-new.weather")

local apply_background = function(widget) 
    return wibox.widget {
        {
            {
                widget, 
                margins = dpi(8),
                widget = wibox.container.margin
            },
            bg = beautiful.bg_light,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, dpi(8))
            end,
            widget = wibox.container.background
        }, 
        margins = dpi(8),
        widget = wibox.container.margin
    }
end

return wibox.widget {
    {
        {
            {
                {
                    avatar, 
                    margins = dpi(16),
                    widget = wibox.container.margin
                },
                session,
                layout = wibox.layout.fixed.horizontal
            },
            {
                playerctl,
                apply_background(sliders),
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.fixed.vertical
        },
        apply_background(storage), 
        {
            apply_background(calendar),
            apply_background({
                nil,
                weather,
                nil,
                expand = "none",
                layout = wibox.layout.align.horizontal
            }),
            forced_height = dpi(250),
            fill_space = true,
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.fixed.vertical
    }, 
    margins = dpi(8),
    widget = wibox.container.margin
}