--[[
    
Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project 
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore 
is also licensed under the terms of the MIT License

]]--


local beautiful = require("beautiful")

local get_colors = require("lib.border_colors")

local add_decorations = function(c)
    local client_color = beautiful.bg_normal

    local args = get_colors(client_color)

    --[[local resize_button = {
        awful.widget.button(
            {}, 1, function()
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end),
    }]]--

    -- https://www.reddit.com/r/awesomewm/comments/ggru8u/custom_rule_properties/
    if c.class == "firefox" then
        require("decorations.top-alternate")(c, args)
    else
        require("decorations.top")(c, args)
    end
    require("decorations.left")(c, args)
    require("decorations.right")(c, args)
    require("decorations.bottom")(c, args)

    -- Clean up
    collectgarbage("collect")
end

client.connect_signal("request::titlebars", function(c)
    add_decorations(c)
end)