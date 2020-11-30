local beautiful = require("beautiful")

local button = require("components.button")

local launcher = button.create_image_onclick(beautiful.search_grey_icon, beautiful.search_icon, function()
    awesome.emit_signal("popup::prompt")
end)

return launcher