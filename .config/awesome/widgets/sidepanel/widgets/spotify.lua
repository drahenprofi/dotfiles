local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local artwork_path = "/home/parndt/.config/awesome/.cache/artwork"

local button = require("components.button")
---------------------------
-- Spotify commands
---------------------------

local spotify_commands = {}
spotify_commands.status = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|egrep -A 1 \"string\"|cut -b 26-|cut -d '\"' -f 1|egrep -v ^$"
spotify_commands.toggle = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
spotify_commands.prev = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
spotify_commands.next = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
spotify_commands.song = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 \"title\"|egrep -v \"title\"|cut -b 44-|cut -d '\"' -f 1|egrep -v ^$"
spotify_commands.album = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 \"album\"|egrep -v \"album\"|cut -b 44-|cut -d '\"' -f 1|egrep -v ^$"
spotify_commands.artist = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 2 \"artist\"|egrep -v \"artist\"|egrep -v \"array\"|cut -b 27-|cut -d '\"' -f 1|egrep -v ^$"


---------------------------
-- Create widgets
---------------------------
local toggle_button = button.create(beautiful.play_icon, 28, 5, 3, beautiful.bg_normal, beautiful.bg_light, beautiful.bg_very_light, function() 
    awful.spawn.easy_async_with_shell(spotify_commands.toggle, function()
        update_widget()
    end)
end)

local prev_button = button.create(beautiful.previous_icon, 28, 5, 3, beautiful.bg_normal, beautiful.bg_light, beautiful.bg_very_light, function() 
    awful.spawn.easy_async_with_shell(spotify_commands.prev, function()
        update_widget()
    end)
end)

local next_button = button.create(beautiful.next_icon, 28, 5, 3, beautiful.bg_normal, beautiful.bg_light, beautiful.bg_very_light, function() 
    awful.spawn.easy_async_with_shell(spotify_commands.next, function()
        update_widget()
    end)
end)

local title = wibox.widget.textbox("Title")
title.font = "Roboto Medium 12"
title.forced_height = 16

local artist = wibox.widget.textbox("Artist")
artist.font = "Roboto Medium 10.5"
artist.forced_height = 20

function add_song_data()
    local song_data = wibox.widget({
        {
            title,
            align = 'center',
            widget = wibox.container.place,
        },
        {
            artist,
            align = 'center',
            widget = wibox.container.place,
        }, 
        layout = wibox.layout.align.vertical,
    })
    return song_data
end

function add_player_controls()
    local player_controls = wibox.widget {
        nil, 
        {
            {
                prev_button, 
                layout = wibox.layout.align.horizontal
            }, 
            {
                toggle_button, 
                layout = wibox.layout.align.horizontal
            }, 
            {
                next_button, 
                layout = wibox.layout.align.horizontal
            },
            expand = "none", 
            layout = wibox.layout.align.horizontal
        }, 
        nil,
        expand = "none", 
        layout = wibox.layout.align.horizontal
    }

    return player_controls
end

local spotify = wibox.widget {
    {
        nil, 
        {
            image = beautiful.spotify_icon, 
            forced_height = 40, 
            forced_width = 40, 
            widget = wibox.widget.imagebox
        }, 
        nil, 
        expand = "none", 
        layout = wibox.layout.align.vertical
    }, 
    {
        add_song_data(),
        add_player_controls(), 
        layout = wibox.layout.align.vertical
    }, 
    layout = wibox.layout.align.horizontal
}

spotify.playing = false
spotify.current_song = ""

update_widget = function(callback)
    local timer = gears.timer {
        timeout = 0.1
    }
    
    timer:connect_signal("timeout", function()
        timer:stop()

        awful.spawn.easy_async_with_shell(spotify_commands.status, function(out)
            if string.match(out, "Playing") then
                toggle_button.update_image(beautiful.pause_icon)
                spotify.playing = true
            elseif string.match(out, "Paused") then
                toggle_button.update_image(beautiful.play_icon)
                spotify.playing = true
            else
                spotify.playing = false
            end
    
            if callback then
                callback()
            end
    
            if spotify.playing then
                awful.spawn.easy_async_with_shell(spotify_commands.song, function(out)
                    title:set_markup ("<span foreground='" .. beautiful.highlight .. "'><b>" .. out .. "</b></span>")
    
                    if out ~= spotify.current_song then 
                    
                        awful.spawn.easy_async_with_shell(spotify_commands.artist, function(out)
                            artist:set_markup ("<b>" .. out .. "</b>")
                        end)
                    end
    
                    spotify.current_song = out
                end)
    
                collectgarbage()
            end
        end)
    end)
    
    timer:start()
end

spotify.update_widget = update_widget

update_widget()

return spotify