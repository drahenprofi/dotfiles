local awful = require("awful")
local cairo = require("lgi").cairo
local gears = require("gears")
local wibox = require("wibox")
local rad = math.rad
local floor = math.floor
local max = math.max
local beautiful = require("beautiful")

local stroke_inner_bottom_lighten_mul = 0.4
local stroke_inner_sides_lighten_mul = 0.4
local stroke_outer_top_darken_mul = 0.7
local bottom_edge_height = 3

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
            left,
            middle,
            right,
            layout = wibox.layout.align.horizontal,
        },
        --bg = beautiful.bg_normal,
        widget = wibox.container.background,
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

-- Calculates the relative luminance of the given color
local function relative_luminance(color)
    local r, g, b = gears.color.parse_color(color)
    local function from_sRGB(u)
        return u <= 0.0031308 and 25 * u / 323 or
                   math.pow(((200 * u + 11) / 211), 12 / 5)
    end
    return 0.2126 * from_sRGB(r) + 0.7152 * from_sRGB(g) + 0.0722 * from_sRGB(b)
end

local function rel_lighten(lum) return lum * 90 + 10 end
local function rel_darken(lum) return -(lum * 70) + 100 end

-- Lightens a given hex color by the specified amount
local function color_lighten(color, amount)
    local r, g, b
    r, g, b = gears.color.parse_color(color)
    r = 255 * r
    g = 255 * g
    b = 255 * b
    r = r + floor(2.55 * amount)
    g = g + floor(2.55 * amount)
    b = b + floor(2.55 * amount)
    r = r > 255 and 255 or r
    g = g > 255 and 255 or g
    b = b > 255 and 255 or b
    return ("#%02x%02x%02x"):format(r, g, b)
end

-- Darkens a given hex color by the specified amount
local function color_darken(color, amount)
    local r, g, b
    r, g, b = gears.color.parse_color(color)
    r = 255 * r
    g = 255 * g
    b = 255 * b
    r = max(0, r - floor(r * (amount / 100)))
    g = max(0, g - floor(g * (amount / 100)))
    b = max(0, b - floor(b * (amount / 100)))
    return ("#%02x%02x%02x"):format(r, g, b)
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

local add_titlebar_only = function(c)
    awful.titlebar.hide(c)
    local titlebar = awful.titlebar(c, {size = beautiful.titlebar_height, bg = beautiful.bg_normal})
    titlebar.widget = 
        get_titlebar(c)
end

