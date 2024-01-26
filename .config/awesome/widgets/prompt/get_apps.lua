local lgi = require "lgi"
local Gio = lgi.Gio
local gtk = lgi.require("Gtk", "3.0")


get_all_apps = function()
    local all_apps = {}

	for i, app_info in ipairs(Gio.AppInfo.get_all()) do
        if not app_info:get_boolean("NoDisplay") and app_info:get_show_in() then 
            table.insert(all_apps, app_info)--Gio.AppInfo.get_name(app_info))
        end
    end


    return all_apps

    --[[
    for k, app_list in ipairs(all_apps) do
		table.sort(app_list, function (a, b) 
            return a.lower() < b.lower() 
        end)
    end

    return app_list]]--
end

get_apps_for_input = function(input)
    local all_apps = get_all_apps()

    local filtered = {}

    local icon_theme = gtk.IconTheme.get_default()
    
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
                launch = function() app:launch() end,
                selected = #filtered == 0
            }
            
            table.insert(filtered, item)
        end
    end

    return filtered
end

return get_apps_for_input
