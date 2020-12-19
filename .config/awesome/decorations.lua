local awful = require("awful")
local cairo = require("lgi").cairo
local gears = require("gears")
local wibox = require("wibox")
local rad = math.rad
local beautiful = require("beautiful")

local get_titlebar = function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            awful.mouse.client.move(c)
            c:raise()
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )
    
    local left = {
        buttons = buttons,
        layout  = wibox.layout.fixed.horizontal,
    }

    local middle = {
        {
            align = "center",
            font = beautiful.font,
            widget = awful.titlebar.widget.titlewidget(c),
        },
        buttons = buttons,
        layout  = wibox.layout.flex.horizontal,
    }

    local right = {
        layout = wibox.layout.fixed.horizontal,
        {
            widget = wibox.container.margin,
            top = 7,
            bottom = 7,
            left = 0,
            right = 10,
            {
                layout = wibox.layout.fixed.horizontal,
                awful.titlebar.widget.minimizebutton(c)
            }
        },
        {
            widget = wibox.container.place,
            {
                widget = wibox.container.margin,
                top = 7,
                bottom = 7,
                left = 0,
                right = 10,
                {
                    layout = wibox.layout.fixed.horizontal,
                    awful.titlebar.widget.maximizedbutton(c),
                }
            }
        },
        {
            widget = wibox.container.place,
            {
                widget = wibox.container.margin,
                top = 7,
                bottom = 7,
                left = 0,
                right = 10,
                {
                    layout = wibox.layout.fixed.horizontal,
                    awful.titlebar.widget.closebutton(c),
                }
            },
        },
    }


    local titlebar = {
        {
            layout = wibox.layout.align.horizontal,
            left,
            middle,
            right,
        },
        bottom = 1,
        widget = wibox.container.margin,
    }

    return titlebar
end

-- Flips the given surface around the specified axis
local function flip(surface, axis)
    local width = surface:get_width()
    local height = surface:get_height()
    local flipped = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(flipped)
    local source_pattern = cairo.Pattern.create_for_surface(surface)
    if axis == "horizontal" then
        source_pattern.matrix = cairo.Matrix {xx = -1, yy = 1, x0 = width}
    elseif axis == "vertical" then
        source_pattern.matrix = cairo.Matrix {xx = 1, yy = -1, y0 = height}
    elseif axis == "both" then
        source_pattern.matrix = cairo.Matrix {
            xx = -1,
            yy = -1,
            x0 = width,
            y0 = height,
        }
    end
    cr.source = source_pattern
    cr:rectangle(0, 0, width, height)
    cr:paint()

    return flipped
end

local gradient = function(color_1, color_2, height, offset_1, offset_2)
    local fill_pattern = cairo.Pattern.create_linear(0, 0, 0, height)
    local r, g, b, a
    r, g, b, a = gears.color.parse_color(color_1)
    fill_pattern:add_color_stop_rgba(offset_1 or 0, r, g, b, a)
    r, g, b, a = gears.color.parse_color(color_2)
    fill_pattern:add_color_stop_rgba(offset_2 or 1, r, g, b, a)
    return fill_pattern
end

local function create_corner_top_left(args)
    local radius = args.radius
    local height = args.height
    local surface = cairo.ImageSurface.create("ARGB32", radius, height)
    local cr = cairo.Context.create(surface)
    -- Create the corner shape and fill it with a gradient
    local radius_offset = 1 -- To soften the corner
    cr:move_to(0, height)
    cr:line_to(0, radius - radius_offset)
    cr:arc(
        radius + radius_offset, radius + radius_offset, radius, rad(180),
        rad(270))
    cr:line_to(radius, height)
    cr:close_path()
    cr.source = args.background_source
    cr.antialias = cairo.Antialias.BEST
    cr:fill()
    -- Next add the subtle 3D look
    local function add_stroke(nargs)
        local arc_radius = nargs.radius
        local offset_x = nargs.offset_x
        local offset_y = nargs.offset_y
        cr:new_sub_path()
        cr:move_to(offset_x, height)
        cr:line_to(offset_x, arc_radius + offset_y)
        cr:arc(
            arc_radius + offset_x, arc_radius + offset_y, arc_radius, rad(180),
            rad(270))
        cr.source = nargs.source
        cr.line_width = nargs.width
        cr.antialias = cairo.Antialias.BEST
        cr:stroke()
    end
    -- Outer dark stroke
    add_stroke {
        offset_x = args.stroke_offset_outer,
        offset_y = args.stroke_offset_outer,
        radius = radius + 0.5,
        source = args.stroke_source_outer,
        width = args.stroke_width_outer,
    }
    -- Inner light stroke
    add_stroke {
        offset_x = args.stroke_offset_inner,
        offset_y = args.stroke_offset_inner,
        radius = radius,
        width = args.stroke_width_inner,
        source = args.stroke_source_inner,
    }

    return surface
