--[[
    
Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project 
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore 
is also licensed under the terms of the MIT License

]]--

local awful = require("awful")
local wibox = require("wibox")

local shapes = require("lib.shapes")

local bottom_edge_height = 3

local set_titlebar = function(c, corner_bottom_left_img, bottom_edge, corner_bottom_right_img)
    awful.titlebar(c, {
        size = bottom_edge_height,
        bg = "transparent",
        position = "bottom",
    }):setup {
        wibox.widget.imagebox(corner_bottom_left_img, false),
        wibox.widget.imagebox(bottom_edge, false),
        wibox.widget.imagebox(corner_bottom_right_img, false),
        layout = wibox.layout.align.horizontal,
    }
end

local bottom = function(c, args)
    local corner_bottom_left_img = shapes.flip(
        shapes.create_corner_top_left {
            color = args.client_color,
            radius = bottom_edge_height,
            height = bottom_edge_height,
            background_source = args.background_fill_top,
            stroke_offset_inner = 1.5,
            stroke_offset_outer = 0.5,
            stroke_source_outer = shapes.gradient(
                args.stroke_color_outer_bottom, args.stroke_color_outer_sides,
                bottom_edge_height, 0, 0.25),
            stroke_source_inner = shapes.gradient(
                args.stroke_color_inner_bottom, args.stroke_color_inner_sides,
                bottom_edge_height),
            stroke_width_inner = 1.5,
            stroke_width_outer = 2,
        }, "vertical")

    local corner_bottom_right_img = shapes.flip(corner_bottom_left_img, "horizontal")

    local bottom_edge = shapes.flip(shapes.create_edge_top_middle {
            color = args.client_color,
            height = bottom_edge_height,
            background_source = args.background_fill_top,
            stroke_color_inner = args.stroke_color_inner_bottom,
            stroke_color_outer = args.stroke_color_outer_bottom,
            stroke_offset_inner = 1.25,
            stroke_offset_outer = 0.5,
            stroke_width_inner = 1,
            stroke_width_outer = 1,
            width = c.screen.geometry.width,
        }, "vertical")

    set_titlebar(c, corner_bottom_left_img, bottom_edge, corner_bottom_right_img)
end

return bottom