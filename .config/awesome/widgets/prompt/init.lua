local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apps = require("config.apps")
local popup = require("components.popup")

local width = dpi(200)
local height = dpi(80)
local margin = dpi(10)
local x = awful.screen.focused().geometry.width - width - margin
local y = beautiful.bar_height + margin

local prompt_popup
local prompt = awful.widget.prompt({
    done_callback = function() 
        prompt_popup.visible = false
    end,
    bg = beautiful.highlight
})

prompt_popup = popup.create(x, y, height, width, {
    {
        markup = "Run command: ", 
        font = "Roboto Bold 12", 
        widget = wibox.widget.textbox
    },
    {
        prompt, 
        bg = beautiful.highlight,
        widget = wibox.container.background
    },
    layout = wibox.layout.fixed.vertical
})

awesome.connect_signal("popup::prompt", function()
    prompt_popup.visible = true
    prompt:run()
end)