local wibox = require("wibox")
local lgi = require("lgi")
local awful = require("awful")
local naughty = require("naughty")

local Playerctl = lgi.Playerctl
local player = nil

local art_script = [[
sh -c '
    tmp_dir="$XDG_CACHE_HOME/awesome/"
    
    if [ -z ${XDG_CACHE_HOME} ]; then
        tmp_dir="$HOME/.cache/awesome/"
    fi

    tmp_cover_path=${tmp_dir}"cover.png"

    if [ ! -d $tmp_dir  ]; then
        mkdir -p $tmp_dir
    fi

    link="$(playerctl metadata mpris:artUrl)"
    link=${link/open.spotify.com/i.scdn.co}

    curl -s "$link" --output $tmp_cover_path && echo "$tmp_cover_path"
']]

--https://open.spotify.com/image/
--https://i.scdn.co/image/

update_metadata = function()
    local artist = ""
    local title = ""
    local playing = ""
    local status = ""

    if player:get_title() then
	    artist = player:get_artist()
        title = player:get_title()
        status = player.playback_status

        awful.spawn.easy_async_with_shell(art_script, function(out)
            -- Get album path
            local album_path = out:gsub('%\n', '')

            awesome.emit_signal("evil::playerctl", {
                artist = artist, 
                title = title, 
                status = status, 
                image = album_path
            })
        end)
    end
end

exit = function()
    awesome.emit_signal("evil::playerctl", {
        artist = "", 
        title = "",
        status = "STOPPED", 
        image = ""
    })
    
    player = nil
end

awful.widget.watch("playerctl status", 10, function(_, stdout, _, _)
    out = stdout:gsub('%\n', '')
    if out ~= "" and player == nil then
        player = Playerctl.Player{}
        player.on_metadata = update_metadata
        player.on_exit = exit
        update_metadata()
    end
end)

awesome.connect_signal("evil::playerctl::previous", function()
    player:previous()
end)

awesome.connect_signal("evil::playerctl::next", function()
    player:next()
end)

awesome.connect_signal("evil::playerctl::play_pause", function()
    player:play_pause()
end)