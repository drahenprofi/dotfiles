local wibox = require("wibox")
local beautiful = require("beautiful")


local cal = wibox.widget {
    date = os.date('*t'),
    font = 'Consolas 12',
    spacing = 7,
    fn_embed = function(widget, flag, date)
        local fg = beautiful.fg_normal

        if flag == "focus" then
            fg = beautiful.highlight_alt
        elseif flag == "header" then
            fg = beautiful.highlight
            widget:set_markup('<b>' .. widget:get_text() .. '</b>')
        end

        return wibox.widget {
            {
                widget,
                widget  = wibox.container.margin
            },
            fg = fg,
            widget             = wibox.container.background
        }
    end,
    widget = wibox.widget.calendar.month
}

return cal