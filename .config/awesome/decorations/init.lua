local beautiful = require("beautiful")

local get_colors = require("lib.border_colors")

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
    local client_color = beautiful.bg_normal

    local args = get_colors(client_color)

    --[[local resize_button = {
        awful.widget.button(
            {}, 1, function()
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end),
    }]]--

    -- https://www.reddit.com/r/awesomewm/comments/ggru8u/custom_rule_properties/
    if c.class == "firefox" or c.class == "Spotify" then
        require("decorations.top-alternate")(c, args)
    else
        require("decorations.top")(c, args)
    end
    require("decorations.left")(c, args)
    require("decorations.right")(c, args)
    require("decorations.bottom")(c, args)

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