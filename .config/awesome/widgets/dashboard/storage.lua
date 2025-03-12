local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local content = {}

local container = {}

local function createDiskRow(disk)
    local detailText = math.floor((disk.size - disk.used)/1024/1024) .. " GB free"

    return wibox.widget{
        {
            markup = "<span foreground='"..beautiful.fg_dark.."'>"..disk.mount.."</span>",
            font = "JetBrains Mono Bold 10", 
            align = "center",
            widget = wibox.widget.textbox
        },
        {
          {
            min_value = 0, 
            max_value = 100, 
            value = disk.perc,
            start_angle = 3 * math.pi / 2,
            bg = beautiful.misc2, 
            colors = { beautiful.yellow },
            rounded_edge = true, 
            thickness = 10,
            widget = wibox.container.arcchart
          },        
          {
            markup = "<span foreground='"..beautiful.fg_dark.."'>"..disk.perc.."%</span>",
            font = "Roboto Bold 10", 
            align = "center",  
            widget = wibox.widget.textbox
          },
          forced_height = 50, 
          layout = wibox.layout.stack
        }, 
        {
          markup = "<span foreground='"..beautiful.fg_dark.."'>"..detailText.."</span>",
          align = "center", 
          font = "Roboto Medium 9", 
          widget = wibox.widget.textbox
        }, 
        spacing = 8,
        layout = wibox.layout.fixed.vertical
      }
end

local function worker(args)
    local mounts = {"/", "/software", "/data", "/data2"}
    local timeout = 60
    local disks = {}

    content = wibox.layout.grid()
    --content.horizontal_spacing = 4
    content.expand = true
    content.forced_width = 200
    content.vertical_spacing = 24
    content.horizontal_spacing = 54
    content.forced_num_cols = 2

    container = wibox.widget {
      {
        nil, 
        {
          {
            markup = "<span foreground='"..beautiful.highlight_alt.."'>󱛟</span>",
            font = "JetBrains Mono 24",
            forced_width = 36,
            widget = wibox.widget.textbox
          }, 
          {
            markup = "<span foreground='"..beautiful.fg_normal.."'>DRIVES</span>",
            font = "Roboto Bold 14",
            widget = wibox.widget.textbox
          }, 
          layout = wibox.layout.fixed.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
      },
      content,
      spacing = 12,
      layout = wibox.layout.fixed.vertical
    }

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

    return container
end

return setmetatable(container, { __call = function(_, ...)
    return worker(...)
end })
