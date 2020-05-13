local cairo = require("lgi").cairo
local mouse = mouse
local screen = screen
local wibox = require('wibox')
local table = table
local keygrabber = keygrabber
local math = require('math')
local awful = require('awful')
local gears = require("gears")
local beautiful = require("beautiful")
local timer = gears.timer
local client = client
awful.client = require('awful.client')

local naughty = require("naughty")
local string = string
local tostring = tostring
local tonumber = tonumber
local debug = debug
local pairs = pairs
local unpack = unpack or table.unpack

local surface = cairo.ImageSurface(cairo.Format.RGB24,20,20)
local cr = cairo.Context(surface)

local popupLib = require("components.popup")

local _M = {}

-- settings

_M.settings = {
	preview_box_delay = 50,
}

-- Create a wibox to contain all the client-widgets
_M.preview_wbox = wibox({ 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end, 
})
_M.preview_wbox.border_width = 0
_M.preview_wbox.ontop = true
_M.preview_wbox.visible = false

_M.preview_widgets = {}

_M.altTabTable = {}
_M.altTabIndex = 1

-- simple function for counting the size of a table
function _M.tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

-- this function returns the list of clients to be shown.
function _M.getClients()
	local clients = {}

	-- Get focus history for current tag
	local s = mouse.screen;
	local idx = 0
	local c = awful.client.focus.history.get(s, idx)

	while c do
		table.insert(clients, c)

		idx = idx + 1
		c = awful.client.focus.history.get(s, idx)
	end

	-- Minimized clients will not appear in the focus history
	-- Find them by cycling through all clients, and adding them to the list
	-- if not already there.
	-- This will preserve the history AND enable you to focus on minimized clients

	local t = s.selected_tag
	local all = client.get(s)

	for i = 1, #all do
		local c = all[i]
		local ctags = c:tags();

		-- check if the client is on the current tag
		local isCurrentTag = false
		for j = 1, #ctags do
			if t == ctags[j] then
				isCurrentTag = true
				break
			end
		end

		if isCurrentTag then
			-- check if client is already in the history
			-- if not, add it
			local addToTable = true
			for k = 1, #clients do
				if clients[k] == c then
					addToTable = false
					break
				end
			end


			if addToTable then
				table.insert(clients, c)
			end
		end
	end

	return clients
end

-- here we populate altTabTable using the list of clients taken from
-- _M.getClients(). In case we have altTabTable with some value, the list of the
-- old known clients is restored.
function _M.populateAltTabTable()
	local clients = _M.getClients()

	if _M.tableLength(_M.altTabTable) then
		for ci = 1, #clients do
			for ti = 1, #_M.altTabTable do
				if _M.altTabTable[ti].client == clients[ci] then
					_M.altTabTable[ti].client.opacity = _M.altTabTable[ti].opacity
					_M.altTabTable[ti].client.minimized = _M.altTabTable[ti].minimized
					break
				end
			end
		end
	end

	_M.altTabTable = {}

	for i = 1, #clients do
		table.insert(_M.altTabTable, {
			client = clients[i],
			minimized = clients[i].minimized,
			opacity = clients[i].opacity
		})
	end
end

-- If the length of list of clients is not equal to the length of altTabTable,
-- we need to repopulate the array and update the UI. This function does this
-- check.
function _M.clientsHaveChanged()
	local clients = _M.getClients()
	return _M.tableLength(clients) ~= _M.tableLength(_M.altTabTable)
end

-- This is called any _M.settings.preview_box_fps milliseconds. In case the list
-- of clients is changed, we need to redraw the whole preview box. Otherwise, a
-- simple widget::updated signal is enough
function _M.updatePreview()
	if _M.clientsHaveChanged() then
		_M.populateAltTabTable()
		_M.preview()
	end

	for i = 1, #_M.preview_widgets do
		_M.preview_widgets[i]:emit_signal("widget::updated")
	end
end

function _M.cycle(dir)
	-- Switch to next client
	_M.altTabIndex = _M.altTabIndex + dir
	if _M.altTabIndex > #_M.altTabTable then
		_M.altTabIndex = 1 -- wrap around
	elseif _M.altTabIndex < 1 then
		_M.altTabIndex = #_M.altTabTable -- wrap around
	end

	_M.updatePreview()

	_M.altTabTable[_M.altTabIndex].client.minimized = false
end

