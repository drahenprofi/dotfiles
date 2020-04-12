local notifications = require("notifications")
local switcher = require("widgets.awesome-switcher")

local apps = {
    terminal = "kitty", 
    launcher = "sh /home/parndt/.config/rofi/launch.sh", 
    notifications = notifications, 
    switcher = switcher
}

return apps