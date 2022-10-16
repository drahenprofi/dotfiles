--[[
    
Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project 
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore 
is also licensed under the terms of the MIT License

]]--

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local get_titlebar = require("decorations.titlebar")
local shapes = require("lib.shapes")

local titlebar

local get_titlebar = function(c, height, corner_top_left_img, top_edge, corner_top_right_img)
    titlebar = awful.titlebar(c, {
        size = height, 
        bg = "transparent"
    })
    
    titlebar:setup {
        wibox.widget.imagebox(corner_top_left_img, false),
        {    
            get_titlebar(c),
            bgimage = top_edge,
            widget = wibox.container.background,
        },
        wibox.widget.imagebox(corner_top_right_img, false),
        layout = wibox.layout.align.horizontal,
    }
end

local top = function(c, args)

    local titlebar_height = beautiful.titlebar_height

    -- The top left corner of the titlebar
    local corner_top_left_img = shapes.create_corner_top_left {
        background_source = args.background_fill_top,
        color = args.client_color,
        height = titlebar_height,
        radius = beautiful.border_radius,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_source_inner = shapes.gradient(
            args.stroke_color_inner_top, args.stroke_color_inner_sides, titlebar_height),
        stroke_source_outer = shapes.gradient(
            args.stroke_color_outer_top, args.stroke_color_outer_sides, titlebar_height),
    }
    -- The top right corner of the titlebar
    local corner_top_right_img = shapes.flip(corner_top_left_img, "horizontal")

    -- The middle part of the titlebar
    local top_edge = shapes.create_edge_top_middle {
        background_source = args.background_fill_top,
        color = args.client_color,
        height = titlebar_height,
        stroke_color_inner = args.stroke_color_inner_top,
        stroke_color_outer = args.stroke_color_outer_top,
        stroke_offset_inner = 1.25,
        stroke_offset_outer = 0.5,
        stroke_width_inner = 2,
        stroke_width_outer = 1,
        width = c.screen.geometry.width,
    }
    
    get_titlebar(c, titlebar_height, corner_top_left_img, top_edge, corner_top_right_img)
end

return top