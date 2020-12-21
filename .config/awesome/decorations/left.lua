local awful = require("awful")
local wibox = require("wibox")

local shapes = require("decorations.shapes")

local set_left_titlebar = function(c, left_border_img, client_color)
    awful.titlebar(c, {
        position = "left",
        size = 2,
        bg = client_color,
        widget = wibox.container.background,
    }):setup{
        bgimage = left_border_img,
        widget = wibox.container.background,
    }
end

local set_thunar_left_titlebar = function(c, left_border_img)
    local custom_titlebar = require("decorations.thunar")(c)

    awful.titlebar(c, {
        position = "left",
        size = 48,
        bg = transparent,
        widget = wibox.container.background,
    }):setup{
        custom_titlebar,
        bgimage = left_border_img,
        widget = wibox.container.background,
    }
end

local left = function(c, client_color, stroke_color_outer_sides, stroke_color_inner_sides)
    -- The left side border
    local left_border_img = shapes.create_edge_left {
        client_color = client_color,
        height = c.screen.geometry.height,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_color_outer = stroke_color_outer_sides,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1.5,
        inner_stroke_color = stroke_color_inner_sides,
    }

    if c.class == "Thunar" and c.type == "normal" then
        set_thunar_left_titlebar(c, left_border_img)
    else
        set_left_titlebar(c, left_border_img, client_color)
    end
end

return left