local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local content = {}

local function createDiskRow(disk)
    return wibox.widget{
        {
            markup = "<span foreground='"..beautiful.highlight_alt.."'>"..disk.mount.."</span>",
            font = "Fira Mono Bold 12", 
            forced_width = 64, 
            widget = wibox.widget.textbox
        },
        {
            max_value = 100,
            value = tonumber(disk.perc),
            forced_height = 32,
            margins = 4, 
            background_color = beautiful.bg_normal,
            color = beautiful.green,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 4)
            end,
            widget = wibox.widget.progressbar,

        },
        {
            text = math.floor(disk.used/1024/1024)
              .. '/'
              .. math.floor(disk.size/1024/1024) .. 'GB ('
              .. math.floor(disk.perc) .. '%)',
            font = "Roboto Bold 10", 
            forced_width = 112,
            align = "right",  
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.align.horizontal
      }
end

local function worker(args)
    local mounts = {"/", "/data"}
    local timeout = 60
    local disks = {}

    content = wibox.layout.fixed.vertical()
    content.spacing = 8

    watch([[bash -c "df | tail -n +2"]], timeout,
        function(widget, stdout)
          for line in stdout:gmatch("[^\r\n$]+") do
            local filesystem, size, used, avail, perc, mount =
              line:match('([%p%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d]+)%%%s+([%p%w]+)')

            disks[mount]            = {}
            disks[mount].filesystem = filesystem
            disks[mount].size       = size
            disks[mount].used       = used
            disks[mount].avail      = avail
            disks[mount].perc       = perc
            disks[mount].mount      = mount

            if disks[mount].mount == mounts[1] then
              widget.value = tonumber(disks[mount].perc)
            end
          end

          content:reset(content)
          
          for k,v in ipairs(mounts) do
            local row = createDiskRow(disks[v])

            content:add(row)
          end

        end,
        content
    )

    return content
end

return setmetatable(content, { __call = function(_, ...)
    return worker(...)
end })
