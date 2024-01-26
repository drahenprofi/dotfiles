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

    for i, suggestion in ipairs(suggestions) do
        local icon = Gio.AppInfo.get_icon(suggestion)
        local icon_theme = gtk.IconTheme.get_default()
        gtk.IconTheme.lookup_by_gicon(icon_theme, icon, 48, {})--:get_filename()


        --require("naughty").notify{text=test}

        layout:add(wibox.widget {
            {
                --image = ,
                widget = wibox.widget.imagebox
            }, 
            {
                markup = Gio.AppInfo.get_name(suggestion),
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
        Gio.AppInfo.launch(suggestions[1])
    end
end

return layout