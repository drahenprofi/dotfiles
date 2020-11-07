local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local button = require("components.button")
local apps = require("config.apps")

local createAppWidget = function(fg, fg_hover, text, onclick)
    local textbox = wibox.widget {
        markup = "<span foreground='"..fg.."'>"..text.."</span>",
        font = "Fira Mono 28",
        widget = wibox.widget.textbox
    }

    local container = wibox.widget {
        {
            textbox,
            left = dpi(16), 
            right = dpi(16), 
            widget = wibox.container.margin
        },  
        bg = beautiful.bg_normal, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(8))
        end,
        widget = wibox.container.background
    }

    container:connect_signal("mouse::enter", function()
        textbox.markup = "<span foreground='"..fg_hover.."'>"..text.."</span>"
        container.bg = beautiful.bg_dark
    end)

    container:connect_signal("mouse::leave", function()
        textbox.markup = "<span foreground='"..fg.."'>"..text.."</span>"
        container.bg = beautiful.bg_normal
    end)

    container:connect_signal("button::press", function() 
        awful.spawn(onclick, false)
        awesome.emit_signal("dashboard::toggle")
    end)

    return container
end

local browser = createAppWidget(beautiful.yellow, beautiful.yellow_light, "", apps.browser)
local terminal = createAppWidget(beautiful.fg_normal, beautiful.fg_focus, "", apps.terminal)
local fileexplorer = createAppWidget(beautiful.blue, beautiful.blue_light, "", apps.fileexplorer)
local musicplayer = createAppWidget(beautiful.green, beautiful.green_light, "", apps.musicplayer)
local code = createAppWidget(beautiful.red, beautiful.red_light, "", apps.code)

return wibox.widget {
    {
        nil, 
        {
            nil, 
            {
                browser, 
                terminal, 
                fileexplorer, 
                musicplayer,
                code, 
                spacing = dpi(8),
                layout = wibox.layout.fixed.vertical
            }, 
            nil,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        nil, 
        expand = "none", 
        layout = wibox.layout.align.horizontal
    }, 
    forced_width = dpi(64),
    widget = wibox.container.background, 
}