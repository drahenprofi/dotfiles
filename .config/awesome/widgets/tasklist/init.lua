local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local naughty = require("naughty")

local rubato = require("modules.rubato")

local tasklist = require("widgets.tasklist.tasklist")

local width = 61
local openerWidth = 8
--tasklist.forced_width = width + openerWidth

local dock_container = wibox({
    visible = true, 
    ontop = true,
    type = "dock", 
    screen = screen.primary, 
    x = 0, 
    y = beautiful.bar_height,
    width = width,
    height = awful.screen.focused().geometry.height - beautiful.bar_height,
    bg = "#00000000"
})


local mouse_in_dock = false

local get_fullscreen = function()
    tag = awful.screen.focused().selected_tag

    for _, client in pairs(tag:clients()) do
        if client.fullscreen then
            return true
        end
    end

    return false
end

local get_auto_hide = function()
    if client.focus and client.focus.x < width then 
        return true
    end

    return false
end

local timed = rubato.timed {
    duration = 0.3, --half a second
    intro = 0.1, --one third of duration
    override_dt = true, --better accuracy for testing
    subscribed = function(pos) 
        dock_container.x = pos * (width - openerWidth) - width + openerWidth
    end
}

local update = function(tag)
    if tag == nil then
        tag = awful.screen.focused().selected_tag
    end

    if get_auto_hide(tag) and not mouse_in_dock then
        timed.target = 0
    else 
        timed.target = 1
    end
end

tasklist:connect_signal("mouse::leave", function() 
    mouse_in_dock = false    
    update()
end)

tasklist:connect_signal("mouse::enter", function()
    mouse_in_dock = true
    update()
end)

client.connect_signal("focus", update)
client.connect_signal("manage", update)
client.connect_signal("unmanage", update)
client.connect_signal("property::size", update)
client.connect_signal("property::position", update)
client.connect_signal("tagged", update)
tag.connect_signal("property::layout", update)
tag.connect_signal("property::selected", update)

dock_container:setup {
    {
        input_passthrough = true, 
        bg = "#0000000",
        widget = wibox.container.background
    },
    tasklist, 
    {
        input_passthrough = true, 
        bg = "#0000000",
        widget = wibox.container.background
    },
    expand = "none",
    layout = wibox.layout.align.vertical
}

update()