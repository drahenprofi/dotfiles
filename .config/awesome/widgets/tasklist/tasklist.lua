local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local helpers = require("lib.helpers")

local launchers = require("widgets.tasklist.launchers")
local get_app_widget = require("widgets.tasklist.app-widget")
local icons = require("widgets.tasklist.icons")
local borders = require("widgets.tasklist.borders")
local favourites = require("widgets.tasklist.favourites")
local source = require("widgets.tasklist.source")
local naughty = require("naughty")

local container = {}
local applist = {}

local get_height = function()
    local app_count = helpers.tablelength(favourites) + helpers.tablelength(source())
    local height = app_count * 48 - 8
    return height
end

local current_height = get_height()
local previous_height = 0

local redraw_borders = function()
    previous_height = current_height
    current_height = get_height()

    if previous_height ~= current_height then
        if helpers.tablelength(source()) == 0 then
            applist.spacing = dpi(0)
        else 
            applist.spacing = dpi(8)
        end

        container.redraw(current_height)
    end
end

local get_custom_icon = function(c)
    for i, v in pairs(icons) do
        if v["class"] == string.lower(c.class) then
            return v
        end
    end

    return nil
end

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:jump_to(false)
        end
    end), awful.button({}, 3, function()
        awful.menu.client_list({theme = {width = 250}})
    end), awful.button({}, 4, function() awful.client.focus.byidx(1) end),
                            awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

local widget = awful.widget.tasklist {
    screen = screen.primary, 
    filter = function() return true end, -- Filtering is already done in source
    source = source,
    buttons = tasklist_buttons,
    layout = {
        spacing = 8,
        layout  = wibox.layout.fixed.vertical, 
    },
    widget_template = {
        get_app_widget(true),
        id = 'background_role',
        widget = wibox.container.background, 
        create_callback = function(self, c, index, objects) --luacheck: no unused
            if c.active then
                self:get_children_by_id('selected_indicator')[1].bg = beautiful.fg_urgent
            end

            local icon = get_custom_icon(c)

            if icon then
                self:get_children_by_id("custom_icon")[1].markup = 
                    "<span foreground='"..icon["color"].."'>"..icon["icon"].."</span>"
                self:get_children_by_id("custom_icon")[1].visible = true
                self:get_children_by_id("default_icon")[1].visible = false
            else 
                self:get_children_by_id("default_icon")[1].visible = true
                self:get_children_by_id("custom_icon")[1].visible = false
            end

            helpers.hover_pointer(self)
        end,
        update_callback = function(self, c, index, objects) --luacheck: no unused
            if c.active then
                self:get_children_by_id('selected_indicator')[1].bg = beautiful.fg_urgent
            else
                self:get_children_by_id('selected_indicator')[1].bg = beautiful.misc1
            end
        end
    }
}

client.connect_signal("manage", function(c)
    redraw_borders()
end)

client.connect_signal("unmanage", function(c)
    redraw_borders()
end)

applist = wibox.widget {
    launchers,
    widget,
    layout = wibox.layout.fixed.vertical
}

container = borders(
    wibox.widget {
        applist,
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }, 53, get_height(), 8
)

return container