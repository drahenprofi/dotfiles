local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local ramWidget = {}

local function worker(args)
    local timeout = 1

    local bar = wibox.widget {
        max_value = 100,
        value = tonumber(60),
        forced_height = 32,
        margins = 4, 
        background_color = beautiful.bg_normal,
        color = beautiful.green,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        widget = wibox.widget.progressbar,
    }

    --- Main ram widget shown on wibar
    ramWidget = wibox.widget {
        {
            markup = "RAM",
            font = "Fira Mono Bold 12",
            widget = wibox.widget.textbox
        }, 
        bar, 
        spacing = 8, 
        layout = wibox.layout.fixed.horizontal
    }

    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap

    watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*Swap.*"', timeout,
        function(widget, stdout, stderr, exitreason, exitcode)
            total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')

            --widget.data = { used, total-used } widget.data = { used, total-used }
            widget:set_value(used / total * 100)
        end,
        bar
    )


    return ramWidget
end

return setmetatable(ramWidget, { __call = function(_, ...)
    return worker(...)
end })
