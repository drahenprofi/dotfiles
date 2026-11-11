local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local rubato = require("modules.rubato")

local apply_borders = require("lib.borders")
local button = require("lib.button")
local show_notification = require("widgets.topbar.notifications.show_notification")
local get_notification_content = require("widgets.topbar.notifications.notification_content")

width = 316

local notification_center = wibox({
    visible = true, 
    ontop = true, 
    type = "dock", 
    screen = screen.primary, 
    x = awful.screen.focused().geometry.width + 2, 
    y = beautiful.bar_height + 8,
    bg = "#00000000", 
    opened = false
})

local animation = rubato.timed {
    duration = 0.3, --half a second
    intro = 0.1, --one third of duration
    override_dt = true, --better accuracy for testing
    subscribed = function(pos)
        if pos == 0 then 
            notification_center.opened = false
        else
            notification_center.opened = true
        end

        notification_center.x = awful.screen.focused().geometry.width + 2 - pos * (width + 10)
    end
}

notification_center.toggle = function()
    if notification_center.x > awful.screen.focused().geometry.width then 
        animation.target = 1
    else
        animation.target = 0
    end
end

local notification_list = wibox.layout.fixed.vertical()
notification_list.spacing = 8

local content = wibox.widget {
    {
        {
            {
                {
                    text = "Notifications",
                    font = "Roboto Bold 12", 
                    widget = wibox.widget.textbox
                }, 
                nil, 
                button.create_text(beautiful.fg_dark, beautiful.fg_normal, "󰎟", 16, function() 
                    notification_list:reset()
                    notification_center.update_borders()
                    notification_center.toggle()
                end), 
                forced_height = 36, 
                layout = wibox.layout.align.horizontal
            }, 
            notification_list,
            widget = wibox.layout.fixed.vertical
        }, 
        margins = 8, 
        widget = wibox.container.margin
    },
    bg = beautiful.bg_normal,
    widget = wibox.container.background
}

local notify_widget = wibox.widget {
    markup = "<span foreground='"..beautiful.highlight.."'></span>", 
    font = "Fira Code NerdFont 10",
    visible = false,
    widget = wibox.widget.textbox
}

notification_center.update_borders = function()
    local count = #notification_list:get_children()

    if count > 0 then
        notify_widget.visible = true
    else
        notify_widget.visible = false
    end

    local height = 60 + 88 * count

    notification_center.width = width 
    notification_center.height = height 

    container = apply_borders(content, width, height, 4)
    notification_center:setup({container, layout = wibox.layout.fixed.vertical})
end

notification_center.update_borders()


local topbar_widget = wibox.widget {
    button.create_text(beautiful.fg_dark, beautiful.fg_normal, "", 10, function() 
        notification_center.toggle()
    end), 
    {
        notify_widget,
        left = 12,
        top = -7,
        widget = wibox.container.margin
    },
    forced_width = 20,         
    layout = wibox.layout.stack
}

naughty.connect_signal("request::display", function(n)
    if not notification_center.opened then 
        show_notification(n)
    end

    notification_list:add({
        {
            get_notification_content(n), 
            margins = 8, 
            forced_height = 80, 
            widget = wibox.container.margin
        }, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 8)
        end,
        bg = beautiful.bg_light, 
        widget = wibox.container.background
    })

    notification_center.update_borders()
end)


-- Icon size
naughty.config.defaults['border_width'] = 0

-- Timeouts
naughty.config.defaults.timeout = 5
naughty.config.presets.low.timeout = 2
naughty.config.presets.critical.timeout = 12


return topbar_widget
