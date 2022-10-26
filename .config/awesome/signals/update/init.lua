local awful = require("awful")
local watch = require("awful.widget.watch")

local GET_UPDATES_CMD = "bash -c 'checkupdates | wc -l'"

local handleUpdates = function(stdout)
    local updates = tonumber(stdout)

    awesome.emit_signal("evil::updates", updates)
end

watch(GET_UPDATES_CMD, 500, function(_, stdout, _, _, _)
    handleUpdates(stdout)
end, nil)