local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local naughty = require("naughty")

local prompt_width = dpi(360)
local prompt_height = dpi(50)

local amp = '&amp'..string.char(0x3B)
local quot = '&quot'..string.char(0x3B)

local prompt = {
    isOpen = false
}

prompt.init = function(s)
    s.prompt_container = wibox {
        screen = s, 
        x = awful.screen.focused().geometry.width / 2 - prompt_width / 2, 
        y = awful.screen.focused().geometry.height / 2 - prompt_height / 2, 
        width = prompt_width,
        height = prompt_height, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        ontop = true,
        visible = false, 
        bg = beautiful.bg_normal, 
    }

    s.prompt_box = awful.widget.prompt({
        prompt = "<b>Run: </b>", 
        font = "Consolas 14", 
        highlighter  = function(b, a)
            -- Add a random marker to delimitate the cursor
            local cmd = b..'ZZZCURSORZZZ'..a
            -- Find shell variables
            local sub = "<span foreground='#CFBA5D'>%1</span>"
            cmd = cmd:gsub('($[A-Za-z][a-zA-Z0-9]*)', sub)
            -- Highlight ' && '
            sub = '<span foreground="#159040">%1</span>'
            cmd = cmd:gsub('( '..amp..amp..')', sub)
            -- Highlight double quotes
            local quote_pos = cmd:find('[^\\]'..quot)
            while quote_pos do
                local old_pos = quote_pos
                quote_pos = cmd:find('[^\\]'..quot, old_pos+2)
                if quote_pos then
                    local content = cmd:sub(old_pos+1, quote_pos+6)
                    cmd = table.concat({
                            cmd:sub(1, old_pos),
                            '<span foreground="#2977CF">',
                            content,
                            '</span>',
                            cmd:sub(quote_pos+7, #cmd)
                    }, '')
                    quote_pos = cmd:find('[^\\]'..quot, old_pos+38)
                end
            end
            -- Split the string back to the original content
            -- (ignore the recursive and escaped ones)
            local pos = cmd:find('ZZZCURSORZZZ')
            b,a = cmd:sub(1, pos-1), cmd:sub(pos+12, #cmd)
            return b,a
        end,
        -- bg_cursor = beautiful.fg_normal
    })

    s.prompt_box.done_callback  = function()
        s.prompt_container.visible = false
    end

    s.prompt_container:setup {
        layout = wibox.layout.align.vertical,
        {
            widget = wibox.widget.separator,
            color  = '#b8d2f82a',
            forced_height = 1,
        },
        {
            {
                layout = wibox.layout.fixed.horizontal, 
                s.prompt_box
            }, 
            left = prompt_height / 2,
            right = prompt_height / 2,
            widget = wibox.container.margin
        }
    }
end

prompt.raise = function()
    for s in screen do
        if s.prompt_container then
            s.prompt_container.visible  = not s.prompt_container.visible

            if s.prompt_container.visible then
                s.prompt_box:run()
            end
        end
    end
end


return prompt