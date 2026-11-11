local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local apply_borders = require("lib.borders")

local default_icon = ''

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

local get_notification_content = function(n)
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
            left = 6,
            right = 6,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_very_light,
        forced_height = 25,
        forced_width = 20,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        widget = wibox.container.background
    }

    local actions = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
            spacing = 8,
            layout = wibox.layout.flex.horizontal
        },
        widget_template = action_widget,
        style = {
            underline_normal = false,
            underline_selected = true
        },
        widget = naughty.list.actions
    }

    return wibox.widget {
        {
            {
                markup = "<span foreground='"..color.."'>"..icon.."</span>",
                align = "center",
                valign = "center",
                widget = custom_notification_icon,
            },
            forced_width = 56,
            --bg = beautiful.bg_normal,
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
                        forced_width = 220,
                    },
                    spacing = 4,
                    layout  = wibox.layout.fixed.vertical,
                },
                nil, 
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            margins = 8,
            widget  = wibox.container.margin,
        }, 
        layout  = wibox.layout.fixed.horizontal,
    }
    
end

return get_notification_content