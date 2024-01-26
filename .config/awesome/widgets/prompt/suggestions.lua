local wibox = require("wibox")
local lgi = require "lgi"
local Gio = lgi.Gio
local gtk = lgi.require("Gtk", "3.0")

local get_apps = require("widgets.prompt.get_apps")

local layout = wibox.layout.fixed.vertical()
layout.spacing = 8

local suggestions = {}

layout.reset = function()
    for i=1,#layout.children do
        layout:remove(#layout.children)
    end
end

layout.update = function(command)
    suggestions = {}
    
    if command ~= '' then 
        suggestions = get_apps(command)
    end

    layout.reset()

    local icon_theme = gtk.IconTheme.get_default()

    for i, suggestion in ipairs(suggestions) do
        local icon = suggestion:get_icon()
        local themed_icon = icon_theme:lookup_by_gicon(icon, 48, 0)

        local icon = wibox.widget {
            forced_width = 24,
            forced_height = 24,
            widget = wibox.container.background
        }

        if themed_icon ~= nil then 
            icon = wibox.widget {
                image = themed_icon:get_filename(),
                forced_width = 24,
                forced_height = 24,
                widget = wibox.widget.imagebox
            }
        end

        layout:add(wibox.widget {
            icon,
            {
                markup = suggestion:get_name(),
                widget = wibox.widget.textbox
            }, 
            spacing = 8,
            widget = wibox.layout.fixed.horizontal
        })
    end

    return layout
end

layout.run = function()
    if #suggestions > 0 then
        suggestions[1]:launch()
    end
end

return layout