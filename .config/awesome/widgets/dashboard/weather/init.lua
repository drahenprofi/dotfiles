local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local json = require("lib.json")

local OPEN_WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather?q=Berlin&units=metric&appid="

local get_command = function(api_key)
    return "curl -X GET '"..OPEN_WEATHER_URL..api_key.."'"
end

local temperature = wibox.widget {
    font = "Fira Mono Bold 14",
    widget = wibox.widget.textbox
}

local description = wibox.widget {
    font = "Fira Mono 10", 
    widget = wibox.widget.textbox
}

local icon_widget = wibox.widget {
    font = "Fira Mono Bold 48",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local weather_widget = wibox.widget {
    icon_widget,
    {
        nil, 
        {
            temperature,
            description,
            layout = wibox.layout.fixed.vertical
        }, 
        expand = "none", 
        layout = wibox.layout.align.vertical
    }, 
    spacing = dpi(16),
    layout = wibox.layout.fixed.horizontal
}


local update_widget = function(widget, stdout, stderr)
    local result = json.decode(stdout)

    temperature.markup = "<span foreground='"..beautiful.bg_normal.."'>"..tostring(result.main.temp).." °C</span>"
    description.markup = "<span foreground='"..beautiful.bg_normal.."'>"..result.weather[1].description.."</span>" 
    
    local icon = ""

    if (result.weather[1].main == "Thunderstorm") then
        icon = ""
    elseif (result.weather[1].main == "Drizzle") then
        icon = ""
    elseif (result.weather[1].main == "Rain") then
        icon = ""
    elseif (result.weather[1].main == "Snow") then
        icon = ""
    elseif (result.weather[1].main == "Clear") then
        icon = ""
    elseif (result.weather[1].main == "Clouds") then
        icon = ""
    end

    icon_widget.markup = "<span foreground='"..beautiful.bg_normal.."'>"..icon.."</span>"
end

local api_key_path = awful.util.getdir("config") .. "widgets/dashboard/weather/openweathermap.txt"
awful.spawn.easy_async_with_shell("cat "..api_key_path, function(stdout)
    local api_key = stdout:gsub("\n", "")

    -- wait for wifi to connect
    awful.spawn.easy_async_with_shell("sleep 10", function()
        awful.widget.watch(get_command(api_key), 5000, update_widget, weather_widget)
    end)
end)

return weather_widget