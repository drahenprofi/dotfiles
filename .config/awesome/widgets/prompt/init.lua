local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local suggestions_widget = require("widgets.prompt.suggestions")

local height = 48
local width = 300

local prompt = wibox({
    visible = false, 
    ontop = true, 
    type = "dock", 
    screen = screen.primary, 
    x = (awful.screen.focused().geometry.width - width) / 2, 
    y = (awful.screen.focused().geometry.height - height) / 3,
    width = width, 
    height = height * 5,
    bg = "#00000000"
})

local textbox = wibox.widget {
    widget = wibox.widget.textbox
}

prompt.run = function()
    prompt.visible = true
    suggestions_widget.reset()

    awful.prompt.run {
        prompt = "> ",
        font = "Roboto Medium 14",
        textbox = textbox, 
        done_callback = function()
            prompt.visible = false
        end, 
        changed_callback = function(command)
            suggestions_widget.update(command)
        end, 
        exe_callback = function(command)
            suggestions_widget.run()
        end, 
        keyreleased_callback = function(mod, key, command)
            if key == "Up" then 
                suggestions_widget.navigate_up()
            elseif key == "Down" then 
                suggestions_widget.navigate_down()
            end
        end
    }
end

prompt.close = function()
    prompt.visible = false
end

-- listen to signal emitted by other widgets
awesome.connect_signal("prompt::run", prompt.run)

prompt:setup {
    {
        textbox,
        bg = beautiful.bg_normal, 
        widget = wibox.container.background
    },
    {
      suggestions_widget,
        bg = beautiful.bg_normal, 
        widget = wibox.container.background
    },
    layout = wibox.layout.fixed.vertical
}

return prompt

