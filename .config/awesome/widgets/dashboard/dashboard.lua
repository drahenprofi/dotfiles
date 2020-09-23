local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")


local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local session = require("widgets.dashboard.session")
local avatar = require("widgets.dashboard.avatar")

local dashboard = wibox({
    visible = false, 
    ontop = true, 
    type = "dock", 
    screen = screen.primary, 
    bg = beautiful.bg_normal .. "CC"
})

local function drawBox(content, width, height)
    local margin = 16
    local padding = 16

    local container = wibox.container.background()
    container.bg = beautiful.bg_normal
    container.forced_width = dpi(width + margin + padding)
    container.forced_height = dpi(height + margin + padding)
    container.shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(16))
    end
    
    return wibox.widget {
        {
            {
                {
                    nil,
                    {
                        nil,
                        content,
                        layout = wibox.layout.align.vertical,
                        expand = "none"
                    },
                    layout = wibox.layout.align.horizontal,
                    expand = "none"
                }, 
                margins = dpi(padding),
                widget = wibox.container.margin
            },
            widget = container
        },
        margins = dpi(margin),
        widget = wibox.container.margin
    }
end

awful.placement.maximize(dashboard)

dashboard.toggle = function()
    dashboard.visible = not dashboard.visible
end

dashboard:setup {
    nil, {
        nil, 
        {
            drawBox(avatar, 144, 200),
            drawBox(session, 144, 32),
            layout = wibox.layout.align.vertical
        },
        expand = "none",
        layout = wibox.layout.align.vertical
    }, 
    expand = "none",
    layout = wibox.layout.align.horizontal
}

dashboard:connect_signal("button::press", dashboard.toggle)

return dashboard