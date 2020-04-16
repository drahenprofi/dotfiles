local apps = {
    terminal = "kitty", 
    launcher = "sh /home/parndt/.config/rofi/launch.sh", 
    notifications = require("notifications"), 
    switcher = require("widgets.awesome-switcher"), 
    xrandr = "lxrandr", --require("widgets.multi-monitor.xrandr2")
}

return apps