local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local hotkeys_popup = require("awful.hotkeys_popup")

-- Define mod key
local modkey = "Mod4"
local altkey = "Mod1"

local keys = {}
local apps = require("config.apps")

keys.desktopbuttons = gears.table.join(
    --awful.button({ }, 1, sidepanel.toggle)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
)

keys.globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ altkey,           }, "Tab",
      function ()
          apps.switcher.switch( 1, "Mod1", "Alt_L", "Shift", "Tab")
      end),
    
    awful.key({ altkey, "Shift"   }, "Tab",
      function ()
          apps.switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
      end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(apps.terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- master height & width
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "k",     function () awful.tag.incmhfact( 0.05)          end,
              {description = "increase master height factor", group = "layout"}),
    awful.key({ modkey,           }, "j",     function () awful.tag.incmhfact(-0.05)          end,
              {description = "decrease master height factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    -- switch layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ modkey },            "r", function () awful.util.spawn(apps.launcher) end),
    awful.key({ modkey }, "p",     function () awful.spawn(apps.xrandr) end),
    awful.key({ modkey, "Shift" }, "p",     function () awful.spawn(apps.screenshot) end),
     
    -- media controls
    awful.key({}, "XF86AudioLowerVolume", function ()
        awful.spawn.easy_async_with_shell("pactl set-sink-volume 0 -3%  ; pamixer --get-volume", function(stdout)
            local volume = stdout
            awful.spawn.easy_async_with_shell("pamixer --get-muted", function(stdout)
                local muted = false
                if stdout == "true" then 
                    muted = true
                end
                
                apps.notifications.volume(tonumber(volume), muted)
            end)
        end)
    end),
    awful.key({}, "XF86AudioRaiseVolume", function ()
        awful.spawn.easy_async_with_shell("pactl set-sink-volume 0 +3% ; pamixer --get-volume", function(stdout)
            local volume = stdout
            awful.spawn.easy_async_with_shell("pamixer --get-muted", function(stdout)
                local muted = false
                if stdout == "true" then 
                    muted = true
                end
                
                apps.notifications.volume(tonumber(volume), muted)
            end)
        end)
    end),
    awful.key({}, "XF86AudioMute", function ()
        awful.spawn.easy_async_with_shell("pamixer -t ; pamixer --get-muted", function(stdout)
            local muted = false
            if stdout == "true" then 
                muted = true
            end
                
            apps.notifications.volume(0, muted)
        end)
    end),

    -- Brightness
   awful.key({ }, "XF86MonBrightnessDown", function ()
       awful.spawn.easy_async_with_shell("brightnessctl set 10%- > /dev/null ; echo $(($(brightnessctl get) * 100 / $(brightnessctl max)))", function(stdout)
           local brightness = stdout:gsub("%D+", "")
           apps.notifications.brightness(brightness, false)
       end)
   end),
   awful.key({ }, "XF86MonBrightnessUp", function ()
       awful.spawn.easy_async_with_shell("brightnessctl set +10% > /dev/null ; echo $(($(brightnessctl get) * 100 / $(brightnessctl max)))", function(stdout)
           local brightness = stdout:gsub("%D+", "")
           apps.notifications.brightness(brightness, false)
    end)
end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keys.globalkeys = gears.table.join(keys.globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
    )
end

keys.clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ altkey    }, "F4",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "Up",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}), 
    awful.key({ modkey             }, "c", awful.placement.centered), 
    awful.key({ modkey, "Shift"    }, "c", function(c)
        c.width = 560
        c.height = 295
        
        awful.placement.top_right(c, {
            margins = {
              top = beautiful.bar_height + 5, 
              right = 5
            }
          })
    end)
)

keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

return keys