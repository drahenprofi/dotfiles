local awful = require("awful")
local beautiful = require("beautiful")

local apps = require("config.apps")
local button = require("lib.button")

local launcher = button.create_text(beautiful.red, beautiful.red_light, "", "Fira Mono 18", function()
    awful.spawn(apps.launcher, false)
end)

return launcher