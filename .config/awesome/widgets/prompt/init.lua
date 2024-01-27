local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local suggestions_widget = require("widgets.prompt.suggestions")
local apply_borders = require("lib.borders")

local prompt_widget
local prompt_container

local height = 58
local width = 400

local prompt = wibox({
    visible = false, 
    ontop = true, 
    type = "dock", 
    screen = screen.primary, 
    x = (awful.screen.focused().geometry.width - width) / 2, 
    y = (awful.screen.focused().geometry.height - 332) / 2,
    width = width, 
    height = height * 7,
    bg = "#00000000"
})

local textbox = wibox.widget {
    widget = wibox.widget.textbox
}

local update_borders = function()
    local new_height = height + suggestions_widget.count() * 50 + math.max(suggestions_widget.count() - 1, 0) * 8
    prompt_container = apply_borders(prompt_widget, width, new_height, 8)
    prompt:setup({prompt_container, layout = wibox.layout.fixed.vertical})
end

prompt.run = function()
    suggestions_widget.reset()
    update_borders()
    prompt.visible = true

    awful.prompt.run {
        prompt = "",
        font = "Roboto Medium 14",
        bg_cursor = beautiful.fg_normal,
        textbox = textbox, 
        done_callback = function()
            prompt.visible = false
        end, 
        changed_callback = function(command)
            suggestions_widget.update(command)

            update_borders()
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

-- listen to signal emitted by other widgets
awesome.connect_signal("prompt::run", prompt.run)

prompt_widget = wibox.widget {
    {
        {
            {
                {
                    markup = "", 
                    font = "JetBrains Mono 14",
                    forced_width = dpi(28),
                    widget = wibox.widget.textbox
                },
                textbox,
                widget = wibox.layout.fixed.horizontal
            }, 
            margins = dpi(16), 
            widget = wibox.container.margin
        },
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

prompt_container = apply_borders(prompt_widget, width, height, 8)

prompt:setup({prompt_container, layout = wibox.layout.fixed.vertical})

return prompt

