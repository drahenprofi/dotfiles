local wibox = require("wibox")
local beautiful = require("beautiful")

local button = require("mainmenu.button")
local shutdownmenu = require("shutdownmenu")

local power = button.create(48, 48, beautiful.power_icon, function() shutdownmenu.toggle() end)

return power