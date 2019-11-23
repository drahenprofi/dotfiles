local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local taglist = {}

local update_icon = function(item, tag, index)
    item.visible = true 

    if tag.selected then
        item.image = beautiful.tag_active_icon
    elseif tag.urgent then
        item.image = beautiful.tag_active_icon
    elseif #tag:clients() > 0 then
        item.image = beautiful.tag_inactive_icon
    else
        item.visible = false
    end
end
 
taglist.init = function(s)
    s.taglist = awful.widget.taglist {
        screen = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons, 
        widget_template = {
            {
                { 
                    widget = wibox.container.background,
                    bg = beautiful.misc2,
                    { 
                        id = "img_tag",
                        widget = wibox.widget.imagebox,
                    }
                },
                --forced_num_rows = 2,
                --forced_num_cols = 5,
                --forced_heigth = 128,
                --forced_width = 128,
                layout = wibox.layout.fixed.horizontal
            },

            id     = 'background_role',
            widget = wibox.container.background,
            create_callback = function(item, tag, index, _)
                update_icon(item:get_children_by_id('img_tag')[1], tag, index)
            end,
            update_callback = function(item, tag, index, _)
                update_icon(item:get_children_by_id('img_tag')[1], tag, index)
            end,
        },
    }

    return s.taglist
end


return taglist