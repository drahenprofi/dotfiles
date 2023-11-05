local wibox = require("wibox")
local gears = require("gears")
local lgi = require("lgi")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local player = lgi.Playerctl.Player{}

local height = 156
local width = height * 2

local music_art = wibox.widget {
    image = beautiful.nocover_icon,
    forced_width = dpi(height),
    forced_height = dpi(height),
    widget = wibox.widget.imagebox
}

local filter_color = {
	type = "linear",
	from = { 0, 0 },
	to = { 0, height + 2 },
	stops = { { 0, beautiful.bg_light .. "CC" }, { 1, beautiful.bg_light } },
}

local music_art_filter = wibox.widget({
	{
		bg = filter_color,
		forced_height = dpi(height+2),
		forced_width = dpi(height),
		widget = wibox.container.background,
	},
	direction = "east",
	widget = wibox.container.rotate
})

local image = wibox.widget {
    music_art, 
    music_art_filter,
    layout = wibox.layout.stack
}

local artist = wibox.widget {
    markup = "Not playing",
    font = "Roboto Black 14",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local title = wibox.widget {
    font = "Roboto Regular 11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local previous = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 16",
    markup = "󰒮",
    widget = wibox.widget.textbox
}

local play_pause = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 24",
    markup = "󰐊",
    widget = wibox.widget.textbox
}

local next = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 16",
    markup = "󰒭",
    widget = wibox.widget.textbox
}

previous:connect_signal("button::press", function() 
    awesome.emit_signal("evil::playerctl::previous")
end)

play_pause:connect_signal("button::press", function() 
    awesome.emit_signal("evil::playerctl::play_pause")
end)

next:connect_signal("button::press", function() 
    awesome.emit_signal("evil::playerctl::next")
end)

awesome.connect_signal("evil::playerctl", function(data)
    artist.markup = data.artist
    title.markup = data.title

    if data.artist == "" and data.title == "" then 
        artist.markup = "Not playing"
    end

    if data.status:lower() == "playing" then 
        play_pause.markup = "󰏤"
    else 
        play_pause.markup = "󰐊"
    end 

    if data.image ~= "" then
        music_art:set_image(gears.surface.load_uncached(data.image))
    else
        music_art:set_image(beautiful.nocover_icon)
    end
end)

return wibox.widget {
    {
        {
            image,
            {
                nil, 
                {
                    {
                        nil,
                        {
                            artist, 
                            title,
                            spacing = dpi(4),
                            layout = wibox.layout.fixed.vertical
                        },
                        nil,
                        expand = "none", 
                        forced_width = dpi(width),
                        layout = wibox.layout.align.vertical
                    }, 
                    {
                        nil, 
                        {
                            {
                                nil,
                                previous,
                                expand = "none", 
                                layout = wibox.layout.align.vertical
                            },
                            play_pause,
                            {
                                nil,
                                next,
                                expand = "none", 
                                layout = wibox.layout.align.vertical
                            },
                            spacing = dpi(80),
                            layout = wibox.layout.fixed.horizontal
                        },
                        nil,
                        expand = "none",
                        layout = wibox.layout.align.horizontal
                    },
                    spacing = dpi(16),
                    layout = wibox.layout.fixed.vertical
                }, 
                nil, 
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            layout = wibox.layout.stack
        },
        bg = beautiful.bg_light,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(8))
        end,
        widget = wibox.container.background
    }, 
    margins = dpi(8),
    widget = wibox.container.margin
}