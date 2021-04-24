local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local tasklist = {}

tasklist.init = function(s)

    local tasklist_buttons = gears.table.join(
        awful.button({}, 1, function(c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", {raise = true})
            end
        end), awful.button({}, 3, function()
            awful.menu.client_list({theme = {width = 250}})
        end), awful.button({}, 4, function() awful.client.focus.byidx(1) end),
                                awful.button({}, 5, function()
            awful.client.focus.byidx(-1)
        end)
    )

    local widget = awful.widget.tasklist {
        screen = s, 
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            spacing_widget = {
                {
                    forced_height = dpi(20),
                    thickness     = dpi(1),
                    color         = beautiful.fg_dark .. "4D",
                    widget        = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            spacing = 1,
            layout  = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    nil,
                    {
                        awful.widget.clienticon,
                        top = dpi(4), 
                        bottom = dpi(4),
                        left = dpi(6), 
                        right = dpi(6),
                        widget = wibox.container.margin
                    }, 
                    {
                        {
                            bg = beautiful.bg_normal,
                            id = "selected_indicator",
                            widget = wibox.container.background
                        },
                        forced_height = dpi(1),
                        widget = wibox.container.background
                    },
                    layout = wibox.layout.align.vertical
                }, 
                left = dpi(4),
                right = dpi(4),
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background, 
            create_callback = function(self, c, index, objects) --luacheck: no unused
                if c.active then
                    self:get_children_by_id('selected_indicator')[1].bg = beautiful.red
                end
            end,
            update_callback = function(self, c, index, objects) --luacheck: no unused
                if c.active then
                    self:get_children_by_id('selected_indicator')[1].bg = beautiful.red
                else
                    self:get_children_by_id('selected_indicator')[1].bg = beautiful.bg_normal
                end
            end,
        }
    }

    return wibox.widget {
        widget, 
        bg = beautiful.bg_light,
        widget = wibox.container.background
    }
end

return tasklist