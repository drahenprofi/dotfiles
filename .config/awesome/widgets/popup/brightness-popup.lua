local beautiful = require("beautiful")

local createPopup = require("widgets.popup.popup")

local popup = createPopup(beautiful.green)

awesome.connect_signal("evil::brightness", function(brightness)
	popup.update(brightness.value, brightness.image)
end)

awesome.connect_signal("popup::brightness", function(brightness)
    popup.updateValue(brightness.amount)
    popup.show()
end)