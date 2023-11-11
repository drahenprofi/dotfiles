local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local json = require("lib.json")

local CURRENT_WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather?q=Berlin&units=metric&appid="
local FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast?q=Berlin&units=metric&appid="

local get_weather_command = function(api_key)
    return "curl -X GET '"..CURRENT_WEATHER_URL..api_key.."'"
end

local get_forecast_command = function(api_key)
    return "curl -X GET '"..FORECAST_URL..api_key.."'"
end

local get_icon = function(condition)
    local icon

    if (condition == "Thunderstorm") then
        icon = ""
    elseif (condition == "Drizzle") then
        icon = ""
    elseif (condition == "Rain") then
        icon = ""
    elseif (condition == "Snow") then
        icon = ""
    elseif (condition == "Clear") then
        local time = os.date("*t")
        if time.hour > 6 and time.hour < 18 then
            icon = ""
        else
            icon = ""
        end
    elseif (condition == "Clouds") then
        icon = ""
    else
        icon = "敖"
    end

    return icon
end

local temperature = wibox.widget {
    font = "JetBrains Mono Bold 14",
    widget = wibox.widget.textbox
}

local loading_indicator = wibox.widget {
    font = "Roboto Bold 14", 
    markup = "Loading weather data...", 
    widget = wibox.widget.textbox
}

local description = wibox.widget {
    font = "JetBrains Mono 10", 
    widget = wibox.widget.textbox
}

local icon_widget = wibox.widget {
    font = beautiful.glyph_font.." 36",
    forced_width = dpi(54),
    forced_height = dpi(54),
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

local forecast1_time = wibox.widget {
    font = "Roboto Medium 11",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast1_temp = wibox.widget {
    font = "Roboto Regular 10",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast1_icon = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 28",
    forced_width = dpi(44),
    forced_height = dpi(64),
    align = "center",
    widget = wibox.widget.textbox
}

local forecast2_time = wibox.widget {
    font = "Roboto Medium 11",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast2_temp = wibox.widget {
    font = "Roboto Regular 10",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast2_icon = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 28",
    forced_width = dpi(44),
    forced_height = dpi(64),
    align = "center",
    widget = wibox.widget.textbox
}

local forecast3_time = wibox.widget {
    font = "Roboto Medium 11",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast3_temp = wibox.widget {
    font = "Roboto Regular 10",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast3_icon = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 28",
    forced_width = dpi(44),
    forced_height = dpi(64),
    align = "center",
    widget = wibox.widget.textbox
}

local forecast4_time = wibox.widget {
    font = "Roboto Medium 11",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast4_temp = wibox.widget {
    font = "Roboto Regular 10",
    align = "center",
    widget = wibox.widget.textbox
}

local forecast4_icon = wibox.widget {
    font = beautiful.glyph_font.." Nerd Font 28",
    forced_width = dpi(44),
    forced_height = dpi(64),
    align = "center",
    widget = wibox.widget.textbox
}

local forecast_widget = wibox.widget {
    {
        forecast1_time, 
        forecast1_icon, 
        forecast1_temp, 
        spacing = -12,
        layout = wibox.layout.fixed.vertical
    },
    {
        forecast2_time, 
        forecast2_icon, 
        forecast2_temp, 
        spacing = -12,
        layout = wibox.layout.fixed.vertical
    },
    {
        forecast3_time, 
        forecast3_icon, 
        forecast3_temp, 
        spacing = -12,
        layout = wibox.layout.fixed.vertical
    },
    {
        forecast4_time, 
        forecast4_icon, 
        forecast4_temp, 
        spacing = -12,
        layout = wibox.layout.fixed.vertical
    },
    spacing = 24,
    layout = wibox.layout.fixed.horizontal
}

local update_weather_widget = function(widget, stdout, stderr)
    local result = json.decode(stdout)

    loading_indicator.visible = false

    temperature.markup = "<span foreground='"..beautiful.fg_normal.."'>"..tostring(result.main.temp).." °C</span>"
    description.markup = "<span foreground='"..beautiful.fg_normal.."'>"..result.weather[1].description.."</span>" 
    
    local condition = result.weather[1].main
    local icon = get_icon(condition)

    icon_widget.markup = "<span foreground='"..beautiful.fg_normal.."'>"..icon.."</span>"
end

local update_forecast_widget = function(widget, stdout, stderr)
    local result = json.decode(stdout)

    local time1_string = string.match(tostring(result.list[1].dt_txt), "%d%d:%d%d")
    local temp1_string = math.floor(result.list[1].main.temp * 10) / 10
    forecast1_time.markup = "<span foreground='"..beautiful.fg_normal.."'>"..time1_string.."</span>"
    forecast1_temp.markup = "<span foreground='"..beautiful.fg_normal.."'>"..temp1_string.." °C</span>"
    forecast1_icon.markup = "<span foreground='"..beautiful.fg_normal.."'>"..get_icon(result.list[1].weather[1].main).."</span>" 

    local time2_string = string.match(tostring(result.list[2].dt_txt), "%d%d:%d%d")
    local temp2_string = math.floor(result.list[2].main.temp * 10) / 10
    forecast2_time.markup = "<span foreground='"..beautiful.fg_normal.."'>"..time2_string.."</span>"
    forecast2_temp.markup = "<span foreground='"..beautiful.fg_normal.."'>"..temp2_string.." °C</span>"
    forecast2_icon.markup = "<span foreground='"..beautiful.fg_normal.."'>"..get_icon(result.list[2].weather[1].main).."</span>" 

    local time3_string = string.match(tostring(result.list[3].dt_txt), "%d%d:%d%d")
    local temp3_string = math.floor(result.list[3].main.temp * 10) / 10
    forecast3_time.markup = "<span foreground='"..beautiful.fg_normal.."'>"..time3_string.."</span>"
    forecast3_temp.markup = "<span foreground='"..beautiful.fg_normal.."'>"..temp3_string.." °C</span>"
    forecast3_icon.markup = "<span foreground='"..beautiful.fg_normal.."'>"..get_icon(result.list[3].weather[1].main).."</span>" 

    local time4_string = string.match(tostring(result.list[4].dt_txt), "%d%d:%d%d")
    local temp4_string = math.floor(result.list[4].main.temp * 10) / 10
    forecast4_time.markup = "<span foreground='"..beautiful.fg_normal.."'>"..time4_string.."</span>"
    forecast4_temp.markup = "<span foreground='"..beautiful.fg_normal.."'>"..temp4_string.." °C</span>"
    forecast4_icon.markup = "<span foreground='"..beautiful.fg_normal.."'>"..get_icon(result.list[4].weather[1].main).."</span>" 
end

local api_key_path = awful.util.getdir("config") .. "widgets/dashboard/weather/openweathermap.txt"
awful.spawn.easy_async_with_shell("cat "..api_key_path, function(stdout)
    local api_key = stdout:gsub("\n", "")

    -- wait for wifi to connect
    awful.spawn.easy_async_with_shell("sleep 8", function()
        awful.widget.watch(get_weather_command(api_key), 5000, update_weather_widget, weather_widget)
        awful.widget.watch(get_forecast_command(api_key), 5000, update_forecast_widget, forecast_widget)
    end)
end)

return wibox.widget {
    nil,
    {
        loading_indicator,
        {
            nil,
            weather_widget,
            expand = "none", 
            layout = wibox.layout.align.horizontal
        }, 
        forecast_widget,
        spacing = dpi(12),
        layout = wibox.layout.fixed.vertical
    },
    expand = "none", 
    layout = wibox.layout.align.vertical
} 