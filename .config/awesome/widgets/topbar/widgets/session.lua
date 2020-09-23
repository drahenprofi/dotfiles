local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local apps = require("config.apps")

local button = require("components.button")
local popupLib = require("components.popup")

local dashboard = require("widgets.dashboard")

local popup = {}

local poweroff = button.create_image_onclick(beautiful.power_grey_icon, beautiful.power_icon, function() awful.spawn("poweroff") end)
local reboot = button.create_image_onclick(beautiful.reboot_grey_icon, beautiful.reboot_icon, function() awful.spawn("reboot") end)
local logout = button.create_image_onclick(beautiful.logout_grey_icon, beautiful.logout_icon, function() awesome.quit() end)

local appearance = button.create_text("#cccccc", "#ffffff", "Appearance", "Roboto Medium 11")
appearance:connect_signal("button::press", function()
    awful.spawn(apps.appearance)
    popup.visible = false
end)

local info = button.create_text("#cccccc", "#ffffff", "System Info", "Roboto Medium 11")
local settings = button.create_text("#cccccc", "#ffffff", "Settings", "Roboto Medium 11")
settings:connect_signal("button::press", function()
    awful.spawn("code /home/parndt/awesome")
    popup.visible = false
end)

local width = 300
local height = 150

local sessionWidget = wibox.widget {
    button.create_image(beautiful.start_grey_icon, beautiful.start_icon), 
    widget = wibox.widget.background
}


local popupWidget = wibox.widget {
    {
        nil, 
        {
            {
                nil, 
                {
                    image = beautiful.avatar,
                    forced_height = 80, 
                    widget = wibox.widget.imagebox
                },
                nil, 
                expand = "none", 
                layout = wibox.layout.align.horizontal
            },  
            {
                font = "Fira Mono Bold 10", 
                align = "center", 
                markup = "<span foreground='"..beautiful.highlight.."'>parndt</span>@<span foreground='"..beautiful.highlight.."'>rouge</span>", 
                widget = wibox.widget.textbox
            }, 
            spacing = 10, 
            layout = wibox.layout.fixed.vertical
        }, 
        expand = "none", 
        layout = wibox.layout.align.vertical
    }, 
    {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_width = 1,
        orientation = "vertical"
    },
    {
        {
            appearance, 
            info, 
            settings, 
            forced_height = height - 48 - 5, 
            spacing = 5, 
            layout = wibox.layout.fixed.vertical
        }, 
        {
            poweroff, 
            reboot, 
            logout, 
            spacing = 20, 
            layout = wibox.layout.fixed.horizontal
        }, 
        spacing = 5, 
        layout = wibox.layout.fixed.vertical
    }, 
    spacing = 10, 
    layout = wibox.layout.fixed.horizontal
}

popup = popupLib.create(5, beautiful.bar_height + 5, height, width, popupWidget)

--sessionWidget:connect_signal("button::press", function() popup.visible = not popup.visible end)
sessionWidget:connect_signal("button::press", dashboard.toggle)

return sessionWidget