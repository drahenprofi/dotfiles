local watch = require("awful.widget.watch")

local naughty = require("naughty")

local GET_BRIGHTNESS_CMD = 'brightnessctl info'

watch(GET_BRIGHTNESS_CMD, 1, function(_, stdout, _, _ , _) 
    local value = tonumber(string.match(string.match(stdout, "%d+%%"), "%d+"))

    awesome.emit_signal("evil::brightness", {
        value = value, 
        image = ""
    })
end, nil)