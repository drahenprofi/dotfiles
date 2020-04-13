local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi
local gears = require("gears")

local button = require("components.button")
local popupLib = require("components.popup") 
local layoutlist = require("widgets.topbar.widgets.layoutlist")

local height = 400
local width = 400

local popup = {}
local workspacesWidget = button.create_image(beautiful.sort_grey_icon, beautiful.sort_icon)

local createClientUI = function(client, tag)
    local widget = wibox.widget {
        {
            {
                {
                    nil, 
                    {
                        image = client.icon,
                        forced_height = dpi(20), 
                        forced_width = dpi(20),  
                        widget = wibox.widget.imagebox
                    }, 
                    nil,
                    expand = "none", 
                    layout = wibox.layout.align.vertical
                }, 
                {
                    forced_height = dpi(20), 
                    font = "Roboto Medium 11", 
                    valign = "center",
                    markup = client.name, 
                    widget = wibox.widget.textbox
                }, 
                spacing = dpi(10), 
                layout = wibox.layout.fixed.horizontal
            }, 
            margins = dpi(8), 
            widget = wibox.container.margin, 
        }, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        widget = wibox.container.background
    }

    widget:connect_signal("mouse::enter", function() widget.bg = beautiful.bg_light end)
    widget:connect_signal("mouse::leave", function() widget.bg = beautiful.bg_normal end)

    widget:connect_signal("button::press", function()
        client:raise()
        tag:view_only()
        popup.visible = false
    end)

    return widget
end

local createTagUI = function(tag, clients)
    local clientsContainer = wibox.layout.fixed.vertical()
    clientsContainer.spacing = 5

    for _, c in pairs(clients) do
        clientsContainer:add(createClientUI(c, tag))
    end

    return wibox.widget {
        {
            font = "Roboto Regular 10", 
            markup = "<span foreground='#cccccc8a'>Workspace "..tag.name.."</span>", 
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
    newWorkspace:connect_signal("button::press", function() 
        for _, tag in pairs(root.tags()) do
            if #tag:clients() == 0 then
               tag:view_only()
               popup.visible = false
               break 
            end
        end
    end)

    local taskManager = button.create_text("#cccccc", "#ffffff", "Task manager...", "Roboto Regular 10")
    taskManager:connect_signal("button::press", function() 
        awful.spawn("lxtask") 
        popup.visible = false
    end)
    
    return wibox.widget {
            newWorkspace, 
            taskManager, 
            spacing = 7, 
            layout = wibox.layout.fixed.vertical
    }
end

local workspacesLayout = wibox.layout.fixed.vertical()
workspacesLayout.spacing = 7

local updateWidget = function()
    workspacesLayout:reset(workspacesLayout)
    for _, tag in pairs(root.tags()) do
        local clients = tag:clients()
        if #clients > 0 then
            workspacesLayout:add(createTagUI(tag, clients))
        end
    end
end

local popupWidget = wibox.widget {
    {
        nil,
        layoutlist,
        nil,
        expand = "none", 
        layout = wibox.layout.align.horizontal
    },
    workspacesLayout,
    {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = 1,
    },
    createSettingsUI(),
    spacing = 10, 
    layout = wibox.layout.fixed.vertical 
}

popup = popupLib.create(5, beautiful.bar_height + 5, nil, width, popupWidget)

workspacesWidget:connect_signal("button::press", function() 
    updateWidget()
    popup.visible = not popup.visible
end)

return workspacesWidget