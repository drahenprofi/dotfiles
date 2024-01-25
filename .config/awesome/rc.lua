--
--
-- ▄▄▄       █     █░▓█████   ██████  ▒█████   ███▄ ▄███▓▓█████
-- ▒████▄    ▓█░ █ ░█░▓█   ▀ ▒██    ▒ ▒██▒  ██▒▓██▒▀█▀ ██▒▓█   ▀
-- ▒██  ▀█▄  ▒█░ █ ░█ ▒███   ░ ▓██▄   ▒██░  ██▒▓██    ▓██░▒███
-- ░██▄▄▄▄██ ░█░ █ ░█ ▒▓█  ▄   ▒   ██▒▒██   ██░▒██    ▒██ ▒▓█  ▄
--  ▓█   ▓██▒░░██▒██▓ ░▒████▒▒██████▒▒░ ████▓▒░▒██▒   ░██▒░▒████▒
--  ▒▒   ▓▒█░░ ▓░▒ ▒  ░░ ▒░ ░▒ ▒▓▒ ▒ ░░ ▒░▒░▒░ ░ ▒░   ░  ░░░ ▒░ ░
--   ▒   ▒▒ ░  ▒ ░ ░   ░ ░  ░░ ░▒  ░ ░  ░ ▒ ▒░ ░  ░      ░ ░ ░  ░
--   ░   ▒     ░   ░     ░   ░  ░  ░  ░ ░ ░ ▒  ░      ░      ░
--       ░  ░    ░       ░  ░      ░      ░ ░         ░      ░  ░
--
--

local awful = require("awful")
local beautiful = require("beautiful")

require("config.errorhandling")

beautiful.init(awful.util.getdir("config") .. "theme.lua" )
-- window decorations (titlebars)
--require("decorations")

-- init configs
--require("config.wallpaper")
require("config.layout")
require("rules")
require("config.tags")

require("bindings")
require("signals")

-- init daemons
--require("evil")

-- init widgets
require("widgets.dashboard")
require("widgets.topbar")
require("widgets.popup")
--require("widgets.dock")
--require("widgets.notifications")

require("awful.autofocus")


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- autorun programs
awful.spawn.with_shell("~/.config/awesome/config/autorun.sh")


require("widgets.tasklist")
