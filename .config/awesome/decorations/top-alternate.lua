--[[
    
Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project 
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore 
is also licensed under the terms of the MIT License

]]--

local awful = require("awful")
local wibox = require("wibox")

local shapes = require("lib.shapes")

local edge_height = 3

local set_titlebar = function(c, corner_left_img, edge, corner_right_img)
    awful.titlebar(c, {
        size = edge_height,
        bg = "transparent",
        position = "top",
    }):setup {
        wibox.widget.imagebox(corner_left_img, false),
        wibox.widget.imagebox(edge, false),
        wibox.widget.imagebox(corner_right_img, false),
        layout = wibox.layout.align.horizontal,
    }
end

local top = function(c, args)
    local corner_left_img = shapes.create_corner_top_left {
        color = args.client_color,
        radius = edge_height,
        height = edge_height,
        background_source = args.background_fill_top,
        stroke_offset_inner = 1.5,
        stroke_offset_outer = 0.5,
        stroke_source_inner = shapes.gradient(
            args.stroke_color_inner_top, args.stroke_color_inner_sides, edge_height),
        stroke_source_outer = shapes.gradient(
            args.stroke_color_outer_top, args.stroke_color_outer_sides, edge_height),
        stroke_width_inner = 1.5,
        stroke_width_outer = 2,
    }

    local corner_right_img = shapes.flip(corner_left_img, "horizontal")

    local edge = shapes.create_edge_top_middle {
        color = args.client_color,
        height = edge_height,
        background_source = args.background_fill_top,
        stroke_color_inner = args.stroke_color_inner_top,
        stroke_color_outer = args.stroke_color_outer_top,
        stroke_offset_inner = 1.25,
        stroke_offset_outer = 0.5,
        stroke_width_inner = 1,
        stroke_width_outer = 1,
        width = c.screen.geometry.width,
    }

    set_titlebar(c, corner_left_img, edge, corner_right_img)
end

return top