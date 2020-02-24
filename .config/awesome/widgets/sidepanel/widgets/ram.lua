
local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")

local ramgraph_widget = {}

local function worker(args)

    local args = args or {}

    --- Main ram widget shown on wibar
    ramgraph_widget = wibox.widget {
        border_width = 0,
        colors = {
            beautiful.fg_normal, beautiful.highlight_alt
        },
        display_labels = false,
        forced_width = 60,
        forced_height = 60,
        widget = wibox.widget.piechart
    }

    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap

    local function getPercentage(value)
        return math.floor(value / (total+total_swap) * 100 + 0.5) .. '%'
    end

    watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*Swap.*"', 1,
        function(widget, stdout, stderr, exitreason, exitcode)
            total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')

            widget.data = { used, total-used } widget.data = { used, total-used }

            if w.visible then
                w.pie.data_list = {
                    {'used ' .. getPercentage(used + used_swap), used + used_swap},
                    {'free ' .. getPercentage(free + free_swap), free + free_swap},
                    {'buff_cache ' .. getPercentage(buff_cache), buff_cache}
                }
            end
        end,
        ramgraph_widget
    )

    return ramgraph_widget
end

return setmetatable(ramgraph_widget, { __call = function(_, ...)
    return worker(...)
end })