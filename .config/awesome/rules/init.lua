local awful = require('awful')
local ruled = require('ruled')

ruled.client.connect_signal('request::rules', function()
   -- All clients will match this rule.
   ruled.client.append_rule{
      id         = 'global',
      rule       = {},
      properties = {
         focus     = awful.client.focus.filter,
         raise     = true,
         screen    = awful.screen.preferred,
         placement = awful.placement.no_overlap + awful.placement.no_offscreen
      }
   }

   -- Floating clients.
   ruled.client.append_rule{
      id = 'floating',
      rule_any = {
         instance = {'copyq', 'pinentry', "floating_terminal"},
         class = {
            'Arandr',
            'Blueman-manager',
            'Gpick',
            'Kruler',
            'Sxiv',
            'Tor Browser',
            'Wpa_gui',
            'veromix',
            'xtightvncviewer',
            "feh",
         },
         -- Note that the name property shown in xprop might be set slightly after creation of the client
         -- and the name shown there might not match defined rules here.
         name = {
            'Event Tester',  -- xev.
         },
         role = {
            'AlarmWindow',    -- Thunderbird's calendar.
            'ConfigManager',  -- Thunderbird's about:config.
            'pop-up',         -- e.g. Google Chrome's (detached) Developer Tools.
         }
      },
      properties = {floating = true}
   }

   -- Add titlebars to normal clients and dialogs
   ruled.client.append_rule{
      id         = 'titlebars',
      rule_any   = {type = {'normal', 'dialog'}},
      properties = {titlebars_enabled = true},
   }

    ruled.client.append_rule {
        rule = {class = "Firefox"},
        properties = { maximized  = true } 
    }

    ruled.client.append_rule {
        rule = { class = "Thunar" },
        properties = { floating  = true },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    }

    ruled.client.append_rule {
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
    }

    ruled.client.append_rule {
        rule = {
            class = "jetbrains-.*",
            name = "win.*"
        },
            properties = {
            titlebars_enabled = false,
            floating = true
        }
    }

    -- prevent overflowing of floating clients
    ruled.client.append_rule {
        rule_any = {floating = true},
        callback = function (c)
            local max_height = awful.screen.focused().workarea.height

            if c.height > max_height then
                c.height = max_height
            end
        end
    }
end)
