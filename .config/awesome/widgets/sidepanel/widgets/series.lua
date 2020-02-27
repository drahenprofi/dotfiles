local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local button = require("components.button")

local widget = wibox.widget {
    {
        forced_width = 100,
        resize = true, 
        image = beautiful.series_icon,
        widget = wibox.widget.imagebox
    },
    {
        {
            align = "center", 
            valign = "center", 
            font = "Roboto Bold 18",
            markup = "<b>Continue watching</b>",
            widget = wibox.widget.textbox
        }, 
        top = 5, 
        widget = wibox.container.margin
    },
    layout = wibox.layout.align.vertical
}

local url = ""

local urlcmd = [[bash -c '
    db=$(find "${HOME}/.mozilla/firefox/" -name "places.sqlite")
    query="select p.url from moz_historyvisits as h inner join moz_places as p on h.place_id = p.id where p.url like \"%theofficetv%\" order by h.visit_date desc limit 1;"
    echo $(sqlite3 "${db}" "${query}") 
']]

awful.spawn.easy_async(urlcmd, function(stdout, stderr)
    url = stdout
end)

return wibox.widget {
    {
        button.create_widget(widget, function() 
            awful.spawn("firefox " .. url) 
        end),
        layout = wibox.layout.align.vertical 
    }, 
    left = 40, 
    right = 40, 
    bottom = 20, 
    widget = wibox.container.margin, 
}