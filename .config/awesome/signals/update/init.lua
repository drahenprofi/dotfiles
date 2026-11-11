local awful = require("awful")
local watch = require("awful.widget.watch")
local naughty = require("naughty")

local GET_UPDATES_CMD = "bash -c 'checkupdates | wc -l'"

local notif_shown = false

local handleUpdates = function(stdout)
    local updates = tonumber(stdout)

    if updates == 0 then 
        notif_shown = false
        return
    end

    if not notif_shown then 
        local notify_text = updates.. " new update available."

        if updates > 1 then
            notify_text = updates.. " new updates available."
        end

        naughty.notify({title = "System", text = notify_text})

        notif_shown = true
    end
end

watch(GET_UPDATES_CMD, 500, function(_, stdout, _, _, _)
    handleUpdates(stdout)
end, nil)