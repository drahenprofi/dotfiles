local awful = require("awful")
local beautiful = require("beautiful")

local apps = require("config.apps")
local button = require("lib.button")

local launcher = button.create_text(beautiful.fg_dark, beautiful.fg_focus, "", 14, function()
    --awful.spawn(apps.launcher, false)
    awesome.emit_signal("prompt::run")
end)

launcher.forced_width = 24

return launcher