local add_decorations = function(c)
    local client_color = beautiful.bg_normal

    -- Closures to avoid repitition
    local lighten = function(amount)
        return color_lighten(client_color, amount)
    end

    local darken = function(amount) 
        return color_darken(client_color, amount) 
    end

    -- > Color computations
    local luminance = relative_luminance(client_color)
    local lighten_amount = rel_lighten(luminance)
    local darken_amount = rel_darken(luminance)
    -- Inner strokes
    local stroke_color_inner_top = lighten(lighten_amount)
    local stroke_color_inner_sides = lighten(lighten_amount * stroke_inner_sides_lighten_mul)
    local stroke_color_inner_bottom = lighten(lighten_amount * stroke_inner_bottom_lighten_mul)
    -- Outer strokes
    local stroke_color_outer_top = darken(darken_amount * stroke_outer_top_darken_mul)
    local stroke_color_outer_sides = darken(darken_amount)
    local stroke_color_outer_bottom = darken(darken_amount)
    local titlebar_height = beautiful.titlebar_height
    local background_fill_top = gradient(
                                    lighten(1),
                                    client_color, titlebar_height, 0,
                                    0.5)
    -- The top left corner of the titlebar
    local corner_top_left_img = create_corner_top_left {
        background_source = background_fill_top,
        color = client_color,
        height = titlebar_height,
        radius = beautiful.border_radius,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_source_inner = gradient(
            stroke_color_inner_top, stroke_color_inner_sides, titlebar_height),
        stroke_source_outer = gradient(
            stroke_color_outer_top, stroke_color_outer_sides, titlebar_height),
    }
    -- The top right corner of the titlebar
    local corner_top_right_img = flip(corner_top_left_img, "horizontal")

    -- The middle part of the titlebar
    local top_edge = create_edge_top_middle {
        background_source = background_fill_top,
        color = client_color,
        height = titlebar_height,
        stroke_color_inner = stroke_color_inner_top,
        stroke_color_outer = stroke_color_outer_top,
        stroke_offset_inner = 1.25,
        stroke_offset_outer = 0.5,
        stroke_width_inner = 2,
        stroke_width_outer = 1,
        width = c.screen.geometry.width,
    }
    -- Create the titlebar
    local titlebar = awful.titlebar(
                         c, {size = titlebar_height, bg = "transparent"})
    -- Arrange the graphics
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
        awful.widget.button(
            {}, 1, function()
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end),
    }

    -- The left side border
    local left_border_img = create_edge_left {
        client_color = client_color,
        height = c.screen.geometry.height,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_color_outer = stroke_color_outer_sides,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1.5,
        inner_stroke_color = stroke_color_inner_sides,
    }
    -- The right side border
    local right_border_img = flip(left_border_img, "horizontal")
    local left_side_border = awful.titlebar(
                                 c, {
            position = "left",
            size = 2,
            bg = client_color,
            widget = wibox.container.background,
        })
    left_side_border:setup{
        bgimage = left_border_img,
        buttons = resize_button,
        widget = wibox.container.background,
    }
    local right_side_border = awful.titlebar(
                                  c, {
            position = "right",
            size = 2,
            bg = client_color,
            widget = wibox.container.background,
        })
    right_side_border:setup{
        bgimage = right_border_img,
        buttons = resize_button,
        widget = wibox.container.background,
    }
    local corner_bottom_left_img = flip(
                                       create_corner_top_left {
            color = client_color,
            radius = bottom_edge_height,
            height = bottom_edge_height,
            background_source = background_fill_top,
            stroke_offset_inner = 1.5,
            stroke_offset_outer = 0.5,
            stroke_source_outer = gradient(
                stroke_color_outer_bottom, stroke_color_outer_sides,
                bottom_edge_height, 0, 0.25),
            stroke_source_inner = gradient(
                stroke_color_inner_bottom, stroke_color_inner_sides,
                bottom_edge_height),
            stroke_width_inner = 1.5,
            stroke_width_outer = 2,
        }, "vertical")
    local corner_bottom_right_img = flip(
                                        corner_bottom_left_img, "horizontal")
    local bottom_edge = flip(
                            create_edge_top_middle {
            color = client_color,
            height = bottom_edge_height,
            background_source = background_fill_top,
            stroke_color_inner = stroke_color_inner_bottom,
            stroke_color_outer = stroke_color_outer_bottom,
            stroke_offset_inner = 1.25,
            stroke_offset_outer = 0.5,
            stroke_width_inner = 1,
            stroke_width_outer = 1,
            width = c.screen.geometry.width,
        }, "vertical")
    local bottom = awful.titlebar(
                       c, {
            size = bottom_edge_height,
            bg = "transparent",
            position = "bottom",
        })
    bottom.widget = wibox.widget {
        wibox.widget.imagebox(corner_bottom_left_img, false),
        -- {widget = wcontainer_background, bgimage = bottom_edge},
        wibox.widget.imagebox(bottom_edge, false),

        wibox.widget.imagebox(corner_bottom_right_img, false),
        layout = wibox.layout.align.horizontal,
        buttons = resize_button,
    }

    add_window_shade(c, titlebar.widget, bottom.widget)

    --[[if _private.no_titlebar_maximized then
        c:connect_signal(
            "property::maximized", function()
                if c.maximized then
                    local curr_screen_workarea = client.focus.screen.workarea
                    awful.titlebar.hide(c)
                    c.shape = nil
                    c:geometry{
                        x = curr_screen_workarea.x,
                        y = curr_screen_workarea.y,
                        width = curr_screen_workarea.width,
                        height = curr_screen_workarea.height,
                    }
                else
                    awful.titlebar.show(c)
                    -- Shape the client
                    c.shape = shapes.rounded_rect {
                        tl = _private.titlebar_radius,
                        tr = _private.titlebar_radius,
                        bl = 4,
                        br = 4,
                    }
                end
            end)
    end]]--

    -- Clean up
    collectgarbage("collect")

end

client.connect_signal("request::titlebars", function(c)
    if c.maximized then
        add_titlebar_only(c)
    else
        add_decorations(c)
    end
end)

client.connect_signal("property::maxmimized", function(c)
    if c.maximized then
        add_titlebar_only(c)
    else
        add_decorations(c)
    end
end)