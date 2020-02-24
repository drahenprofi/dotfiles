---------------------------
-- custom awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = "~/.config/awesome/themes/" -- gfs.get_themes_dir()
local ex_tip = "~/.config/awesome/themes/custom/titlebar/"
local gears = require("gears")

local icon_path = "~/.config/awesome/themes/custom/icons/"

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

theme.highlight = "#EC6A88"
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
theme.bar_height = 28
theme.bar_item_radius = 10
theme.bar_item_padding = 3

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

-- Notificatons
theme.notification_margin = dpi(7)
theme.notification_icon_size = dpi(64)
theme.notification_fg = "#dddddd"
theme.notification_opacity = 0.85
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
theme.menu_submenu_icon = themes_path.."custom/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- regular
theme.titlebar_close_button_normal = ex_tip .. "close/close_1.svg"
theme.titlebar_close_button_focus = ex_tip .. "close/close_2.svg"
theme.titlebar_maximized_button_normal_inactive = ex_tip .. "maximize/maximize_1.svg"
theme.titlebar_maximized_button_focus_inactive  = ex_tip .. "maximize/maximize_2.svg"
theme.titlebar_maximized_button_normal_active = ex_tip .. "maximize/maximize_3.svg"
theme.titlebar_maximized_button_focus_active  = ex_tip .. "maximize/maximize_3.svg"
theme.titlebar_minimize_button_normal = ex_tip .. "minimize/minimize_1.svg"
theme.titlebar_minimize_button_focus  = ex_tip .. "minimize/minimize_2.svg"

-- hover
theme.titlebar_close_button_normal_hover = ex_tip .. "close/close_3.svg"
theme.titlebar_close_button_focus_hover = ex_tip .. "close/close_3.svg"
theme.titlebar_maximized_button_normal_inactive_hover = ex_tip .. "maximize/maximize_3.svg"
theme.titlebar_maximized_button_focus_inactive_hover  = ex_tip .. "maximize/maximize_3.svg"
theme.titlebar_maximized_button_normal_active_hover = ex_tip .. "maximize/maximize_3.svg"
theme.titlebar_maximized_button_focus_active_hover  = ex_tip .. "maximize/maximize_3.svg"
theme.titlebar_minimize_button_normal_hover = ex_tip .. "minimize/minimize_3.svg"
theme.titlebar_minimize_button_focus_hover  = ex_tip .. "minimize/minimize_3.svg"

theme.titlebar_height = 28

theme.wallpaper = themes_path.."custom/wallpaper.jpg"
theme.meme = themes_path.."custom/meme.jpg"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."custom/layouts/fairhw.png"
theme.layout_fairv = themes_path.."custom/layouts/fairvw.png"
theme.layout_floating  = themes_path.."custom/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."custom/layouts/magnifierw.png"
theme.layout_max = themes_path.."custom/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."custom/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."custom/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."custom/layouts/tileleftw.png"
theme.layout_tile = themes_path.."custom/layouts/tilew.png"
theme.layout_tiletop = themes_path.."custom/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."custom/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."custom/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."custom/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."custom/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."custom/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."custom/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Icons
theme.brightness_icon = icon_path.."brightness.png"
theme.volume_up_icon = icon_path.."volume_up.png"
theme.volume_down_icon = icon_path.."volume_down.png"
theme.volume_mute_icon = icon_path.."volume_mute.png"
theme.volume_off_icon = icon_path.."volume_off.png"
theme.launcher_icon = icon_path.."apps.png"
theme.launcher_icon_dark = icon_path.."apps_dark.png"
theme.tag_active_icon = icon_path.."radio_checked_2.png"
theme.tag_inactive_icon = icon_path.."radio_unchecked.png"
theme.battery_alert_icon = icon_path.."battery_alert.png"
theme.battery_charging_icon = icon_path.."battery_charging.png"
theme.battery_full_icon = icon_path.."battery_full.png"
theme.battery_full_icon_dark = icon_path.."battery_full_dark.png"
theme.power_icon = icon_path.."poweroff.png"
theme.reboot_icon = icon_path.."reboot.png"
theme.sleep_icon = icon_path.."sleep.png"
theme.logout_icon = icon_path.."logout.png"
theme.open_panel_icon = icon_path.."open_panel.png"
theme.close_panel_icon = icon_path.."close_panel.png"
theme.settings_icon = icon_path.."settings.png"

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

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
