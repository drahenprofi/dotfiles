local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

local function show_battery_warning(charge)
    local bg = beautiful.bg_normal
    local fg = beautiful.fg_normal

    if charge < 3 then 
        bg = beautiful.highlight
        fg = beautiful.bg_normal
    end

    naughty.notify {
        icon = beautiful.battery_alert_icon,
        icon_size = 32,
        text = charge.."% remaining",
        title = "Battery may run out soon!",
        timeout = 25, -- show the warning for a longer time
        hover_timeout = 0.5,
        fg = fg, 
        bg = bg
    }
end

local last_battery_check = os.time()
local warningDisplayed = false

local batteryType = beautiful.battery_full_grey_icon

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
        batteryType = beautiful.battery_charging_grey_icon
    elseif (charge >= 0 and charge < 10) then
        batteryType = beautiful.battery_alert_grey_icon
        if os.difftime(os.time(), last_battery_check) > 300 or not warningDisplayed or charge < 3 then
            -- if 5 minutes have elapsed since the last warning
            last_battery_check = os.time()
            warningDisplayed = true

            show_battery_warning(charge)
        end
    elseif (charge >= 10 and charge <= 100) then 
        batteryType = beautiful.battery_full_grey_icon
    end
    
    awesome.emit_signal("evil::battery", {
        charge = charge,
        image = batteryType
    })
end,
nil)