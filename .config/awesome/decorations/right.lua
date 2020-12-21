local awful = require("awful")
local wibox = require("wibox")

local shapes = require("decorations.shapes")

local set_titlebar = function(c, right_border_img, client_color)
    awful.titlebar(c, {
        position = "right",
        size = 2,
        bg = client_color,
        widget = wibox.container.background,
    }):setup{
        bgimage = right_border_img,
        widget = wibox.container.background,
    }
end

local left = function(c, client_color, stroke_color_outer_sides, stroke_color_inner_sides)
    local right_border_img = shapes.flip(
        shapes.create_edge_left {
            client_color = client_color,
            height = c.screen.geometry.height,
            stroke_offset_outer = 0.5,
            stroke_width_outer = 1,
            stroke_color_outer = stroke_color_outer_sides,
            stroke_offset_inner = 1.5,
            stroke_width_inner = 1.5,
            inner_stroke_color = stroke_color_inner_sides,
        }, "horizontal")

    set_titlebar(c, right_border_img, client_color)
end

return left