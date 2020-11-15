local naughty = require('naughty')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi

-- Default config
naughty.config.spacing = dpi(4)
naughty.config.padding = dpi(10)
naughty.config.defaults.margin = dpi(10)
naughty.config.defaults.border_width = 0
naughty.config.defaults.max_width = dpi(350)
--naughty.config.defaults.max_height = dpi(78)
naughty.config.defaults.icon_size = 32
naughty.config.defaults.shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(4))
end


-- Presets
naughty.config.presets.low.timeout = 5

naughty.config.presets.normal.timeout = 6

naughty.config.presets.critical.timeout = 12
naughty.config.presets.critical.bg = beautiful.highlight
naughty.config.presets.critical.fg = beautiful.bg_normal
