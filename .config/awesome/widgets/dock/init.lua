local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local dock = require("widgets.dock.dock")

local width = 68
local openerWidth = 8
local height = 376

local dock_container = wibox({
    visible = true, 
    ontop = true,
    type = "dock", 
    screen = screen.primary, 
    x = 0, 
    y = beautiful.bar_height + (awful.screen.focused().geometry.height - height - beautiful.bar_height) / 2,
    width = dpi(width + openerWidth), 
    height = dpi(height),
    bg = "#00000000"
})

local dock_opener = wibox.widget {
    bg = beautiful.bg_normal,
    forced_width = dpi(openerWidth),
    input_passthrough = true,
    bg = "#00000000",
    widget = wibox.container.background
}

local auto_hide = false
local mouse_in_dock = false
local set_position = function()
    if auto_hide and not mouse_in_dock then
        dock_container.x = -width 
    else 
        dock_container.x = 0
    end
end

local get_auto_hide = function(tag)
    for _, client in pairs(tag:clients()) do
        if client.x < width then
            return true
        end
    end

    return false
end

dock_opener:connect_signal("mouse::enter", function()
    dock_container.x = 0
end)

local timer = gears.timer {
    timeout   = 0.75,
    single_shot = true,
    callback  = set_position
}

dock:connect_signal("mouse::leave", function() 
    mouse_in_dock = false
    timer:again()
end)

dock:connect_signal("mouse::enter", function()
    mouse_in_dock = true
    timer:stop()
end)

local update = function(tag)
    if tag == nil then
        tag = awful.screen.focused().selected_tag
    end

    auto_hide = get_auto_hide(tag)
    set_position()
end

client.connect_signal("manage", function() update() end)
client.connect_signal("unmanage", function() update() end)
client.connect_signal("property::size", function() update() end)
client.connect_signal("property::position", function() update() end)
tag.connect_signal("property::layout", function(t) update(t) end)
tag.connect_signal("property::selected", function(t) update(t) end)


dock_container:setup {
    dock, 
    dock_opener,
    layout = wibox.layout.fixed.horizontal
}

update()