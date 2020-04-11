local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")


local battery_text = wibox.widget{
  markup = "<span foreground='#cccccc'>0%</span>",
  align  = 'center',
  valign = 'center',
  widget = wibox.widget.textbox, 
  font = "Roboto Bold 10"
}

local battery_image = wibox.widget {
  image  = beautiful.battery_full_grey_icon,
  widget = wibox.widget.imagebox
}

local function update_widget(bat, charging)
  battery_text.markup = bat .. "%"

  --[[if charging then
    battery_image.image = beautiful.battery_charging_icon
  elseif bat > 10 then
    battery_image.image = beautiful.battery_full_grey_icon
  else
    battery_image.image = beautiful.battery_alert_icon
  end]]--
end

awesome.connect_signal("daemons::battery", function(value)
  update_widget(value)
end)

local battery = {
  get = function()
    return battery_image, battery_text
  end
}

return battery