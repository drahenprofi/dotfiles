local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")

local apply_borders = require("lib.borders")

local default_icon = ''

beautiful.notification_bg = "#00000000"

-- Custom text icons according to the notification's app_name
-- plus whether the title should be visible or not
-- (This will be removed when notification rules are released)
-- Using icomoon font
local app_config = {
    ['screenshot'] = { icon = "", title = true },
    --['Telegram Desktop'] = { icon = "", title = true },
    --['NetworkManager'] = { icon = "", title = true },
    ["Spotify"] = { icon = "", title = false },
    ["battery"] = { icon = "󰂃", title = true },
    ["Discord"] = { icon = "󰙯", title = true }

}

local urgency_color = {
    ['low'] = beautiful.fg_normal,
    ['normal'] = beautiful.fg_normal,
    ['critical'] = beautiful.red,
}

-- Template
-- ===================================================================
naughty.connect_signal("request::display", function(n)
    local custom_notification_icon = wibox.widget {
        font = beautiful.glyph_font.." 28",
        align = "right",
        valign = "center",
        widget = wibox.widget.textbox
    }
    
    local color = urgency_color[n.urgency]

    local icon, title_visible

    -- Set icon according to app_name
    if app_config[n.app_name] then
        icon = app_config[n.app_name].icon
        title_visible = app_config[n.app_name].title
    else
        icon = default_icon
        title_visible = true
    end

    local action_widget = {
        {
            {
                id = 'text_role',
                align = "center",
                valign = "center",
                font = "Roboto Bold 10",
                widget = wibox.widget.textbox
            },
            left = dpi(6),
            right = dpi(6),
            widget = wibox.container.margin
        },
        bg = beautiful.bg_very_light,
        forced_height = dpi(25),
        forced_width = dpi(20),
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
        end,
        widget = wibox.container.background
    }

    local actions = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
            spacing = dpi(8),
            layout = wibox.layout.flex.horizontal
        },
        widget_template = action_widget,
        style = {
            underline_normal = false,
            underline_selected = true
        },
        widget = naughty.list.actions
    }

    naughty.layout.box {
        notification = n,
        type = "notification",
        position = beautiful.notification_position,
        --maximum_width = 300,
        --maximum_height = 78,
        widget_template = apply_borders({
            {
                {
                    {
                        markup = "<span foreground='"..color.."'>"..icon.."</span>",
                        align = "center",
                        valign = "center",
                        widget = custom_notification_icon,
                    },
                    forced_width = dpi(64),
                    bg = beautiful.bg_normal,
                    widget  = wibox.container.background,
                },
                {
                    {
                        nil,
                        {
                            {
                                text = n.title,
                                font = "Roboto Bold 11",
                                align = "left",
                                visible = title_visible,
                                widget = wibox.widget.textbox,
                                -- widget = naughty.widget.title,
                            },
                            {
                                text = n.message,
                                align = "left",
                                font = "Roboto Medium 10",
                                -- wrap = "char",
                                widget = wibox.widget.textbox,
                            },
                            {
                                actions,
                                visible = n.actions and #n.actions > 0,
                                layout  = wibox.layout.fixed.vertical,
                                forced_width = dpi(220),
                            },
                            spacing = dpi(4),
                            layout  = wibox.layout.fixed.vertical,
                        },
                        nil, 
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    margins = dpi(8),
                    widget  = wibox.container.margin,
                }, 
                layout  = wibox.layout.fixed.horizontal,
            },
            forced_height = 70,
            forced_width = 284,
            bg = beautiful.bg_normal,
            widget = wibox.container.background
        }, 300, 88, 8)
    }
end)


local notifications = {}

-- Notification settings
-- Icon size
naughty.config.defaults['border_width'] = 0

-- Timeouts
naughty.config.defaults.timeout = 5
naughty.config.presets.low.timeout = 2
naughty.config.presets.critical.timeout = 12
