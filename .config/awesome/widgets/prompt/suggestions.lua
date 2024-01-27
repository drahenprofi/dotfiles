local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local get_apps = require("widgets.prompt.get_apps")

local layout = wibox.layout.fixed.vertical()
layout.spacing = dpi(8)

local suggestions = {}
local current_command = ""

layout.reset = function()
    for i=1,#layout.children do
        layout:remove(#layout.children)
    end
end

layout.navigate_up = function()
    for i, suggestion in ipairs(suggestions) do
        if suggestion["selected"] and i > 1 then 
            suggestions[i]["selected"] = false 
            suggestions[i-1]["selected"] = true 
            break
        end 
    end

    layout.update_suggestions_widget()
end

layout.navigate_down = function()
    for i, suggestion in ipairs(suggestions) do
        if suggestion["selected"] and i < #suggestions then 
            suggestions[i]["selected"] = false 
            suggestions[i+1]["selected"] = true 
            break
        end 
    end

    layout.update_suggestions_widget()
end

layout.update = function(command)
    if command == current_command then return end

    current_command = command
    
    suggestions = {}
    
    if command ~= '' then 
        suggestions = get_apps(command)
    end

    layout.update_suggestions_widget(suggestions)
end

layout.update_suggestions_widget = function()
    layout.reset()

    for i, suggestion in ipairs(suggestions) do
        local icon = wibox.widget {
            forced_width = 24,
            forced_height = 24,
            widget = wibox.container.background
        }

        if suggestion["icon"] ~= nil then 
            icon = wibox.widget {
                image = suggestion["icon"],
                forced_width = 24,
                forced_height = 24,
                widget = wibox.widget.imagebox
            }
        end

        local suggestion_background = beautiful.bg_normal

        if suggestion["selected"] then 
            suggestion_background = beautiful.bg_light
        end

        layout:add(wibox.widget {
            {
                {
                    {
                        {
                            nil,
                            icon,
                            expand = "none", 
                            widget = wibox.layout.align.vertical
                        },
                        {
                            {
                                markup = suggestion["name"],
                                font = "Roboto Medium 12",
                                forced_height = 18,
                                widget = wibox.widget.textbox
                            }, 
                            {
                                markup = suggestion["description"],
                                font = "Roboto Regular 10",
                                forced_height = 16,
                                widget = wibox.widget.textbox
                            },
                            widget = wibox.layout.fixed.vertical
                        },
                        spacing = dpi(16),
                        widget = wibox.layout.fixed.horizontal
                    },
                    margins = dpi(8),
                    widget = wibox.container.margin
                },
                bg = suggestion_background,
                shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, dpi(4))
                end,
                widget = wibox.container.background
            }, 
            left = dpi(8),
            right = dpi(8),
            widget = wibox.container.margin
        })
    end

    return layout
end

layout.run = function()
    for _, suggestion in ipairs(suggestions) do
        if suggestion["selected"] then 
            suggestion:launch()
            return 
        end
    end
end

layout.count = function()
    return #layout.children
end

return layout