local beautiful = require("beautiful")

local button = require("components.button")

local color = beautiful.blue
local color_hover = beautiful.blue_light

return button.create_text(color, color_hover, "", "Fira Mono 20", function()
    awesome.emit_signal("dashboard::toggle")
end)