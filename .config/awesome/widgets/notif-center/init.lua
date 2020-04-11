local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

local notif_header = wibox.widget {
	text   = 'Notification Center',
	font   = 'Roboto Bold 16',
	align  = 'left',
	valign = 'bottom',
	widget = wibox.widget.textbox
}

return wibox.widget {
	{
		notif_header,
		nil, 
		require("widgets.notif-center.clear-all"),
		expand = "none", 
		spacing = dpi(10), 
		layout = wibox.layout.align.horizontal,
	},
	require('widgets.notif-center.build-notifbox'), 
	spacing = dpi(10), 
	layout = wibox.layout.fixed.vertical,
}