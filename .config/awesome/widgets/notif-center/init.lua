local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

local notif_header = wibox.widget {
	text   = 'Notification Center',
	font   = 'Roboto Bold 16',
	align  = 'center',
	valign = 'bottom',
	widget = wibox.widget.textbox
}

return wibox.widget {
	layout = wibox.layout.fixed.vertical,
	notif_header, 
	require('widgets.notif-center.build-notifbox')
}