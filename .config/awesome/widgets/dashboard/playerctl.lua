local wibox = require("wibox")
local naughty = require("naughty")

local artist = wibox.widget {
    widget = wibox.widget.textbox
}

local title = wibox.widget {
    widget = wibox.widget.textbox
}

awesome.connect_signal("evil::playerctl", function(data)
    --naughty.notify{text = "test"}
    artist.markup = data.artist
    title.markup = data.title
end)

return wibox.widget {
    artist, 
    title,
    layout = wibox.layout.fixed.vertical
}