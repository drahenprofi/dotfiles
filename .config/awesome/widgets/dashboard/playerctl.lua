local wibox = require("wibox")
local gears = require("gears")
local lgi = require("lgi")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apply_borders = require("lib.borders")

local player = lgi.Playerctl.Player{}

local image = wibox.widget {
    resize = true,
    forced_height = dpi(100),
    widget = wibox.widget.imagebox
}

local artist = wibox.widget {
    font = "Roboto Bold 12",
    widget = wibox.widget.textbox
}

local title = wibox.widget {
    font = "Roboto Regular 10",
    widget = wibox.widget.textbox
}

local previous = wibox.widget {
    font = "FiraMono Nerd Font 20",
    markup = "玲",
    widget = wibox.widget.textbox
}

local play_pause = wibox.widget {
    font = "FiraMono Nerd Font 28",
    widget = wibox.widget.textbox
}

local next = wibox.widget {
    font = "FiraMono Nerd Font 20",
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
    image,
    {
        nil,
        {
            artist, 
            title,
            layout = wibox.layout.fixed.vertical
        },
        nil,
        expand = "none", 
        forced_width = dpi(200),
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
}

return apply_borders({
    {
        playerctl_widget,
        left = dpi(8), 
        right = dpi(8),
        widget = wibox.container.margin
    },
    forced_width = dpi(400), 
    forced_height = dpi(64),
    bg = beautiful.bg_normal,
    widget = wibox.container.background
}, 400, 64, 8)