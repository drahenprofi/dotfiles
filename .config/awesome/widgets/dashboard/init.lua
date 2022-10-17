local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apply_borders = require("lib.borders")
local content = require("widgets.dashboard.content")

local naughty = require("naughty")

local rubato = require("modules.rubato")

local height = 663
local width = 582

local outer_padding = 24

local busy = false

local dashboard = wibox({
    ontop = true, 
    type = "dock", 
    screen = screen.primary, 
    x = width, 
    y = 0,
    width = awful.screen.focused().geometry.width, 
    height = awful.screen.focused().geometry.height, 
    bg = "#00000000"
})

dashboard.open = function()
    if busy then return end 

    dashboard.visible = true
    busy = true

    timed = rubato.timed {
        duration = 0.75, 
        subscribed = function(pos) 
            dashboard.x = (width + outer_padding) - pos

            if pos == (width + outer_padding) then
                busy = false
            end
        end
    }

    timed.target = width + outer_padding
end

dashboard.close = function()
    if busy then return end 

    busy = true

    timed = rubato.timed {
        duration = 0.75, 
        subscribed = function(pos) 
            dashboard.x = pos
            
            if pos == (width + outer_padding) then
                dashboard.visible = false 
                busy = false
            end
        end
    }

    timed.target = width + outer_padding
end

dashboard.toggle = function()
    if dashboard.x >= width then
        dashboard.open()
    else
        dashboard.close()
    end
end

awesome.connect_signal("dashboard::toggle", dashboard.toggle)
awesome.connect_signal("dashboard::close", dashboard.close)

local background_top = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = awful.screen.focused().geometry.width,
    forced_height = beautiful.bar_height + 4,
}

local background_bottom = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = awful.screen.focused().geometry.width,
    forced_height = awful.screen.focused().geometry.height - beautiful.bar_height - 4,
}

local background_left = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = awful.screen.focused().geometry.width - width - 4,
    forced_height = height,
}

local background_right = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = 4,
    forced_height = height,
}

background_top:connect_signal("button::press", dashboard.toggle)
background_bottom:connect_signal("button::press", dashboard.toggle)
background_left:connect_signal("button::press", dashboard.toggle)
background_right:connect_signal("button::press", dashboard.toggle)

dashboard:setup {
    background_top, 
    {
        background_left, 
        {
            apply_borders({
                content, 
                bg = beautiful.bg_normal,
                widget = wibox.container.background
            }, width, height, 8), 
            forced_width = width,
            widget = wibox.container.background
        }, 
        background_right, 
        layout = wibox.layout.fixed.horizontal
    },
    background_bottom, 
    layout = wibox.layout.fixed.vertical
}