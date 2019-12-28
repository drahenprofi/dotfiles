local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("mainmenu.button")

local github = button.create(42, 42, beautiful.github_icon, function() awful.spawn("firefox https://github.com") end)
local reddit = button.create(42, 42, beautiful.reddit_icon, function() awful.spawn("firefox https://reddit.com") end)
local youtube = button.create(42, 42, beautiful.youtube_icon, function() awful.spawn("firefox https://youtube.com") end)

local internet = wibox.widget {
    {
        {
            github,
            layout = wibox.layout.align.horizontal
        }, 
        top = 5, 
        bottom = 5, 
        widget = wibox.container.margin
    }, 
    {
        {
            reddit,
            layout = wibox.layout.align.horizontal
        }, 
        top = 5, 
        bottom = 5, 
        widget = wibox.container.margin
    }, 
    {
        {
            youtube,
            layout = wibox.layout.align.horizontal
        }, 
        top = 5, 
        bottom = 5, 
        widget = wibox.container.margin
    }, 
    layout = wibox.layout.align.vertical
}

return internet