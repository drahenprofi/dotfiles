-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status using the ACPI tool
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local HOME = os.getenv("HOME")

local battery_widget = {}
local function worker(args)
    local icon_widget = wibox.widget {
        id = "icon",
        image = beautiful.battery_alert_icon, 
        widget = wibox.widget.imagebox,
    }
    local level_widget = wibox.widget {
        markup = "0%", 
        font = "Roboto Bold 10",
        widget = wibox.widget.textbox
    }

    battery_widget = wibox.widget {
        icon_widget,
        level_widget,
        spacing = dpi(2),
        layout = wibox.layout.fixed.horizontal,
    }

    local function show_battery_warning(charge)
        naughty.notify {
            icon = beautiful.battery_alert_icon,
            icon_size = 100,
            text = charge.."% left",
            title = "Battery running low!",
            timeout = 25, -- show the warning for a longer time
            hover_timeout = 0.5,
        }
    end

    local last_battery_check = os.time()
    local warningDisplayed = false

    local batteryType = beautiful.battery_full_grey_icon

    watch("acpi -i", 10,
    function(widget, stdout, stderr, exitreason, exitcode)
        local battery_info = {}
        local capacities = {}

        local charging = false

        for s in stdout:gmatch("[^\r\n]+") do
            local status, charge_str, time = string.match(s, '.+: (%a+), (%d?%d?%d)%%,?(.*)')
            
            if status == "Charging" then charging = true end

            if status ~= nil then
                table.insert(battery_info, {status = status, charge = tonumber(charge_str)})
            else
                local cap_str = string.match(s, '.+:.+last full capacity (%d+)')
                table.insert(capacities, tonumber(cap_str))
            end
        end

        local capacity = 0
        for i, cap in ipairs(capacities) do
            capacity = capacity + cap
        end

        local charge = 0
        local count = 0
        for _, batt in ipairs(battery_info) do
            charge = charge + batt.charge
            count = count + 1
        end

        charge = math.floor(charge / count)

        if charging then
            batteryType = beautiful.battery_charging_grey_icon
        elseif (charge >= 0 and charge < 10) then
            batteryType = beautiful.battery_alert_grey_icon
            if os.difftime(os.time(), last_battery_check) > 300 or not warningDisplayed then
                -- if 5 minutes have elapsed since the last warning
                last_battery_check = os.time()
                warningDisplayed = true

                show_battery_warning(charge)
            end
        elseif (charge >= 10 and charge <= 100) then 
            batteryType = beautiful.battery_full_grey_icon
        end

        icon_widget.image = batteryType
        level_widget.markup = "<span foreground='#cccccc'>"..charge.."%</span>"
    end,
    icon_widget)

    return battery_widget
end

return setmetatable(battery_widget, { __call = function(_, ...) return worker(...) end })