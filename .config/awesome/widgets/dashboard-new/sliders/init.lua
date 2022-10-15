local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local volume = require("widgets.dashboard-new.sliders.volume")
local brightness = require("widgets.dashboard-new.sliders.brightness")
local battery = require("widgets.dashboard-new.sliders.battery")

return wibox.widget {
    nil,
    {
        volume,
        brightness,
        battery,
        spacing = dpi(16),
        layout = wibox.layout.fixed.vertical
    }, 
    expand = "none", 
    layout = wibox.layout.align.vertical
}