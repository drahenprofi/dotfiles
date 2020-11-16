local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local icon = wibox.widget{
    markup = '<span foreground="'..beautiful.green..'">ﲤ</span>',
    font = "Fira Mono 88",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local username = wibox.widget{
    markup = '<span foreground="'..beautiful.highlight..'">parndt</span>@<span foreground="'..beautiful.highlight..'">rouge</span>',
    font = "Fira Mono 14",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- uptime
local uptime = wibox.widget {
    font = "Fira Mono 10",
    align = "center", 
    valign = "center",
    wrap = "char",
    widget = wibox.widget.textbox
}

local pacman = wibox.widget {
    markup = "1",
    font = "Roboto Medium 10", 
    align = "center", 
    valign = "center",
    widget = wibox.widget.textbox
}

local pacmanContainer = wibox.widget {
    {
        {
            pacman,
            margins = dpi(4),
            widget = wibox.container.margin
        },
        bg = beautiful.red,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(50))
        end,
        widget = wibox.container.background
    },
    {
        text = "updates available",
        font = "Roboto Bold 10",
        widget = wibox.widget.textbox
    },
    spacing = dpi(4),
    layout = wibox.layout.fixed.horizontal
}

awful.widget.watch("uptime -p | sed 's/^...//'", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1'):gsub(", ", ",\n")
    uptime.markup = "<span foreground='"..beautiful.fg_normal.."'>"..out.."</span>"
end)

awesome.connect_signal("evil::pacman", function(updates)
    local value = updates.updates
    pacman.markup = tostring(value)
    pacmanContainer.visible = value > 0
end)

return wibox.widget {
    icon,
    username, 
    uptime,
    pacmanContainer,
    spacing = dpi(12),
    layout = wibox.layout.fixed.vertical
}