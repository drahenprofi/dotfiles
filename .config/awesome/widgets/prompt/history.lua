local gfs = require("gears.filesystem")

local json = require("lib.json")

local history_file = gfs.get_cache_dir() .. "/prompt_history"

local history = {}

function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end
 
history.write = function(app)
    local history_data = history.read()

    local app_name = app:get_name()
    if history_data[app_name] then 
        history_data[app_name] = history_data[app_name] + 1 
    else 
        history_data[app_name] = 1 
    end

    file = io.open(history_file, "w")
    io.output(file)
    io.write(json.encode(history_data))
    io.close(file)
end

history.read = function()
    local history_data = {}

    local file = io.open(history_file, "rb")

    if file then 
        local jsonString = file:read "*a"
        file:close()

        history_data = json.decode(jsonString)
    end

    return history_data
end

--/home/parndt/.cache/awesome
--require("naughty").notify{text=cache}

return history