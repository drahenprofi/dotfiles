local awful = require("awful")
local beautiful = require("beautiful")

local apps = require("config.apps")
local button = require("components.button")

local launcher = button.create_image_onclick(beautiful.search_grey_icon, beautiful.search_icon, function()
    awful.spawn(apps.launcher, false)
end)

return launcher