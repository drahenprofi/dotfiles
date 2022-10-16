local awful = require("awful")
local watch = require("awful.widget.watch")

local GET_VOLUME_CMD = 'amixer -D pulse sget Master'

local handleVolume = function(stdout)
    local mute = string.match(stdout, "%[(o%D%D?)%]")   -- \[(o\D\D?)\] - [on] or [off]
    local volume = string.match(stdout, "(%d?%d?%d)%%") -- (\d?\d?\d)\%)
    volume = tonumber(string.format("% 3d", volume))

    local icon = ""

    if mute == 'off' then
        icon = ""
    elseif volume > 50 then
        icon = ""
    elseif volume > 5 then 
        icon = ""
    else
        icon = ""
    end

    awesome.emit_signal("evil::volume", {
        value = volume,
        image = icon
    })
end

watch(GET_VOLUME_CMD, 1, function(_, stdout, _, _, _)
    handleVolume(stdout)
end, nil)