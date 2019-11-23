local awful = require("awful")
local naughty = require("naughty")

local update_interval = 30

local bat_script = [[
  bash -c '
  echo $((($(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | sed 's/[^0-9]*//g') + $(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage | sed 's/[^0-9]*//g')) / 2))']]

awful.widget.watch(bat_script, update_interval, function(widget, stdout)
  local bat = stdout:gsub("%D+", "")
  awful.spawn.easy_async_with_shell("upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep state | grep -o discharging", function(stdout)
    local charging = false
    stdout = stdout:gsub("%s+", "")
    if stdout == nil or stdout == "" then 
        charging = true
    end

    awesome.emit_signal("daemons::battery", tonumber(bat), charging)
  end)
end)