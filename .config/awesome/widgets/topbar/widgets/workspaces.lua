local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")

local button = require("components.button")
local height = 400
local width = 400

local workspacesWidget = button.create_image(beautiful.sort_grey_icon, beautiful.sort_icon)


local createClientUI = function(client)
    return wibox.widget {
        {
            image = client.icon,
            forced_height = 24, 
            forced_width = 24,  
            widget = wibox.widget.imagebox
        }, 
        {
            font = "Roboto Medium 10", 
            valign = "center", 
            markup = client.name, 
            widget = wibox.widget.textbox
        }, 
        spacing = 7, 
        layout = wibox.layout.fixed.horizontal
    }
end

local createTagUI = function(name, clients)
    local clientsContainer = wibox.layout.fixed.vertical()
    clientsContainer.spacing = 7

    for _, c in pairs(clients) do
        clientsContainer:add(createClientUI(c))
    end

    return wibox.widget {
        {
            font = "Roboto Regular 10", 
            markup = "<span foreground='#cccccc8a'>Workspace "..name.."</span>", 
            widget = wibox.widget.textbox
        }, 
        {
            widget = wibox.widget.separator,
            color  = '#b8d2f82a',
            forced_height = 1,
        },
        clientsContainer, 
        spacing = 5, 
        layout = wibox.layout.fixed.vertical
    }
end

local createSettingsUI = function() 
    local newWorkspace = button.create_text("#cccccc", "#ffffff", "New workspace", "Roboto Regular 10")
    local taskManager = button.create_text("#cccccc", "#ffffff", "Task manager...", "Roboto Regular 10")
    return wibox.widget {
        {
            newWorkspace, 
            taskManager, 
            spacing = 7, 
            layout = wibox.layout.fixed.vertical
        },
        top = 10, 
        bottom = 10, 
        widget = wibox.widget.margin
    }
end

local workspacesLayout = wibox.layout.fixed.vertical()
workspacesLayout.spacing = 7

local updateWidget = function()
    workspacesLayout:reset(workspacesLayout)
    for _, tag in pairs(root.tags()) do
        local clients = tag:clients()
        if #clients > 0 then
            workspacesLayout:add(createTagUI(tag.name, clients))
        end
    end
end

local popupWidget = wibox.widget {
    {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = 1,
    },
    {
        {
            workspacesLayout,
            {
                widget = wibox.widget.separator,
                color  = '#b8d2f82a',
                forced_height = 1,
            },
            createSettingsUI(),
            {
                {
                    markup = "test", 
                    widget = wibox.widget.textbox
                },
                top = 10, 
                bottom = 10, 
                widget = wibox.container.margin
            }, 
            layout = wibox.layout.fixed.vertical 
        }, 
        margins = 10, 
        widget = wibox.container.margin
    }, 
    forced_width = width, 
    layout = wibox.layout.fixed.vertical
}

local popup = awful.popup {
    widget = popupWidget, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end,
    visible = false, 
    ontop = true, 
    x = 5, 
    y = beautiful.bar_height + 5,
}

workspacesWidget:connect_signal("button::press", function() 
    updateWidget()
    popup.visible = not popup.visible
end)

return workspacesWidget