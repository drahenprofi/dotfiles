local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local button = require("mainmenu.button")

local cw_widget = wibox.widget {
    {
        forced_width = 100,
        resize = true, 
        image = beautiful.hxh_icon,
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
        top = 10, 
        widget = wibox.container.margin
    },
    layout = wibox.layout.align.vertical
}

local url = ""

local urlcmd = [[bash -c '
    db=$(find "${HOME}/.mozilla/firefox/" -name "places.sqlite")
    query="select p.url from moz_historyvisits as h inner join moz_places as p on h.place_id = p.id where p.url like \"%animeheaven.ru%\" order by h.visit_date desc limit 1;"
    echo $(sqlite3 "${db}" "${query}") 
']]

awful.spawn.easy_async(urlcmd, function(stdout, stderr)
    url = stdout
end)

return button.create_widget(cw_widget, function() 
    awful.spawn("firefox " .. url) 
end)