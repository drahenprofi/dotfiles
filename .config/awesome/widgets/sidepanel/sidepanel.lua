local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local avatar = require("widgets.sidepanel.widgets.avatar")
local volume = require("widgets.sidepanel.widgets.volume")
local ram = require("widgets.sidepanel.widgets.ram")
local series = require("widgets.sidepanel.widgets.series")
local logout = require("widgets.sidepanel.widgets.logout")
local settings = require("widgets.sidepanel.widgets.settings")

local spotify = require("widgets.sidepanel.widgets.spotify")
spotify.visible = false

local width = 400

local panel = {}

awful.screen.connect_for_each_screen(function(s)
    panel = wibox {
        screen = s,
        x = awful.screen.focused().geometry.width - width, 
        y = beautiful.bar_height, 
        width = width, 
        height = awful.screen.focused().geometry.height - beautiful.bar_height, 
        ontop = true, 
        visible = false, 
        bg = beautiful.bg_normal, 
    }

    panel:setup {
        {
            {
                settings, 
                --avatar, 
                --ram(), 
                layout = wibox.layout.align.vertical
            },
            {
                {
                    spotify, 
                    volume(), 
                    layout = wibox.layout.align.vertical
                },
                left = 50, 
                right = 50, 
                widget = wibox.layout.margin
            },
            {
                series,
                logout, 
                layout = wibox.layout.align.vertical
            },
            expand = "none", 
            layout = wibox.layout.align.vertical
        }, 
        bottom = 30, 
        top = 30, 
        left = 30, 
        right = 30, 
        widget = wibox.container.margin
    }

    s.sidepanel = panel
end)

panel.toggle = function()
    panel.visible = not panel.visible

    awesome.emit_signal("sidepanel::visible", panel.visible)

    if panel.visible then
        spotify.update_widget(function()
          spotify.visible = spotify.playing
        end)
      end
end

return panel