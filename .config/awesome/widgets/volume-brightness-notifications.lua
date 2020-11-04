local naughty = require("naughty")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")


local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local size = dpi(32)

-- icon 
local icon = wibox.widget {
    align  = 'center',
    valign = 'center',
    --image = beautiful.reboot_icon,
    forced_height = size,
    forced_width  = size,
    widget = wibox.widget.imagebox, 
}

-- progressbar
local notyfi_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 6)
end

local progressbar = wibox.widget {
    value         = 1,
    color		  = beautiful.highlight,
    background_color = beautiful.fg_normal .. "66",
    shape         = notyfi_shape,
    bar_shape	  = notyfi_shape,
    forced_width = dpi(120),
    forced_height  = dpi(5),
    widget        = wibox.widget.progressbar
}

local progressbar_container = wibox.widget {
    {
        progressbar,
        layout = wibox.layout.align.vertical    
    },
    direction     = 'east',
    layout        = wibox.container.rotate,
}

local notyfi = awful.popup {
    widget = {
        {
            {
                nil, 
                {
                    {
                        progressbar_container,
                        layout = wibox.layout.align.horizontal
                    },
                    top = 10, 
                    bottom = 10, 
                    widget = wibox.container.margin
                },
                nil, 
                expand="none",
                layout = wibox.layout.align.horizontal
            }, 
            {
                widget = wibox.container.margin,
                bottom = dpi(10),
                {
                    layout = wibox.layout.fixed.horizontal,
                    icon,
                }
            },
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(5),
        widget  = wibox.container.margin
    },
    y            = awful.screen.focused().geometry.height / 2 - 72,
    x            = awful.screen.focused().geometry.width - 72,
    shape        = notyfi_shape,
    bg           = beautiful.bg_normal,
    ontop        = true,
    visible      = false,
}

notyfi:connect_signal("button::press", function() notyfi.visible = false end)

local timer_die = timer { timeout = 3 }

local show = function(value, image)
	icon.image = image
	progressbar.value = value / 100

    if timer_die.started then
		timer_die:again()
	else
		timer_die:start()
    end
    
    notyfi.visible = true
end

-- Hide popup after timeout
timer_die:connect_signal("timeout", function()
    notyfi.visible = false
    -- Prevent infinite timers events on errors.
    if timer_die.started then
        timer_die:stop()
    end
end)



local notifications = {
    volume_id = 0,
    brightness_id = 0
}

notifications.volume = function(value, is_muted)
    local icon = beautiful.volume_off_icon

    if not is_muted then
        if value > 60 then
            icon = beautiful.volume_up_icon
        elseif value > 25 then 
            icon = beautiful.volume_down_icon
        else
            icon = beautiful.volume_mute_icon
        end
    end
    show(value, icon)
end

notifications.brightness = function(value)
    show(value, beautiful.brightness_icon)
end

return notifications