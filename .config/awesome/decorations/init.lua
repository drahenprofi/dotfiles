local awful = require("awful")
local cairo = require("lgi").cairo
local gears = require("gears")
local wibox = require("wibox")
local rad = math.rad
local floor = math.floor
local max = math.max
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local stroke_inner_bottom_lighten_mul = 0.4
local stroke_inner_sides_lighten_mul = 0.4
local stroke_outer_top_darken_mul = 0.7
local bottom_edge_height = 3

local get_titlebar = require("decorations.titlebar")

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
    --[[local resize_button = {
        awful.widget.button(
            {}, 1, function()
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end),
    }]]--

    -- https://www.reddit.com/r/awesomewm/comments/ggru8u/custom_rule_properties/
    if c.class == "firefox" or c.class == "Spotify" then
        require("decorations.top-alternate")(c, background_fill_top, client_color, stroke_color_inner_top, stroke_color_outer_top, stroke_color_inner_sides, stroke_color_outer_sides)
    else
        require("decorations.top")(c, background_fill_top, client_color, stroke_color_inner_top, stroke_color_outer_top, stroke_color_inner_sides, stroke_color_outer_sides)
    end
    require("decorations.left")(c, client_color, stroke_color_outer_sides, stroke_color_inner_sides)
    require("decorations.right")(c, client_color, stroke_color_outer_sides, stroke_color_inner_sides)
    require("decorations.bottom")(c, client_color, background_fill_top, stroke_color_outer_bottom, stroke_color_inner_bottom, stroke_color_outer_sides, stroke_color_inner_sides)

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
    add_decorations(c)
end)