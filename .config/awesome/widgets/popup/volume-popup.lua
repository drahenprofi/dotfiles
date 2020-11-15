local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local createPopup = require("widgets.popup.popup")

local popup = createPopup(beautiful.blue)

awesome.connect_signal("evil::volume", function(volume)
	popup.update(volume.value, volume.image)
end)

awesome.connect_signal("popup::volume", function(volume)
    popup.show()
end)