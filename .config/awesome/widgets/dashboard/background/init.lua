local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

local wallblur_script = awful.util.getdir("config").."/widgets/dashboard/background/wallblur.sh" 
local command = wallblur_script.." -i "..beautiful.wallpaper

local blur_wallpaper = function(dashboard)
    awful.spawn.easy_async_with_shell(command, function(stdout, stderr)
        beautiful.wallpaper_blur = stdout:gsub("\n", "")
        
        dashboard.bgimage = function(context, cr, width, height) 
            local img = gears.surface(beautiful.wallpaper_blur)
    
            local w, h = gears.surface.get_size(img)
            local aspect_w = awful.screen.focused().geometry.width / w
            local aspect_h = (awful.screen.focused().geometry.height) / h
    
            --aspect_h = math.max(aspect_w, aspect_h)
            --aspect_w = math.max(aspect_w, aspect_h)
            
            cr:scale(aspect_w, aspect_h)
    
            cr:translate(0, -(beautiful.bar_height * 1 / aspect_h))
            
            cr:set_source_surface(img, 0, 0)
            cr:paint()
        end
    end)
end

return blur_wallpaper