end

local function create_edge_top_middle(args)
    local client_color = args.color
    local height = args.height
    local width = args.width
    local surface = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(surface)
    -- Create the background shape and fill it with a gradient
    cr:rectangle(0, 0, width, height)
    cr.source = args.background_source
    cr:fill()
    -- Then add the light and dark strokes for that 3D look
    local function add_stroke(stroke_width, stroke_offset, stroke_color)
        cr:new_sub_path()
        cr:move_to(0, stroke_offset)
        cr:line_to(width, stroke_offset)
        cr.line_width = stroke_width
        cr:set_source_rgb(gears.color.parse_color(stroke_color))
        cr:stroke()
    end
    -- Inner light stroke
    add_stroke(
        args.stroke_width_inner, args.stroke_offset_inner,
        args.stroke_color_inner)
    -- Outer dark stroke
    add_stroke(
        args.stroke_width_outer, args.stroke_offset_outer,
        args.stroke_color_outer)

    return surface
end

local function create_edge_left(args)
    local height = args.height
    local width = 2
    -- height = height or 1080
    local surface = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(surface)
    cr:rectangle(0, 0, 2, args.height)
    cr:set_source_rgb(gears.color.parse_color(args.client_color))
    cr:fill()
    -- Inner light stroke
    cr:new_sub_path()
    cr:move_to(args.stroke_offset_inner, 0) -- 1/5
    cr:line_to(args.stroke_offset_inner, height)
    cr.line_width = args.stroke_width_inner -- 1.5
    cr:set_source_rgb(gears.color.parse_color(args.inner_stroke_color))
    cr:stroke()
    -- Outer dark stroke
    cr:new_sub_path()
    cr:move_to(args.stroke_offset_outer, 0)
    cr:line_to(args.stroke_offset_outer, height)
    cr.line_width = args.stroke_width_outer -- 1
    cr:set_source_rgb(gears.color.parse_color(args.stroke_color_outer))
    cr:stroke()

    return surface
end

-- Adds a window shade to the given client
local function add_window_shade(c, src_top, src_bottom)
    local geo = c:geometry()
    local w = wibox()
    w.width = geo.width
    w.background = "transparent"
    w.x = geo.x
    w.y = geo.y
    w.height = beautiful.titlebar_height + 3
    w.ontop = true
    w.visible = false
    w.shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end
    -- Need to use a manual layout because layout fixed seems to introduce a thin gap
    src_top.point = {x = 0, y = 0}
    src_top.forced_width = geo.width
    src_bottom.point = {x = 0, y = beautiful.titlebar_height}
    w.widget = {src_top, src_bottom, layout = wibox.layout.manual}
    -- Clean up resources when a client is killed
    c:connect_signal(
        "request::unmanage", function()
            if c._nice_window_shade then
                c._nice_window_shade.visible = false
                c._nice_window_shade = nil
            end
            -- Clean up
            collectgarbage("collect")
        end)
    c._nice_window_shade_up = false
    c._nice_window_shade = w
end

