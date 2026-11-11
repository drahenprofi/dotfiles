local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi

local apps = require("config.apps")

local color_solid = beautiful.bg_normal 

local button = require("lib.button")

local widget = function(inner_widget)
    return wibox.widget {
        widget = wibox.container.margin,
        top = dpi(beautiful.bar_item_padding + 2), 
        bottom = dpi(beautiful.bar_item_padding + 2),
        left = dpi(6),
        right = dpi(6),
        {
            inner_widget,
            layout = wibox.layout.fixed.horizontal
        }
    }
end

-- Init widgets
------------------------------------------------
local session = require("widgets.topbar.session")
local taglist = require("widgets.topbar.taglist")
local clock = widget(require("widgets.topbar.clock"))
clock.right = 0

local tasklist = require("widgets.topbar.tasklist")
local launcher = require("widgets.topbar.launcher")
local update = require("widgets.topbar.notifications")
local globalmenu = require("widgets.topbar.globalmenu")

globalmenu.config.desktop_name   = "Desktop"
globalmenu.config.terminal       = "kitty"
globalmenu.config.editor         = "code"
globalmenu.config.editor_in_terminal = false
globalmenu.config.font           = "Roboto Medium 10"
globalmenu.config.menu_font      = "Roboto Medium 10"
globalmenu.config.menu_shape     = 4
globalmenu.config.menu_border_width = 1
globalmenu.config.menu_border_color = beautiful.bg_very_light
globalmenu.config.submenu_text   = ""
globalmenu.config.cursor         = "pointer"
globalmenu.config.disabled_fg    = "#444444"

beautiful.systray_icon_spacing = dpi(12)
local systray = wibox.widget.systray()

------------------------------------------------
-- setup
------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    s.topbar = awful.wibar({
        screen = s,
        position = beautiful.bar_position, 
        height = beautiful.bar_height, 
        type = "dock",
        bg = color_solid,
    })

    local bar_taglist = taglist.init(s)
    local bar_tasklist = tasklist.init(s)

    s.topbar:setup {
        layout = wibox.layout.align.horizontal, 
        spacing = dpi(10),
        expand = "none",
        {   -- Left
            widget(session), 
            globalmenu, 
            spacing = dpi(6),
            layout = wibox.layout.fixed.horizontal, 
        }, 
        {   -- Middle
            --widget(spotify()),
            --bar_tasklist,
            layout = wibox.layout.fixed.horizontal, 
        },
        {   -- Right 
            --widget(battery), 
            bar_taglist,
            widget(wibox.widget {
                widget = wibox.container.margin,
                left = 8, 
                top = 1,
                bottom = 1, 
                {
                    systray, 
                    layout = wibox.layout.fixed.horizontal, 
                }
            }),
            widget(update),
            clock, 
            widget(launcher),
            layout = wibox.layout.fixed.horizontal, 
        }
    }
end)