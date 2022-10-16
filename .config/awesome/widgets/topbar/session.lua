local beautiful = require("beautiful")

local button = require("lib.button")

local color = beautiful.green
local color_hover = beautiful.green_light

return button.create_text(color, color_hover, "ﲤ", beautiful.glyph_font.." 14", function()
    awesome.emit_signal("dashboard::toggle")
end)