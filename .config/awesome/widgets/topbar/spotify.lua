local wibox = require("wibox")
local awful = require("awful")
local watch = require("awful.widget.watch")
local gears = require("gears")
local beautiful = require("beautiful")

local button = require("lib.button")

---------------------------
-- Spotify commands
---------------------------

local spotify_commands = {}
spotify_commands.status = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|egrep -A 1 \"string\"|cut -b 26-|cut -d '\"' -f 1|egrep -v ^$"
--spotify_commands.song = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 \"title\"|egrep -v \"title\"|cut -b 44-|cut -d '\"' -f 1|egrep -v ^$"
--spotify_commands.artist = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 2 \"artist\"|egrep -v \"artist\"|egrep -v \"array\"|cut -b 27-|cut -d '\"' -f 1|egrep -v ^$"
spotify_commands.toggle = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"

spotify_commands.song = "sp eval | grep SPOTIFY_TITLE | sed 's|SPOTIFY_TITLE=\"||g' | sed 's|\"$||g'"
spotify_commands.artist = "sp eval | grep SPOTIFY_ARTIST | sed 's|SPOTIFY_ARTIST=\"||g' | sed 's|\"$||g'"
spotify_commands.prev = "sp prev"
spotify_commands.next = "sp next"

local spotify = {}

local function worker(args)
    local title = wibox.widget.textbox("Title")
    title.font = "Fira Mono 10"

    local artist = wibox.widget.textbox("Artist")
    artist.font = "Fira Mono 10"

    local prev = button.create_image_onclick(beautiful.previous_grey_icon, beautiful.previous_icon, function() awful.spawn(spotify_commands.prev, false) end)
    local next = button.create_image_onclick(beautiful.next_grey_icon, beautiful.next_icon, function() awful.spawn(spotify_commands.next, false) end)

    function add_song_data()
        local songData = wibox.widget({
            {
                artist,
                widget = wibox.container.place,
            }, 
            {
                markup = "<b>-</b>", 
                font = "Fira Mono 10", 
                widget = wibox.widget.textbox
            }, 
            {
                title,
                widget = wibox.container.place,
            },
            spacing = 8, 
            layout = wibox.layout.fixed.horizontal,
        })


        songData:connect_signal("button::press", function() 
            awful.spawn(spotify_commands.toggle, false)
        end)

        return songData
    end

    spotify = wibox.widget {
        {
            markup = "<span foreground='"..beautiful.green.."'></span>", 
            font = "Fira Mono 18", 
            widget = wibox.widget.textbox
        },
        prev, 
        add_song_data(),
        next,
        spacing = 8,
        layout = wibox.layout.fixed.horizontal
    } 

    spotify.playing = false
    spotify.visible = false
    spotify.current_song = ""


    spotify.update_widget = function(widget, song, _, _, _)
        awful.spawn.easy_async_with_shell(spotify_commands.status, function(out)
            if string.match(out, "Playing") then
                widget.playing = true
            elseif string.match(out, "Paused") then
                widget.playing = true
            else
                widget.playing = false
            end

            widget.visible = widget.playing

            if widget.playing then
                awful.spawn.easy_async_with_shell(spotify_commands.song, function(out)
                    title:set_markup ("<span foreground='" .. beautiful.highlight .. "'><b>" .. out .. "</b></span>")
    
                    if out ~= spotify.current_song then  
                        awful.spawn.easy_async_with_shell(spotify_commands.artist, function(out)
                            artist:set_markup ("<b>" .. out .. "</b>")
                        end)
                    end
                end)

                spotify.current_song = out

                collectgarbage()
            end
        end)
    end

    watch(spotify_commands.song, 1, spotify.update_widget, spotify)

    return spotify
end

return setmetatable(spotify, { __call = function(_, ...)
    return worker(...)
end })