local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

-- bar colors

local color_transparent = gears.color({
    type = "linear", 
    from = { 0, 0 }, 
    to = { 0, beautiful.bar_height }, 
    stops = {
        { 0, beautiful.bg_normal .. "40" }, 
        { 0.5, beautiful.bg_normal .. "1A"},
        { 1, beautiful.bg_normal .. "00" }
    }
})

local color_solid = beautiful.bg_normal 

-- Init widgets
------------------------------------------------
local layoutbox = require("topbar.layoutbox")
local battery = require("topbar.battery")
local taglist = require("topbar.taglist")
local calendar = require("topbar.calendar")
local tasklist = require("topbar.tasklist")

local rofi_launcher = awful.widget.launcher({
    image = beautiful.launcher_icon, 
    command = "/home/parndt/.config/rofi/launch.sh"
})

beautiful.systray_icon_spacing = 6
local systray = wibox.widget.systray()

------------------------------------------------
-- setup
------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    s.topbar = awful.wibar({
        screen = s,
        position = beautiful.bar_position, 
        height = beautiful.bar_height, 
        bg = color_transparent,
    })

    local battery_image, battery_text = battery.get()
    local bar_taglist = taglist.init(s)
    --local bar_tasklist = tasklist.init(s)
    calendar.init(s)


    s.topbar:setup {
        layout = wibox.layout.align.horizontal, 
        spacing = 10,
        expand = "none",
        {   -- Left
            {
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4,
                right = 4,
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_normal, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, 5)
                    end,
                    {
                        rofi_launcher,
                        layout = wibox.layout.fixed.horizontal, 
                    }
                }
            },
            {

                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4,
                right = 4,
                {
                    widget = wibox.container.background,
                    bg = beautiful.misc2, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, beautiful.bar_item_radius)
                    end,
                    {
                        widget = wibox.container.margin,
                        top = 2, 
                        bottom = 2,
                        left = 6,
                        right = 6,
                        {
                            bar_taglist,
                            layout = wibox.layout.fixed.horizontal, 
                        }
                    }
                }
            },
            --[[{
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_normal, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, 5)
                    end,
                    {
                        bar_tasklist,
                        layout = wibox.layout.fixed.horizontal
                    }
                }
            },]]--W
            layout = wibox.layout.fixed.horizontal, 
        }, 
        {       
            layout = wibox.layout.fixed.horizontal, 
        },
        {   -- Right 
            {
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4, 
                right = 4, 
                {
                    widget = wibox.container.background,
                    bg = beautiful.highlight, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, beautiful.bar_item_radius)
                    end,
                    {
                        widget = wibox.container.margin,
                        top = 3, 
                        bottom = 3,
                        left = 4, 
                        right = 4, 
                        {
                            battery_image,
                            battery_text,
                            layout = wibox.layout.fixed.horizontal, 
                        }
                    }
                }
            },
            {
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4, 
                right = 4, 
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_normal, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, beautiful.bar_item_radius)
                    end,
                    {
                        widget = wibox.container.margin,
                        top = 3, 
                        bottom = 3,
                        left = 7, 
                        right = 7, 
                        {
                            systray, 
                            layout = wibox.layout.fixed.horizontal, 
                        }
                    }
                }
            },
            {
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4,
                right = 4,
                {
                    widget = wibox.container.background,
                    bg = beautiful.highlight_alt, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, beautiful.bar_item_radius)
                    end,
                    {
                        calendar.clock, 
                        layout = wibox.layout.fixed.horizontal, 
                    }
                }
            },
            {
                widget = wibox.container.margin,
                top = beautiful.bar_item_padding, 
                bottom = beautiful.bar_item_padding,
                left = 4,
                right = 4,
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_normal, 
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, 5)
                    end,
                    {
                        widget = wibox.container.margin,
                        top = 2, 
                        bottom = 2,
                        left = 2,
                        right = 2,
                        {
                            layoutbox,
                            layout = wibox.layout.fixed.horizontal, 
                        }
                    }
                }
            },
            layout = wibox.layout.fixed.horizontal, 
        }
    }
end)
------------------------------------------------

function set_topbar_color(clients, screen)
    local maximized_on_tag = false

    for _, c in pairs(clients) do
        if c.maximized then
            maximized_on_tag = true
            break
        end
    end

    if maximized_on_tag then 
        screen.topbar.bg = color_solid
    else
        screen.topbar.bg = color_transparent
    end
end

client.connect_signal('property::maximized', function (c)
    set_topbar_color(c.screen.clients, c.screen)
end)

client.connect_signal('property::minimized', function (c)
    set_topbar_color(c.screen.clients, c.screen)
end)

client.connect_signal("unmanage", function(c)
    set_topbar_color(c.screen.clients, c.screen)
end)

client.connect_signal("manage", function(c)
    set_topbar_color(c.screen.clients, c.screen)
end)

tag.connect_signal("property::selected", function(t)
    if t.selected then
        set_topbar_color(t:clients(), t.screen)
    end
end)