local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local rubato = require("modules.rubato")

local apply_borders = require("lib.borders")

local createPopup = function(color)
    local icon = wibox.widget {
        font = beautiful.glyph_font.." 14",
        forced_width = 28,
        align = "left", 
        valign = "center",
        widget = wibox.widget.textbox
    }

    local progressbar = wibox.widget {
        value         = 1,
        color		  = color,
        background_color = beautiful.misc2,
        forced_width = dpi(120),
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        forced_height  = dpi(6),
        widget        = wibox.widget.progressbar
    }

    local text = wibox.widget {
        text = 0,
        forced_width = 24,
        align = "right",
        font = "Roboto Bold 11",
        widget = wibox.widget.textbox
    }


    local widget = apply_borders({
        {
            icon,
            {
                nil, 
                progressbar,
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            text, 
            spacing = 8,
            layout = wibox.layout.fixed.horizontal,
        },
        left = 12, 
        right = 12,
        widget  = wibox.container.margin
    }, 204, 36, 6)

    local popup = awful.popup {
        widget = widget,
        y = awful.screen.focused().geometry.height + 2,
        x            = awful.screen.focused().geometry.width / 2 - 72,
        shape        = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        bg           = beautiful.bg_normal,
        ontop        = true,
    }

    popup:connect_signal("button::press", function() notyfi.visible = false end)

     local animation = rubato.timed {
        duration = 0.3, --half a second
        intro = 0.1, --one third of duration
        override_dt = true, --better accuracy for testing
        subscribed = function(pos) 
            --popup.y = pos * (beautiful.bar_height + 64) - 56
            popup.y = awful.screen.focused().geometry.height + 2 - pos * 64
        end
    }

    local timer_die = timer { timeout = 3 }

    popup.show = function()
        if timer_die.started then
            timer_die:again()
        else
            timer_die:start()
        end
        
        animation.target = 1
    end

    -- Hide popup after timeout
    timer_die:connect_signal("timeout", function()
        animation.target = 0
        -- Prevent infinite timers events on errors.
        if timer_die.started then
            timer_die:stop()
        end
    end)

    popup.update = function(value, image)
        icon.markup = "<span foreground='"..beautiful.fg_normal.."'>"..image.."</span>"
        progressbar.value = value / 100
    end

    popup.updateValue = function(value)
        if value ~= nil then
            progressbar.value = value / 100
            text.text = value
        end
    end

    return popup
end

return createPopup