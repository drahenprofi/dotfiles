local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local artwork_path = "/home/parndt/.config/awesome/.cache/artwork"

local button = require("mainmenu.button")

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
spotify_commands.artwork = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 \"artUrl\"|egrep -v \"artUrl\"|cut -b 44-|cut -d '\"' -f 1|egrep -v ^$"


---------------------------
-- Create widgets
---------------------------
local toggle_button = button.create(42, 42, beautiful.play_icon, function() awful.spawn(spotify_commands.toggle) end)

local artwork = wibox.widget {
    nil,
    {
        image = beautiful.spotify_icon, 
        forced_width = 48,
        forced_height = 48,
        widget = wibox.widget.imagebox
    }, 
    nil, 
    layout = wibox.layout.align.horizontal
}

local title = wibox.widget.textbox("Title")
title.align = center
title.font = "Roboto Medium 12"

local album = wibox.widget.textbox("Album")
album.align =  center
album.font = "Roboto Medium 10"

local artist = wibox.widget.textbox("Artist")
artist.align = center
artist.font = "Roboto Medium 10.5"

function add_artwork()
    local artwork_widget = wibox.widget ({
        {
            artwork, 
            valign = "center",
            align = 'center',
            widget = wibox.container.place,
        }, 
        layout = wibox.layout.align.vertical,
    })

    return artwork_widget
end

function set_artwork(playing)
    if playing then
        artwork.image = artwork_path
        artwork.forced_width = 150
        artwork.forced_height = 150

        artwork:emit_signal("widget::redraw_needed")
        artwork:emit_signal("widget::layout_changed")
    else
        artwork.image = beautiful.spotify_icon
        artwork.forced_width = 48
        artwork.forced_height = 48
    end
end

function add_song_data()
    local song_data = wibox.widget({
        {
            title,
            align = 'center',
            widget = wibox.container.place,
        },
        {
            album,
            align = 'center',
            widget = wibox.container.place,
        },
        {
            artist,
            align = 'center',
            widget = wibox.container.place,
        },
        layout = wibox.layout.flex.vertical,
    })
    return song_data
end

function add_player_controls()
    local player_controls = wibox.widget {
        {
            {
                button.create(42, 42, beautiful.previous_icon, function() awful.spawn(spotify_commands.prev) end),
                layout = wibox.layout.align.horizontal
            }, 
            {
                toggle_button, 
                layout = wibox.layout.align.horizontal
            }, 
            {
                button.create(42, 42, beautiful.next_icon, function() awful.spawn(spotify_commands.next) end),
                layout = wibox.layout.align.horizontal
            },
            expand = "none", 
            layout = wibox.layout.align.horizontal
        }, 
        align = 'center',
        widget = wibox.container.place,
    }

    return player_controls
end

local spotify = wibox.widget {
    {
        {
            {
                add_artwork(), 
                layout = wibox.layout.align.horizontal
            },
            bottom = 15, 
            widget = wibox.container.margin
        },
        add_song_data(),
        add_player_controls(), 
        layout = wibox.layout.align.vertical
    }, 
    widget = wibox.container.background
}

spotify.playing = false
spotify.current_song = ""

spotify.update_widget = function(callback)    
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
                    awful.spawn.easy_async_with_shell(spotify_commands.album, function(out)
                        album:set_markup ("<span foreground='#ffffffAA'>" .. out .. "</span>")
                    end)
                
                    awful.spawn.easy_async_with_shell(spotify_commands.artist, function(out)
                        artist:set_markup ("<span foreground='" .. beautiful.highlight_alt .. "'><b>" .. out .. "</b></span>")
                    end)      

                    awful.spawn.easy_async_with_shell(spotify_commands.artwork, function(out)
                        local cmd = "wget -O "..artwork_path.." "..out
                        awful.spawn.easy_async_with_shell(cmd, function(out)
                            set_artwork(true)
                        end)
                    end)  
                end

                spotify.current_song = out
            end)
        end
    end)
end

spotify.update_widget(nil)

return spotify