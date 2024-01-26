local lgi = require "lgi"
local Gio = lgi.Gio

--[[
create_menu_entry_for_app = (app_info) -> {
	app_info::get_name()
	() -> app_info::launch()
	util.lookup_gicon(app_info::get_icon())
}]]--

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

    for _, app in ipairs(all_apps) do 
        if string.find(string.lower(Gio.AppInfo.get_name(app)), string.lower(input)) then 
            table.insert(filtered, app)
        end
    end

    return filtered
end

return get_apps_for_input
