local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

local notification


local last_battery_check = os.time()
local warningDisplayed = false

local icon = ""

watch("acpi -i", 10, function(widget, stdout, stderr, exitreason, exitcode)
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
        icon = ""
    elseif (charge >= 0 and charge < 10) then
        icon = ""
        if os.difftime(os.time(), last_battery_check) > 300 or not warningDisplayed or charge < 3 then
            -- if 5 minutes have elapsed since the last warning
            last_battery_check = os.time()
            warningDisplayed = true

            require("widgets.notifications").battery(charge)
        end
    elseif (charge < 20) then 
        icon = ""
    elseif charge < 30 then
        icon = ""
    elseif charge < 40 then
        icon = ""
    elseif charge < 50 then
        icon = ""
    elseif charge < 60 then
        icon = ""
    elseif charge < 70 then
        icon = ""
    elseif charge < 80 then
        icon = ""
    elseif charge < 90 then
        icon = ""
    elseif charge < 100 then
        icon = ""
    else
        icon = ""
    end
    
    awesome.emit_signal("evil::battery", {
        value = charge,
        image = icon
    })
end,
nil)