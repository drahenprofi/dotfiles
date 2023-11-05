local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local notify_widget = wibox.widget {
    markup = "<span foreground='"..beautiful.highlight.."'></span>", 
    font = "Fira Code NerdFont 12",
    visible = false,
    widget = wibox.widget.textbox
}

local update_widget = wibox.widget {
    {
        markup = "<span foreground='"..beautiful.fg_dark.."'></span>",
        font = "JetBrains Mono NerdFont 10",
        forced_width = 16,
        widget = wibox.widget.textbox
    },
    {
        notify_widget,
        left = 6,
        top = -7,
        widget = wibox.container.margin
    },
    layout = wibox.layout.stack
}

awesome.connect_signal("evil::updates", function(updates)
    if updates > 0 then
        if not notify_widget.visible then
            local notify_text = updates.. " new update available."

            if updates > 1 then
                notify_text = updates.. " new updates available."
            end

            naughty.notify({title = "System", text = notify_text})
        end
        
        notify_widget.visible = true
    else 
        notify_widget.visible = false
    end
end)

return update_widget