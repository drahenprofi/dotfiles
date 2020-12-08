local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local button = require("lib.button")

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

local markup = function(tag) return "<span foreground='#aaaaaa'>  "..tag.name.."  </span>" end
local markup_hover = function(tag) return "<span foreground='#ffffff'>  "..tag.name.."  </span>" end

local update_tag = function(item, tag, index)
    item.visible = #tag:clients() > 0 or tag.selected

    local textbox = item:get_children_by_id('text_tag')[1]
    local selected_indicator = item:get_children_by_id('selected_indicator')[1]

    selected_indicator.visible = tag.selected

    if tag.selected then
        textbox.markup = markup_hover(tag)
    else
        textbox.markup = markup(tag)
    end
end
 
taglist.init = function(s)
    local taglist = awful.widget.taglist {
        screen = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons, 
        widget_template = {
            {
                nil,
                { 
                    font = "Roboto Medium 10",
                    id = "text_tag",
                    widget = wibox.widget.textbox,
                },
                {
                    {
                        bg = beautiful.red,
                        id = "selected_indicator",
                        widget = wibox.container.background
                    },
                    forced_height = 1,
                    widget = wibox.container.background
                },
                layout = wibox.layout.align.vertical
            },
            id     = 'background_role',
            widget = wibox.container.background,
            create_callback = function(item, tag, index, _)
                update_tag(item, tag, index)

                local old_cursor, old_wibox
                item:connect_signal("mouse::enter", function() 
                    -- change cursor
                    local wb = mouse.current_wibox
                    old_cursor, old_wibox = wb.cursor, wb
                    wb.cursor = "hand2" 
                end)
                item:connect_signal("mouse::leave", function() 
                    -- reset cursor
                    if old_wibox then
                        old_wibox.cursor = old_cursor
                        old_wibox = nil
                    end
                end)
            end,
            update_callback = update_tag
        },
    }

    local container = wibox.widget {
        taglist, 
        button.create_text(beautiful.fg_dark, beautiful.fg_normal, "", "Fira Mono 12", function() 
            for _, tag in pairs(root.tags()) do
                if #tag:clients() == 0 then
                tag:view_only()
                break 
                end
            end
        end),
        spacing = 6, 
        layout = wibox.layout.fixed.horizontal
    }

    return container
end


return taglist