local wibox = require("wibox")
local lgi = require("lgi")
local naughty = require("naughty")

local Playerctl = lgi.Playerctl
local player = Playerctl.Player{}

update_metadata = function()
    local artist = ""
    local title = ""

    if player:get_title() then
	    artist = player:get_artist()
        title = player:get_title()
    end

    awesome.emit_signal("evil::playerctl", {
        artist = artist, 
        title = title
    })
end

player.on_metadata = update_metadata

update_metadata()