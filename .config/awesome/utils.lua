local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local padding_font = beautiful.padding_font
local lfs_exists, lfs = pcall(require, "lfs") -- let's not crash like crazy if there's no `luafilesystem` module
local naughty = require("naughty")

local utils = {}

-- TODO: actually separate this file. The name is garbage, it's not specific,
-- and a bunch of this stuff should be separate files.

-- Create rounded rectangle shape
utils.rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
        --gears.shape.octogon(cr, width, height, radius)
        --gears.shape.rounded_bar(cr, width, height)
    end
end

utils.rounded_bar = function(width, height)
  return function(cr, width, height)
    gears.shape.rounded_bar(cr, width, height)
  end
end

utils.bubble = function(radius)
    return function(cr, width, height)
        gears.shape.circle(cr, radius, radius)
    end
end

utils.prrect = function(radius, tl, tr, br, bl)
  return function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
  end
end

utils.center_layout = function(widget, valign)
  valign = "center" or valign
  return {
    layout =  wibox.container.place,
    {
      widget = widget,
    },
  }
end

-- Create info bubble shape
-- TODO
-- utils.infobubble = function(radius)
  -- return function(cr, width, height)
    -- gears.shape.infobubble(cr, width, height, radius)
  -- end
-- end

-- Create rectangle shape
utils.rect = function()
    return function(cr, width, height)
        gears.shape.rectangle(cr, width, height)
    end
end

function utils.colorize_text(txt, fg)
    return "<span foreground='" .. fg .."'>" .. txt .. "</span>"
end

function utils.client_menu_toggle()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

function utils.pad_height(size)
    local str = ""
    for i=1, size do
        str = str .. " \n"
    end
    local pad = wibox.widget({
        font = beautiful.padding_font,
        widget = wibox.widget.textbox(str)
        })
    return pad
end

function utils.pad_width(size)
    local str = ""
    for i = 1, size do
        str = str .. " "
    end
    local pad = wibox.widget({
        font = beautiful.padding_font,
        widget = wibox.widget.textbox(str),
        })
    return pad
end

function utils.relative_position(c, direction, margin)
    local workarea = awful.screen.focused().workarea
    local client_geometry = c:geometry()
    if direction == "top" then
        c:geometry({ nil, y = workarea.y + margin * 2, nil, nil })
    elseif direction == "bottom" then
        c:geometry({ nil, y = workarea.height + workarea.y - client_geometry.height - margin * 2 - beautiful.border_width * 2, nil, nil })
    elseif direction == "left" then
        c:geometry({ x = workarea.x + margin * 2, nil, nil, nil })
    elseif direction == "right" then
        c:geometry({ x = workarea.width + workarea.x - client_geometry.width - margin * 2 - beautiful.border_width * 2, nil, nil, nil })
    end
    collectgarbage()
end

function utils.create_titlebar(c, titlebar_buttons, titlebar_position, titlebar_size)
    awful.titlebar(c, {font = beautiful.titlebar_font, position = titlebar_position, size = titlebar_size}) : setup {
        {
            buttons = titlebar_buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {
            buttons = titlebar_buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {
            buttons = titlebar_buttons,
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end


local double_tap_timer = nil
function utils.check_double_tap(double_tap_function)
    if double_tap_timer then
        double_tap_timer:stop()
        double_tap_timer = nil
        double_tap_function()
        -- naughty.notify({text = "We got a double tap"})
        return
    end

    double_tap_timer = gears.timer.start_new(0.20, function()
        double_tap_timer = nil
        return false -- false so the timer doesn't restart automatically
    end)
end

-- @DESCRIPTION:
-- recursively get all filenames that are not directories from a specified path,
-- and put them in `storage_place`
-- @param `storage_place`, table: the table in which to store the found filenames
-- @param `path`, the path from which to begin the search
if lfs_exists then
    function utils.get_files_recursively(storage_place, path)

        local path = path

        -- lets make sure we have a separator at the end
        if string.sub(path, -1, -1) ~= "/" then
            path = path .. '/'
        end

        -- now let's recursively get all of the files in this diretory
        for file in lfs.dir(path) do
            if file ~= '.' and file ~= '..' then
                local full_path_entity = path .. tostring(file)

                -- if it's a dir, recursively go in it
                if lfs.attributes(full_path_entity, "mode") == "directory" then
                    utils.get_files_recursively(storage_place, full_path_entity)

                -- if it's a file, put its name in the `files` table
                elseif lfs.attributes(full_path_entity, "mode") == "file" then
                    table.insert(storage_place, tostring(file))
                end
            end
        end
    end
end

return utils
