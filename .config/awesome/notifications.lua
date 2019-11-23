local naughty = require("naughty")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")


local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Notifications --------------------------------------------------------------------------------------------
-- TODO: some options are not respected when the notification is created
-- through lib-notify. Naughty works as expected.

-- Icon size
-- naughty.config.defaults['icon_size'] = beautiful.notification_icon_size

-- Timeouts
naughty.config.defaults.timeout = 5
naughty.config.presets.low.timeout = 5
naughty.config.presets.critical.timeout = 12

-- Apply theme variables
naughty.config.spacing = beautiful.notification_spacing
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.border_width = beautiful.notification_border_width

--[[naughty.config.presets.normal = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_fg,
    bg           = beautiful.xbackgroundtp,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

naughty.config.presets.low = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_fg,
    bg           = beautiful.xbackgroundtp,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

naughty.config.presets.ok = naughty.config.presets.low
naughty.config.presets.info = naughty.config.presets.low
naughty.config.presets.warn = naughty.config.presets.normal

naughty.config.presets.critical = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_crit_fg,
    bg           = beautiful.notification_crit_bg,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}]]--
-------------------------------------------------------------------------------------------------------------

awesome.connect_signal("daemons::battery", function(value)
    if value < 5 then
        naughty.notify({title="Battery running low", text=value .. "%"})
    end
end)

local size = dpi(96)

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
    forced_height = dpi(8),
    forced_width  = size,
    color		  = beautiful.highlight,
    background_color = beautiful.fg_normal .. "66",
    shape         = notyfi_shape,
    bar_shape	  = notyfi_shape,
    widget        = wibox.widget.progressbar
}

local notyfi = awful.popup {
    widget = {
        {
            {
                widget = wibox.container.margin,
                bottom = dpi(10),
                {
                    layout = wibox.layout.fixed.horizontal,
                    icon,
                }
            },
            progressbar,
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(10),
        widget  = wibox.container.margin
    },
    y            = awful.screen.focused().geometry.height / 2 - 72,
    x            = (awful.screen.focused().geometry.width / 2) - (size / 2),
    shape        = notyfi_shape,
    bg           = beautiful.bg_normal .. "D9",
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