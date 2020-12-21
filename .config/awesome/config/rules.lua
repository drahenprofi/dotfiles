local awful = require("awful")
local beautiful = require("beautiful")

local keys = require("config.keys")

rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = keys.clientkeys,
                     buttons = keys.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer",
          "feh",
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
    --[[{ rule_any = { class = { "firefox", "Chromium", "Spotify" }
      }, properties = {  titlebars_enabled = false } },]]--
    
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    { rule = { class = "Firefox" },
      properties = { maximized  = true } }, 
    { rule = { class = "Thunar" },
      properties = { floating  = true },
      callback = function (c)
        awful.placement.centered(c,nil)
      end
    }, 
    { rule = { class = "Pavucontrol" },
      properties = { floating  = true },
      callback = function (c)
        c.width = 450
        c.height = 350
        awful.placement.top_right(c, {
          margins = {
            top = beautiful.bar_height + 5, 
            right = 5
          }
        })
      end
    }, 
    { rule = { class = "Lxappearance" },
      properties = { floating  = true },
    }, 
    { rule = { class = "Cisco AnyConnect Secure Mobility Client" },
      properties = { floating = true }, 
      callback = function (c)
        awful.placement.top_right(c, {
          margins = {
            top = beautiful.bar_height + 5, 
            right = 5
          }
        })
      end
    }, 
    {
      rule = {
        class = "jetbrains-.*",
        instance = "sun-awt-X11-XWindowPeer",
        name = "win.*"
      },
      properties = {
          floating = true,
          focus = true,
          focusable = false,
          ontop = true,
          placement = awful.placement.restore,
          buttons = {}, 
          titlebars_enabled = false
      }
    }, 
    { rule = { class = "Visualboyadvance-m" },
      properties = { 
        floating  = true, 
      },
    },
    { rule = { instance = "floating_terminal" },
      properties = { 
        floating  = true, 
      },
    }, 
    { rule = { class = "Spotify" },
      properties = { 
        maximized = true
      },
    },
    {
      -- intellij-idea
      rule = {
        class = "jetbrains-.*",
        name = "win.*"
      },
      properties = {
        titlebars_enabled = false,
        floating = true
      }
    }
}

awful.rules.rules = rules
