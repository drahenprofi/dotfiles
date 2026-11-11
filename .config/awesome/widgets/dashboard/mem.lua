local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local mem_widget = wibox.widget {
    font = "Roboto Medium 12",
    align = "center",
    widget = wibox.widget.textbox
}

local mem_detail = wibox.widget {
    font = "Roboto Medium 9",
    align = "center",
    widget = wibox.widget.textbox
}

local mem_graph = wibox.widget {
    max_value = 1, 
    min_value = 0, 
    step_width = 6,
    step_spacing = 2,
    forced_width = 6*8+2*7,
    forced_height = 48,
    step_shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 2)
    end, 
    color = beautiful.green, 
    background_color = beautiful.bg_light, 
    widget = wibox.widget.graph
}

graph_container = wibox.container.mirror(mem_graph, {horizontal=true, vertical=false})

awesome.connect_signal("evil::mem", function(mem)
    value_str = math.floor(mem.value * 100)
    value_str = value_str .. "%"
    mem_widget.markup = value_str

    mem_detail.markup = mem.text

    mem_graph:add_value(mem.value)
end)

return wibox.widget {
    {
        nil, 
        {
            {
                markup = "<span foreground='"..beautiful.green.."'>MEM</span>",
                font = "Roboto Bold 14",
                align = "center",
                widget = wibox.widget.textbox
            },
            {
                mem_widget, 
                mem_detail, 
                layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.fixed.vertical
        }, 
        expand = "none", 
        layout = wibox.layout.align.vertical
    },
    graph_container, 
    spacing = 8,
    layout = wibox.layout.fixed.horizontal
}