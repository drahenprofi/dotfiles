local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local appmenu = require("mainmenu.appmenu")
local wallpaper = require("mainmenu.wallpaper")
local calendar = require("mainmenu.calendar")
local files = require("mainmenu.files")
local power = require("mainmenu.power")
local spotify = require("mainmenu.spotify")
local internet = require("mainmenu.internet")
local cw_widget = require("mainmenu.continuewatching")

local menu = {}

local visible = false


local box = function(content, width, height, margin)
    local box_widget = wibox.widget {
        {
            {
                nil,
                {
                    {
                        nil,
                        content,
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    margins = dpi(margin),
                    widget = wibox.container.margin,
                },
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            bg = beautiful.bg_normal,
            forced_height = dpi(height),
            forced_width = dpi(width),
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
            end,
            widget = wibox.container.background
        },
        margins = dpi(7),
        color = "#00000000",
        widget = wibox.container.margin
    }

    return box_widget
end

local spotify_box = box(spotify, 250, 314, 20)
spotify_box.visible = false

awful.screen.connect_for_each_screen(function(s)
    menu = wibox {
        screen = s,
        height = awful.screen.focused().geometry.height, 
        width = awful.screen.focused().geometry.width, 
        bg = "#00000000",--beautiful.misc2 .. "26", 
        --bgimage = beautiful.wallpaper,
        visible = visible, 
        ontop = true
    }

    menu:connect_signal("button::press", function() menu.visible = false end)

    menu:setup {
        nil,
        {
          nil,
          {
            {
              nil,
              {
                box(internet, 80, 225, 10),
                layout = wibox.layout.fixed.vertical
              },
              nil,
              expand = "none",
              layout = wibox.layout.align.vertical
            },
            {
              box(files, 200, 200, 30), 
              box(power, 200, 100, 10), 
              layout = wibox.layout.fixed.vertical
            },
            {
              nil,
              {
                spotify_box,
                layout = wibox.layout.fixed.vertical
              },
              nil,
              expand = "none",
              layout = wibox.layout.align.vertical
            },
            {
                box(appmenu, 300, 85, 10), 
                box(cw_widget, 300, 215, 20),
                layout = wibox.layout.fixed.vertical
            }, 
            --[[{
              boxes(threatpost_widget, feed_width, feed_height, 1),
              boxes(ycombinator_widget, feed_width, feed_height, 1),
              layout = wibox.layout.fixed.vertical
            },
            {
              nil,
              {
                boxes(todo_widget, 210, 30, 0),
                boxes(todo_list, 210, 200, 1),
                boxes(buttons_path_1_widget, 210, 85, 1),
                boxes(buttons_path_2_widget, 210, 85, 1),
                layout = wibox.layout.fixed.vertical
              },
              nil,
              expand = "none",
              layout = wibox.layout.align.vertical
            },
            {
              boxes(buttons_url_widget, 100, 350, 1),
              layout = wibox.layout.fixed.vertical
            },]]--
            layout = wibox.layout.fixed.horizontal
          },
          nil,
          expand = "none",
          layout = wibox.layout.align.horizontal
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    }
end)

menu.toggle = function()
  menu.visible = not menu.visible

  if menu.visible then
    spotify.update_widget(function()
      spotify_box.visible = spotify.playing
    end)
  end
end

return menu