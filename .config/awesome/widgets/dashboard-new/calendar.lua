local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

local button = require("lib.button")


local calendar = {}

local currentMonth = os.date('*t').month

local cal = wibox.widget {
    date = os.date('*t'),
    font = 'Roboto Regular 11',
    spacing = 4,
    fn_embed = function(widget, flag, date)
        local fg = beautiful.fg_dark
        local font = "Roboto Regular 11"
        widget.markup = widget.text
        widget.align = "center"

        if flag == "focus" and date.month == currentMonth then
            widget:set_markup('<b>' .. widget:get_text() .. '</b>')

            return wibox.widget {
                widget,
                bg = beautiful.green,
                fg = beautiful.bg_normal,
                shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, 4)
                end,
                widget = wibox.container.background
            }
        elseif flag == "header" then
            fg = beautiful.highlight
            widget.font = "Roboto Medium 12"
        elseif flag == "weekday" then
            widget:set_markup('<b>' .. string.upper(widget:get_text()) .. '</b>')
        end
    

        return wibox.widget {
            widget,
            fg = fg,
            widget = wibox.container.background
        }
    end,
    widget = wibox.widget.calendar.month
}

local calendarWidget = wibox.widget {
    {
        nil, 
        button.create_image_onclick(beautiful.previous_grey_icon, beautiful.previous_icon, function() 
            local a = cal:get_date()
            a.month = a.month - 1
            cal:set_date(nil)
            cal:set_date(a)
        end), 
        nil, 
        forced_width = 30,
        expand = "none", 
        layout = wibox.layout.align.vertical
    },
    cal,
    {
        nil, 
        button.create_image_onclick(beautiful.next_grey_icon, beautiful.next_icon, function() 
            local a = cal:get_date()
            a.month = a.month + 1
            cal:set_date(nil)
            cal:set_date(a)
        end), 
        nil, 
        forced_width = 30,
        expand = "none", 
        layout = wibox.layout.align.vertical
    },
    expand = "none", 
    layout = wibox.layout.align.horizontal, 
}

calendarWidget.reset = function() 
    cal:set_date(nil)
    cal:set_date(os.date('*t'))
end


return calendarWidget