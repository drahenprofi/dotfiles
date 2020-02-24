local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

local calendar = {}

calendar.clock = wibox.widget.textclock()
calendar.clock.font = "Roboto Bold 10"
calendar.clock.format = "<span foreground='" .. beautiful.bg_normal .. "'>  %H:%M  </span>"
calendar.clock.fg = beautiful.bg_normal

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
        layout = wibox.layout.align.horizontal, 
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
        }
    }
end

return calendar