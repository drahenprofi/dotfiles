local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local GET_BRIGHTNESS_CMD = 'brightnessctl info'
local INC_BRIGHTNESS_CMD = 'brightnessctl set 5%+'
local DEC_BRIGHTNESS_CMD = 'brightnessctl set 5%-'

local widget = {}

local function worker(args)

    local args = args or {}

    local main_color = beautiful.green
    local mute_color = beautiful.misc2
    
    local image_size = 28

    local icon =  wibox.widget {
        image = beautiful.brightness_grey_icon, 
        forced_height = image_size, 
        forced_width = image_size,
        widget = wibox.widget.imagebox
    }

    local progressbar = wibox.widget {
        max_value     = 100,
        color		  = main_color,
        background_color = mute_color,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 6)
        end,
        forced_height = 4,
        widget        = wibox.widget.progressbar
    }

    local progressbar_container = wibox.widget {
        nil,
        {
            {
                progressbar, 
                direction     = 'east',
                layout        = wibox.container.rotate,
            },
            left = 4, 
            right = 4, 
            bottom = 8,
            widget = wibox.container.margin
        },
        icon, 
        layout = wibox.layout.align.vertical
    }

    local update_bar = function(widget, stdout, _, _, _)
        local value = string.match(string.match(stdout, "%d+%%"), "%d+")
        --naughty.notify({text = value})
        widget.value = tonumber(value);
    end

    progressbar:connect_signal("button::press", function(_, _, _, button)
        if (button == 4) then awful.spawn(INC_BRIGHTNESS_CMD, false)
        elseif (button == 5) then awful.spawn(DEC_BRIGHTNESS_CMD, false)
        end

        spawn.easy_async(GET_BRIGHTNESS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_bar(progressbar, stdout, stderr, exitreason, exitcode)
        end)
    end)

    watch(GET_BRIGHTNESS_CMD, 1, update_bar, progressbar)

    return progressbar_container
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })