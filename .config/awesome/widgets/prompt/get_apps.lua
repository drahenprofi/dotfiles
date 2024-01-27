local lgi = require "lgi"
local Gio = lgi.Gio
local gtk = lgi.require("Gtk", "3.0")

local history = require("widgets.prompt.history")

local MAX_AMOUNT = 5

get_all_apps = function()
    local all_apps = {}

	for i, app_info in ipairs(Gio.AppInfo.get_all()) do
        if not app_info:get_boolean("NoDisplay") and app_info:get_show_in() then 
            table.insert(all_apps, app_info)
        end
    end

    return all_apps
end

get_apps_for_input = function(input)
    local all_apps = get_all_apps()

    local history_data = history.read()

    -- sort by history count and alphabetically
    table.sort(all_apps, function (a, b) 
        local history_a = history_data[a:get_name()]
        local history_b = history_data[b:get_name()]

        if history_a == nil then history_a = 0 end
        if history_b == nil then history_b = 0 end

        if history_a ~= history_b then 
            return history_a > history_b 
        else 
            return string.lower(a:get_name()) < string.lower(b:get_name()) 
        end
    end)
    
    local filtered = {}
    local icon_theme = gtk.IconTheme.get_default()
    local added = 0

    for i, app in ipairs(all_apps) do 
        local input_in_name = string.find(string.lower(app:get_name()), string.lower(input))
        local input_in_description = app:get_description() ~= nil and string.find(string.lower(app:get_description()), string.lower(input))

        if input_in_name or input_in_description then 
            local icon = app:get_icon()
            local themed_icon = icon_theme:lookup_by_gicon(icon, 48, 0)
            
            local filename = nil
            if themed_icon ~= nil then 
                filename = themed_icon:get_filename()
            end

            local item = {
                name = app:get_name(), 
                description = app:get_description(), 
                icon = filename, 
                launch = function() 
                    app:launch() 

                    history.write(app)
                end,
                selected = #filtered == 0
            }
            
            table.insert(filtered, item)
            added = added + 1

            if added >= MAX_AMOUNT then 
                return filtered
            end
        end
    end

    return filtered
end

return get_apps_for_input
