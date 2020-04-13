local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

local popupLib = require("components.popup")


local width = 270
local height = 180
local clock_format = "%A %B %d, %H:%M"

local calendar = {}

local clock = wibox.widget.textclock()
clock.font = "Roboto Bold 10"
clock.format = "<span foreground='#cccccc'>"..clock_format.."</span>"
clock.fg = beautiful.bg_normal

clock:connect_signal("mouse::enter", function() clock.format = "<span foreground='#ffffff'>"..clock_format.."</span>" end)
clock:connect_signal("mouse::leave", function() clock.format = "<span foreground='#cccccc'>"..clock_format.."</span>" end)

local cal = wibox.widget {
    date = os.date('*t'),
    font = 'Fira Mono 11',
    spacing = 8,
    fn_embed = function(widget, flag, date)
        local fg = beautiful.fg_normal

        if flag == "focus" then
            fg = beautiful.highlight_alt
        elseif flag == "header" then
            fg = beautiful.highlight
            widget:set_markup('<b>' .. widget:get_text() .. '</b>')
        elseif flag == "weekday" then
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

local popupWidget = wibox.widget {
    nil, 
    cal,
    nil, 
    expand = "none", 
    layout = wibox.layout.align.horizontal, 
}

local popup = popupLib.create(awful.screen.focused().geometry.width - width - 5, beautiful.bar_height + 5, 
    height, width, popupWidget)

clock:connect_signal("button::press", function() 
    popup.visible = not popup.visible 
end)

return clock