local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local cpu_widget = wibox.widget {
    font = "Roboto Medium 12",
    align = "center",
    widget = wibox.widget.textbox
}

local cpu_graph = wibox.widget {
    max_value = 100, 
    min_value = 0, 
    step_width = 6,
    step_spacing = 2,
    forced_width = 6*8+2*7,
    forced_height = 48,
    step_shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 2)
    end, 
    color = beautiful.highlight, 
    background_color = beautiful.bg_light, 
    widget = wibox.widget.graph
}

graph_container = wibox.container.mirror(cpu_graph, {horizontal=true, vertical=false})

awesome.connect_signal("evil::cpu", function(cpu)
    value_str = string.format("%.1f", cpu.value)

    cpu_widget.markup = value_str.."%"
    cpu_graph:add_value(cpu.value)
end)

return wibox.widget {
    {
        nil, 
        {
            {
                markup = "<span foreground='"..beautiful.highlight.."'>CPU</span>",
                font = "Roboto Bold 14",
                align = "center",
                widget = wibox.widget.textbox
            },
            cpu_widget, 
            layout = wibox.layout.fixed.vertical
        },
        expand = "none", 
        layout = wibox.layout.align.vertical
    }, 
    graph_container, 
    spacing = 8,
    layout = wibox.layout.fixed.horizontal
}