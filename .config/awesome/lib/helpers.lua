
local tablelength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local hover_pointer = function(widget)
    local old_cursor, old_wibox
    widget:connect_signal("mouse::enter", function()
        -- Hm, no idea how to get the wibox from this signal's arguments...
        local w = mouse.current_wibox
        old_cursor, old_wibox = w.cursor, w
        w.cursor = "hand2"
    end)
    widget:connect_signal("mouse::leave", function()
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)
end

local helpers = {
    tablelength = tablelength, 
    hover_pointer = hover_pointer
}

return helpers