local favourites = require("widgets.tasklist.favourites")
local naughty = require("naughty")

function reverse_table(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

return function()
    -- Get all clients
    local cls = client.get()

    -- Filter by an existing filter function and allowing only one client per class
    local result = {}
    local class_seen = {}
    for _, c in pairs(cls) do
        client_identifier = c.class

        --if c.icon_name == "com.bitwig.BitwigStudio" then 
        --    client_identifier = "bitwig"
        --end

        if client_identifier ~= nil and not class_seen[client_identifier] and not favourites[client_identifier:lower()] then
            
            if client_identifier:lower() == "pianoteq stage" then 
            else 
                class_seen[client_identifier] = true
                table.insert(result, c)
            end
        end
    end
    
    return reverse_table(result)
end