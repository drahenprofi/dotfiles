-------------------------------------------------
-- CPU Widget for Awesome Window Manager
-- Shows the current CPU utilization
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/cpu-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local widget = {}

-- Checks if a string starts with a another string
local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function worker(args)
    local step_width = 8
    local step_spacing = 1
    local color = beautiful.blue
    local timeout = 1

    local cpugraph_widget = wibox.widget {
        max_value = 100,
        background_color = "#00000000",
        forced_width = 50,
        step_width = step_width,
        step_spacing = step_spacing,
        widget = wibox.widget.graph,
        color = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. color
    }

    --- By default graph widget goes from left to right, so we mirror it and push up a bit
    local cpu_widget = wibox.container.margin(wibox.container.mirror(cpugraph_widget, { horizontal = true }), 0, 0, 0, 2)

    widget = wibox.widget {
        {
            markup = "CPU",
            font = "Fira Mono Bold 12",
            widget = wibox.widget.textbox
        }, 
        cpu_widget, 
        spacing = 8, 
        layout = wibox.layout.fixed.horizontal
    }

    local cpus = {}
    watch([[bash -c "grep '^cpu.' /proc/stat; ps -eo '%p|%c|%C|' -o "%mem" -o '|%a' --sort=-%cpu | head -11 | tail -n +2"]], timeout,
            function(widget, stdout)
                local i = 1
                local j = 1
                for line in stdout:gmatch("[^\r\n]+") do
                    if starts_with(line, 'cpu') then

                        if cpus[i] == nil then cpus[i] = {} end

                        local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
                            line:match('(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)')

                        local total = user + nice + system + idle + iowait + irq + softirq + steal

                        local diff_idle = idle - tonumber(cpus[i]['idle_prev'] == nil and 0 or cpus[i]['idle_prev'])
                        local diff_total = total - tonumber(cpus[i]['total_prev'] == nil and 0 or cpus[i]['total_prev'])
                        local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

                        cpus[i]['total_prev'] = total
                        cpus[i]['idle_prev'] = idle

                        if i == 1 then
                            widget:add_value(diff_usage)
                        end

                        i = i + 1
                    end
                end
            end,
            cpugraph_widget
    )

    return widget
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })
