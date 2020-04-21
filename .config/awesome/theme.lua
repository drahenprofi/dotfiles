---------------------------
-- custom awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local themes_path = "~/.config/awesome/" 
local gears = require("gears")

local icon_path = "~/.config/awesome/icons/"

local theme = {}

theme.font          = "Roboto Medium 9"
theme.titlefont          = "Roboto Bold 9"
theme.fontname          = "Roboto Medium 9"


theme.bg_normal     = "#1C1E26"
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = "#aaaaaa"--theme.bg_normal
theme.bg_systray    = theme.bg_normal
theme.bg_light      = "#232530"
theme.bg_very_light = "#2E303E"

theme.fg_normal     = "#dddddd"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.highlight = "#F43E5C"
theme.highlight_alt = "#B877DB"
theme.misc1 = "#6C6F93"
theme.misc2 = "#2f3240"

theme.useless_gap   = dpi(8)
theme.border_width  = dpi(0)
theme.border_normal = "#2b3539"
theme.border_focus  = "#2b3539"
theme.border_marked = "#2b3539"
theme.rounded_corners = true
theme.border_radius = dpi(6) -- set roundness of corners

-- bar config
theme.bar_position = "top"
theme.bar_height = dpi(28)
theme.bar_item_radius = dpi(10)
theme.bar_item_padding = dpi(3)

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
local taglist_square_size = dpi(0)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

theme.layoutlist_bg_selected = "#2E303E"

-- Notificatons
theme.notification_margin = dpi(7)
theme.notification_icon_size = dpi(64)
theme.notification_fg = "#dddddd"
theme.notification_opacity = 1
theme.notification_spacing = dpi(0)
theme.notification_border_width = dpi(0)
theme.notification_max_width = dpi(350)
--theme.notification_max_height = dpi(78)
theme.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(5))
end

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- regular
theme.titlebar_close_button_normal = icon_path.."titlebar/close/close_1.svg"
theme.titlebar_close_button_focus = icon_path.."titlebar/close/close_2.svg"
theme.titlebar_maximized_button_normal_inactive = icon_path.."titlebar/maximize/maximize_1.svg"
theme.titlebar_maximized_button_focus_inactive  = icon_path.."titlebar/maximize/maximize_2.svg"
theme.titlebar_maximized_button_normal_active = icon_path.."titlebar/maximize/maximize_3.svg"
theme.titlebar_maximized_button_focus_active  = icon_path.."titlebar/maximize/maximize_3.svg"
theme.titlebar_minimize_button_normal = icon_path.."titlebar/minimize/minimize_1.svg"
theme.titlebar_minimize_button_focus  = icon_path.."titlebar/minimize/minimize_2.svg"

-- hover
theme.titlebar_close_button_normal_hover = icon_path.."titlebar/close/close_3.svg"
theme.titlebar_close_button_focus_hover = icon_path.."titlebar/close/close_3.svg"
theme.titlebar_maximized_button_normal_inactive_hover = icon_path.."titlebar/maximize/maximize_3.svg"
theme.titlebar_maximized_button_focus_inactive_hover  = icon_path.."titlebar/maximize/maximize_3.svg"
theme.titlebar_maximized_button_normal_active_hover = icon_path.."titlebar/maximize/maximize_3.svg"
theme.titlebar_maximized_button_focus_active_hover  = icon_path.."titlebar/maximize/maximize_3.svg"
theme.titlebar_minimize_button_normal_hover = icon_path.."titlebar/minimize/minimize_3.svg"
theme.titlebar_minimize_button_focus_hover  = icon_path.."titlebar/minimize/minimize_3.svg"

theme.titlebar_height = dpi(28)

theme.wallpaper = themes_path.."wallpaper.jpg"

-- You can use your own layout icons like this:
theme.layout_fairh = icon_path.."layouts/fairhw.png"
theme.layout_fairv = icon_path.."layouts/fairvw.png"
theme.layout_floating  = icon_path.."layouts/floatingw.png"
theme.layout_magnifier = icon_path.."layouts/magnifierw.png"
theme.layout_max = icon_path.."layouts/maxw.png"
theme.layout_fullscreen = icon_path.."layouts/fullscreenw.png"
theme.layout_tilebottom = icon_path.."layouts/tilebottomw.png"
theme.layout_tileleft   = icon_path.."layouts/tileleftw.png"
theme.layout_tile = icon_path.."layouts/tilew.png"
theme.layout_tiletop = icon_path.."layouts/tiletopw.png"
theme.layout_spiral  = icon_path.."layouts/spiralw.png"
theme.layout_dwindle = icon_path.."layouts/dwindlew.png"
theme.layout_cornernw = icon_path.."layouts/cornernww.png"
theme.layout_cornerne = icon_path.."layouts/cornernew.png"
theme.layout_cornersw = icon_path.."layouts/cornersww.png"
theme.layout_cornerse = icon_path.."layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Icons
theme.brightness_icon = icon_path.."brightness.png"
theme.volume_up_icon = icon_path.."volume_up.png"
theme.volume_up_grey_icon = icon_path.."volume_up_grey.png"
theme.volume_down_icon = icon_path.."volume_down.png"
theme.volume_mute_icon = icon_path.."volume_mute.png"
theme.volume_off_icon = icon_path.."volume_off.png"
theme.launcher_icon = icon_path.."apps.png"
theme.launcher_icon_dark = icon_path.."apps_dark.png"
theme.tag_active_icon = icon_path.."radio_checked_2.png"
theme.tag_inactive_icon = icon_path.."radio_unchecked.png"
theme.battery_alert_icon = icon_path.."battery_alert.png"
theme.battery_alert_grey_icon = icon_path.."battery_alert_grey.png"
theme.battery_charging_icon = icon_path.."battery_charging.png"
theme.battery_charging_grey_icon = icon_path.."battery_charging_grey.png"
theme.battery_full_icon = icon_path.."battery_full.png"
theme.battery_full_grey_icon = icon_path.."battery_full_grey.png"
theme.power_icon = icon_path.."poweroff.png"
theme.power_grey_icon = icon_path.."poweroff_grey.png"
theme.reboot_icon = icon_path.."reboot.png"
theme.reboot_grey_icon = icon_path.."reboot_grey.png"
theme.sleep_icon = icon_path.."sleep.png"
theme.logout_icon = icon_path.."logout.png"
theme.logout_grey_icon = icon_path.."logout_grey.png"
theme.open_panel_icon = icon_path.."open_panel.png"
theme.close_panel_icon = icon_path.."close_panel.png"
theme.settings_icon = icon_path.."settings.png"
theme.settings_grey_icon = icon_path.."settings_grey.png"
theme.notification_icon = icon_path.."notification.png"
theme.notification_grey_icon = icon_path.."notification_grey.png"
theme.notification_none_icon = icon_path.."notifications_none.png"
theme.clear_icon = icon_path.."clear.png"
theme.clear_grey_icon = icon_path.."clear_grey.png"
theme.search_icon = icon_path.."search.png"
theme.search_grey_icon = icon_path.."search_grey.png"
theme.sort_icon = icon_path.."sort.png"
theme.sort_grey_icon = icon_path.."sort_grey.png"
theme.add_icon = icon_path.."add.png"
theme.add_grey_icon = icon_path.."add_grey.png"
theme.left_icon = icon_path.."left.png"
theme.left_grey_icon = icon_path.."left_grey.png"
theme.right_icon = icon_path.."right.png"
theme.right_grey_icon = icon_path.."right_grey.png"
theme.delete_icon = icon_path.."delete.png"
theme.delete_grey_icon = icon_path.."delete_grey.png"
theme.start_icon = icon_path.."start.png"
theme.start_grey_icon = icon_path.."start_grey.png"

-- apps
theme.firefox_icon = icon_path.."firefox.png"
theme.spotify_icon = icon_path.."spotify.png"
theme.folder_icon = icon_path.."folder.png"
theme.intellij_icon = icon_path.."intellij.png"
theme.github_icon = icon_path.."github.png"
theme.reddit_icon = icon_path.."reddit.png"
theme.youtube_icon = icon_path.."youtube.png"
theme.hxh_icon = icon_path.."hxh.png"

-- spotify
theme.play_icon = icon_path.."play.png"
theme.pause_icon = icon_path.."pause.png"
theme.next_icon = icon_path.."next.png"
theme.previous_icon = icon_path.."previous.png"

theme.avatar = icon_path.."fateful.png"
theme.series_icon = icon_path.."series.png"

return theme
