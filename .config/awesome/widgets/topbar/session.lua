local beautiful = require("beautiful")

local button = require("components.button")

local color = beautiful.red
local color_hover = beautiful.red_light

return button.create_text(color, color_hover, "ﱣ", "Fira Mono 16", function()
    awesome.emit_signal("dashboard::toggle")
end)