local add_decorations = function(c)
    local background_fill_top = gradient(beautiful.bg_normal, beautiful.bg_normal, beautiful.titlebar_height, 0, 0.5)

    -- The top left corner of the titlebar
    local corner_top_left_img = create_corner_top_left {
        background_source = background_fill_top,
        color = beautiful.bg_very_light,
        height = beautiful.titlebar_height,
        radius = beautiful.border_radius,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_source_inner = gradient(
            beautiful.border_inner, beautiful.border_inner, beautiful.titlebar_height),
        stroke_source_outer = gradient(
            beautiful.border_outer, beautiful.border_outer, beautiful.titlebar_height),
    }
    -- The top right corner of the titlebar
    local corner_top_right_img = flip(corner_top_left_img, "horizontal")

    -- The middle part of the titlebar
    local top_edge = create_edge_top_middle {
        background_source = background_fill_top,
        color = beautiful.bg_normal,
        height = beautiful.titlebar_height,
        stroke_color_inner = beautiful.border_inner,
        stroke_color_outer = beautiful.border_outer,
        stroke_offset_inner = 1.25,
        stroke_offset_outer = 0.5,
        stroke_width_inner = 2,
        stroke_width_outer = 1,
        width = c.screen.geometry.width,
    }

    -- Create the titlebar
    local titlebar = awful.titlebar(
                            c, {size = beautiful.titlebar_height, bg = "transparent"})
    titlebar.widget = {
        wibox.widget.imagebox(corner_top_left_img, false),
        {
            get_titlebar(c),
            bgimage = top_edge,
            widget = wibox.container.background,
        },
        wibox.widget.imagebox(corner_top_right_img, false),
        layout = wibox.layout.align.horizontal,
    }

    local resize_button = {
        awful.button(
            {}, 1, function()
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end),
    }

    -- The left side border
    local left_border_img = create_edge_left {
        client_color = beautiful.bg_normal,
        height = c.screen.geometry.height,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_color_outer = beautiful.border_outer,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1.5,
        inner_stroke_color = beautiful.border_inner,
    }
    -- The right side border
    local right_border_img = flip(left_border_img, "horizontal")
    local left_side_border = awful.titlebar(
                                 c, {
            position = "left",
            size = 2,
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        })
    left_side_border:setup{
        buttons = resize_button,
        bgimage = left_border_img,
        widget = wibox.container.background,
    }

    local right_side_border = awful.titlebar(
                                  c, {
            position = "right",
            size = 2,
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        })
    right_side_border:setup{
        buttons = resize_button,
        bgimage = right_border_img,
        widget = wibox.container.background,
    }

    local corner_bottom_left_img = flip(
                                       create_corner_top_left {
            color = beautiful.bg_normal,
            radius = 3,
            height = 3,
            background_source = background_fill_top,
            stroke_offset_inner = 1.5,
            stroke_offset_outer = 0.5,
            stroke_source_outer = gradient(
                beautiful.border_outer, beautiful.border_outer,
                3, 0, 0.25),
            stroke_source_inner = gradient(
                beautiful.border_inner, beautiful.border_inner,
                3),
            stroke_width_inner = 1.5,
            stroke_width_outer = 2,
        }, "vertical")
    local corner_bottom_right_img = flip(
                                        corner_bottom_left_img, "horizontal")
    local bottom_edge = flip(
                            create_edge_top_middle {
            color = beautiful.bg_very_light,
            height = 3,
            background_source = background_fill_top,
            stroke_color_inner = beautiful.border_inner,
            stroke_color_outer = beautiful.border_outer,
            stroke_offset_inner = 1.25,
            stroke_offset_outer = 0.5,
            stroke_width_inner = 1,
            stroke_width_outer = 1,
            width = c.screen.geometry.width,
        }, "vertical")
    local bottom = awful.titlebar(
                       c, {
            size = 3,
            bg = "transparent",
            position = "bottom",
        })
    bottom.widget = wibox.widget {
        wibox.widget.imagebox(corner_bottom_left_img, false),
        wibox.widget.imagebox(bottom_edge, false),
        wibox.widget.imagebox(corner_bottom_right_img, false),
        buttons = resize_button,
        layout = wibox.layout.align.horizontal,
    }

    add_window_shade(c, titlebar.widget, bottom.widget)
end

client.connect_signal("request::titlebars", function(c)
    add_decorations(c)

    --c:connect_signal("request::activate", add_decorations)
end)