local awful = require('awful')

awful.mouse.append_global_mousebindings{
    awful.button{
        modifiers = {}, 
        button = 1, 
        on_press = function() 
            awesome.emit_signal("dashboard::toggle") 
        end
    }
}