local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apps = require("config.apps")

local text = wibox.widget {
    text = "CONFIG", 
    font = "Roboto Bold 12",
    widget = wibox.widget.textbox
}

local icon = wibox.widget {
    markup = "<span foreground='"..beautiful.misc1.."'>漣</span>",
    font = "Fira Code NerdFont 24",
    forced_width = 24,
    widget = wibox.widget.textbox
}

local container = wibox.widget {
    nil, 
    {
        icon, 
        text,
        spacing = dpi(16),
        layout = wibox.layout.fixed.horizontal
    }, 
    nil, 
    expand = "none", 
    forced_height = dpi(51),
    layout = wibox.layout.align.horizontal
}

container:connect_signal("button::press", function()
    awesome.emit_signal("dashboard::toggle")
    awful.spawn(apps.settings, false)
end)

local old_cursor, old_wibox
container:connect_signal("mouse::enter", function()
    -- change cursor
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand2" 
end)

container:connect_signal("mouse::leave", function()
     -- reset cursor
     if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)

return container