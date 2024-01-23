local wibox = require("wibox")

return wibox.widget {
    nil,
    require("widgets.tasklist.tasklist"),
    nil,
    expand = "none",
    layout = wibox.layout.align.vertical
}