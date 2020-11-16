local watch = require("awful.widget.watch")
local naughty = require("naughty")

local GET_UPDATE_COUNT_CMD = 'bash -c "checkupdates | wc -l"'

watch(GET_UPDATE_COUNT_CMD, 1800, function(_, stdout, _, _, _)
    awesome.emit_signal("evil::pacman", {
        updates = tonumber(stdout)
    })
end)