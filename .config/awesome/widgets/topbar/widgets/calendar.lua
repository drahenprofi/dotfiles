local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

local calendar = {}
local clock_format = "%A %B %d, %H:%M"

calendar.clock = wibox.widget.textclock()
calendar.clock.font = "Roboto Bold 10"
calendar.clock.format = "<span foreground='#cccccc'>"..clock_format.."</span>"
calendar.clock.fg = beautiful.bg_normal

calendar.clock:connect_signal("mouse::enter", function() calendar.clock.format = "<span foreground='#ffffff'>"..clock_format.."</span>" end)
calendar.clock:connect_signal("mouse::leave", function() calendar.clock.format = "<span foreground='#cccccc'>"..clock_format.."</span>" end)

local cal = wibox.widget {
    date = os.date('*t'),
    font = 'Fira Mono 10',
    spacing = 8,
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

calendar.init = function(s)
    local calendar_container = wibox {
        screen = s, 
        x = awful.screen.focused().geometry.width - 205, 
        y = beautiful.bar_height + 5, 
        width = 200, 
        height = 180,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end, 
        ontop = true, 
        visible = false
    }
    --naughty.notify({text="height: "..cal.height})

    calendar_container:connect_signal("button::press", function()
        calendar_container.visible = not calendar_container.visible    
    end)

    calendar.clock:connect_signal("button::press", function()
        calendar_container.visible = not calendar_container.visible
    end)

    calendar_container:setup {
        {
            widget = wibox.widget.separator,
            color  = '#b8d2f82a',
            forced_height = 1,
        },
        {
            widget = wibox.container.margin,
            top = 20, 
            bottom = 0,
            left = 16,
            right = 16,
            {
                cal,
                layout = wibox.layout.fixed.horizontal, 
            }
        }, 
        layout = wibox.layout.fixed.vertical
    }
end

return calendar