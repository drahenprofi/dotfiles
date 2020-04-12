local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local button = require("components.button")

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

local markupSelected = function(tag) return "<span foreground='#ffffff'>  "..tag.name.."  </span>" end
local markupNormal = function(tag) return "<span foreground='#aaaaaa'>  "..tag.name.."  </span>" end

local update_icon = function(item, tag, index)
    item.visible = true 

    if tag.selected then
        item.markup = markupSelected(tag)
    elseif #tag:clients() > 0 then
        item.markup = markupNormal(tag)
    else
        item.visible = false
    end
end
 
taglist.init = function(s)
    local taglist = awful.widget.taglist {
        screen = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons, 
        widget_template = {
            {
                { 
                    font = "Roboto Bold 10",
                    id = "text_tag",
                    fg = "#000000",
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.margin
            },

            id     = 'background_role',
            widget = wibox.container.background,
            create_callback = function(item, tag, index, _)
                local textbox = item:get_children_by_id('text_tag')[1]
                update_icon(textbox, tag, index)

                item:connect_signal("mouse::enter", function() 
                    if textbox.markup ~= markupSelected(tag) then
                        item.backup = textbox.markup
                        item.hasBackup = true
                    else
                        item.hasBackup = false
                    end

                    textbox.markup = markupSelected(tag)
                end)

                item:connect_signal("mouse::leave", function()
                    if item.hasBackup and not tag.selected then textbox.markup = item.backup end
                end)

            end,
            update_callback = function(item, tag, index, _)
                update_icon(item:get_children_by_id('text_tag')[1], tag, index)
            end,
        },
    }

    local container = wibox.widget {
        taglist, 
        button.create_image_onclick(beautiful.add_grey_icon, beautiful.add_icon, function() 
            for _, tag in pairs(root.tags()) do
                if #tag:clients() == 0 then
                   tag:view_only()
                   break 
                end
            end
        end),
        spacing = 2, 
        layout = wibox.layout.fixed.horizontal
    }

    return container
end


return taglist