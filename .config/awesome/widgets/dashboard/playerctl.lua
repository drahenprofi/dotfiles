local wibox = require("wibox")
local gears = require("gears")
local lgi = require("lgi")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apply_borders = require("lib.borders")

local naughty = require("naughty")

local player = lgi.Playerctl.Player{}

local container = {}

local image = wibox.widget {
    resize = true,
    forced_height = dpi(100),
    widget = wibox.widget.imagebox
}

local artist = wibox.widget {
    font = "Roboto Black 12",
    widget = wibox.widget.textbox
}

local title = wibox.widget {
    font = "Roboto Regular 10",
    widget = wibox.widget.textbox
}

local previous = wibox.widget {
    font = "FiraMono Nerd Font 18",
    markup = "玲",
    widget = wibox.widget.textbox
}

local play_pause = wibox.widget {
    font = "FiraMono Nerd Font 28",
    widget = wibox.widget.textbox
}

local next = wibox.widget {
    font = "FiraMono Nerd Font 18",
    markup = "怜",
    widget = wibox.widget.textbox
}

previous:connect_signal("button::press", function() 
    player:previous()
end)

play_pause:connect_signal("button::press", function() 
    player:play_pause()
end)

next:connect_signal("button::press", function() 
    player:next()
end)

awesome.connect_signal("evil::playerctl", function(data)
    container.visible = data~=false

    if not data then return end

    artist.markup = data.artist
    title.markup = data.title

    if data.status == "PLAYING" then 
        play_pause.markup = ""
    else 
        play_pause.markup = "契"
    end 

    if data.image ~= "" then
        image:set_image(gears.surface.load_uncached(data.image))
    else
        image:set_image(beautiful.nocover_icon)
    end
end)

local playerctl_widget = wibox.widget {
    {
        {
            image,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, dpi(4))
            end,
            widget = wibox.container.background
        },
        {
            nil,
            {
                artist, 
                title,
                layout = wibox.layout.fixed.vertical
            },
            nil,
            expand = "none", 
            forced_width = dpi(210),
            layout = wibox.layout.align.vertical
        },
        {
            previous,
            play_pause,
            next,
            spacing = dpi(20),
            layout = wibox.layout.fixed.horizontal
        },
        spacing = dpi(16),
        layout = wibox.layout.fixed.horizontal
    }, 
    left = dpi(8), 
    right = dpi(8),
    widget = wibox.container.margin
}

container = apply_borders({
    {
        playerctl_widget,
        margins = dpi(8),
        widget = wibox.container.margin
    },
    forced_width = dpi(420), 
    forced_height = dpi(80),
    bg = beautiful.bg_normal,
    widget = wibox.container.background
}, 420, 80, 8)

container.visible = false

return container