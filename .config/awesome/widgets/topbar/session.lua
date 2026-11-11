local beautiful = require("beautiful")

local button = require("lib.button")

local color = beautiful.green
local color_hover = beautiful.green_light

session = button.create_text(color, color_hover, "", 12, function()
    awesome.emit_signal("dashboard::toggle")
end)

session.forced_width = 16
return session