function _M.preview()
	-- Apply settings
    _M.preview_wbox:set_bg(beautiful.bg_normal)

	-- cols in the grid view
	local cols = 3
	if #_M.altTabTable == 4 then
		cols = 2
	end 

	-- Make the wibox the right size, based on the number of clients
    local w = 150 -- widget width
	local h = w * 0.75 -- widget height
	local innerMargin = 10
	local outerMargin = 10
	local spacing = 10
	local textboxHeight = w * 0.125
	local W = (w + 2 * innerMargin) * math.min(cols, #_M.altTabTable) 
		+ (math.min(cols, #_M.altTabTable) - 1) * spacing 
		+ 2 * outerMargin
	local H = (h + textboxHeight + 2 * (innerMargin)) * math.ceil(#_M.altTabTable / cols) 
		+ spacing * (math.ceil(#_M.altTabTable / cols) - 1)
		+ 2 * outerMargin

	local x = (screen[mouse.screen].geometry.width - W) / 2
	local y = (screen[mouse.screen].geometry.height - H) / 2
	_M.preview_wbox:geometry({x = x, y = y, width = W, height = H})

	-- create a list that holds the clients to preview, from left to right
	local leftRightTab = {}
	local leftRightTabToAltTabIndex = {} -- save mapping from leftRightTab to altTabTable as well
	local nLeft
	local nRight
	if #_M.altTabTable == 2 then
		nLeft = 0
		nRight = 2
	else
		nLeft = math.floor(#_M.altTabTable / 2)
		nRight = math.ceil(#_M.altTabTable / 2)
	end

	for i = 1, nLeft do
		table.insert(leftRightTab, _M.altTabTable[#_M.altTabTable - nLeft + i].client)
		table.insert(leftRightTabToAltTabIndex, #_M.altTabTable - nLeft + i)
	end
	for i = 1, nRight do
		table.insert(leftRightTab, _M.altTabTable[i].client)
		table.insert(leftRightTabToAltTabIndex, i)
	end

	_M.preview_widgets = {}

	--naughty.notify({text = test})
	-- create all the widgets
	for i = 1, #leftRightTab do
		local c = leftRightTab[i]

		local preview_img = wibox.widget.base.make_widget()
		preview_img.fit = function(preview_widget, width, height)
			return w, h
		end
		preview_img.draw = function(preview_img, preview_wbox, cr, width, height)
			local cg = c:geometry()
			local tx, ty, sx, sy
			tx = 0 
			ty = 0
			if cg.width > cg.height then
				sx = w / cg.width
				sy = math.min(sx, h / cg.height)
			else
				sy = h / cg.height
				sx = math.min(sy, h / cg.width)
			end
			tx = (w - sx * cg.width) / 2
			ty = (h - sy * cg.height) / 2

			local tmp = gears.surface(c.content)
			cr:translate(tx, ty)
			cr:scale(sx, sy)
			cr:set_source_surface(tmp, 0, 0)
			cr:paint()
			tmp:finish()
		end

		local bg = beautiful.bg_light

		if c == _M.altTabTable[_M.altTabIndex].client then
			bg = beautiful.bg_very_light
		end
        
        local client_widget = wibox.widget {
			{
				{
					preview_img, 
					{
						{
							image = c.icon, 
							widget = wibox.widget.imagebox
						}, 
						{
							font = "Roboto Bold 10", 
							markup = c.class, 
							widget = wibox.widget.textbox
						}, 
						spacing = 5, 
						forced_width = w, 
						forced_height = textboxHeight, 
						layout = wibox.layout.fixed.horizontal
					}, 
					layout = wibox.layout.fixed.vertical
				}, 
				margins = innerMargin, 
				widget = wibox.container.margin
			}, 
			bg = bg, 
			widget = wibox.container.background
		}

		local container = wibox.widget {
			client_widget, 
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
			end, 
			widget = wibox.container.background
		}
		
		container:connect_signal("widget::updated", function() 
			bg = beautiful.bg_light

			if c == _M.altTabTable[_M.altTabIndex].client then
				bg = beautiful.bg_very_light
			end
			client_widget.bg = bg
		end)
		
        _M.preview_widgets[i] = container

	end

	--layout
    preview_layout = wibox.layout.grid()
	preview_layout.forced_num_cols = cols
	preview_layout.spacing = spacing

	for i = 1, #leftRightTab do
		preview_layout:add(_M.preview_widgets[i])
	end

	_M.preview_wbox:set_widget(wibox.widget {
		popupLib.separator(), 
		{
			preview_layout,
			margins = outerMargin, 
			widget = wibox.container.margin
		}, 
		layout = wibox.layout.fixed.vertical
	})
end


-- This starts the timer for updating and it shows the preview UI.
function _M.showPreview()
	_M.preview()
	_M.preview_wbox.visible = true
end

function _M.switch(dir, mod_key1, release_key, mod_key2, key_switch)
	_M.populateAltTabTable()

	if #_M.altTabTable == 0 then
		return
	end

	-- reset index
	_M.altTabIndex = 1

	-- preview delay timer
	local previewDelay = _M.settings.preview_box_delay / 1000
	_M.previewDelayTimer = timer({timeout = previewDelay})
	_M.previewDelayTimer:connect_signal("timeout", function()
		_M.previewDelayTimer:stop()
		_M.showPreview()
	end)
	_M.previewDelayTimer:start()

	-- Now that we have collected all windows, we should run a keygrabber
	-- as long as the user is alt-tabbing:
	keygrabber.run(
		function (mod, key, event)
			-- Stop alt-tabbing when the alt-key is released
			if gears.table.hasitem(mod, mod_key1) then
				if (key == release_key or key == "Escape") and event == "release" then
					if _M.preview_wbox.visible == true then
						_M.preview_wbox.visible = false
					end

					if key == "Escape" then
						for i = 1, #_M.altTabTable do
							_M.altTabTable[i].client.opacity = _M.altTabTable[i].opacity
							_M.altTabTable[i].client.minimized = _M.altTabTable[i].minimized
						end
					else
						-- Raise clients in order to restore history
						local c
						for i = 1, _M.altTabIndex - 1 do
							c = _M.altTabTable[_M.altTabIndex - i].client
							if not _M.altTabTable[i].minimized then
								c:raise()
								client.focus = c
							end
						end

						-- raise chosen client on top of all
						c = _M.altTabTable[_M.altTabIndex].client
						c:raise()
						client.focus = c

						-- restore minimized clients
						for i = 1, #_M.altTabTable do
							if i ~= _M.altTabIndex and _M.altTabTable[i].minimized then
								_M.altTabTable[i].client.minimized = true
							end
							_M.altTabTable[i].client.opacity = _M.altTabTable[i].opacity
						end
					end

					keygrabber.stop()
				
				elseif key == key_switch and event == "press" then
					if gears.table.hasitem(mod, mod_key2) then
						-- Move to previous client on Shift-Tab
						_M.cycle(-1)
					else
						-- Move to next client on each Tab-press
						_M.cycle( 1)
					end
				end
			end
		end
	)

	-- switch to next client
	_M.cycle(dir)

end -- function altTab

return {switch = _M.switch, settings = _M.settings}
