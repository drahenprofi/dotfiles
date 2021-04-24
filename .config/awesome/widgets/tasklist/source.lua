local favourites = require("widgets.tasklist.favourites")

return function()
    -- Get all clients
    local cls = client.get()

    -- Filter by an existing filter function and allowing only one client per class
    local result = {}
    local class_seen = {}
    for _, c in pairs(cls) do
        if not class_seen[c.class] and not favourites[c.class:lower()] then
            class_seen[c.class] = true
            table.insert(result, c)
        end
    end
    return result
end