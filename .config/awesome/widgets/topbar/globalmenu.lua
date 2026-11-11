---------------------------------------------------------------------------
-- globalmenu.lua -- a macOS-style global application menu for AwesomeWM
--
-- Supported applications
--   * dbusmenu backend: Qt 5.7+/6 and KDE apps, Chromium/Electron, JetBrains
--     IDEs, LibreOffice (qt/kf5 VCL plugin), ... These apps export their
--     menubar when com.canonical.AppMenu.Registrar exists on the session bus,
--     which this module provides.
--   * GTK backend: GtkApplication apps (GTK3 and GTK4) with a menubar model
--     set via gtk_application_set_menubar (exported natively), and plain
--     GTK2/GTK3 apps with a GtkMenuBar when appmenu-gtk-module is loaded.
--     These announce their menu through the _GTK_UNIQUE_BUS_NAME /
--     _GTK_MENUBAR_OBJECT_PATH window properties and speak org.gtk.Menus +
--     org.gtk.Actions. GTK4 apps that embed their own GtkPopoverMenuBar
--     (instead of using set_menubar) export nothing and can't be shown.
--
-- Usage (rc.lua)
--   beautiful.init(...)
--   local globalmenu = require("globalmenu")   -- before any autostart!
--   ...
--   -- inside awful.screen.connect_for_each_screen, in the wibar's left part:
--   globalmenu.widget { screen = s },
--   ...
--   -- optional keybinding that opens the whole menu as one cascading menu:
--   awful.key({ modkey }, "F10", globalmenu.show_all)
--
-- Built-in menus
--   * The bold application name opens an app menu: "New Window" and the
--     actions from the app's .desktop file, window controls (minimize,
--     maximize, floating, on top, sticky, move to tag), Close and Quit.
--     It is there for every client, also for apps without a menu of their own.
--   * Without a focused client the bar shows a desktop menu: an "awesome"
--     menu (hotkeys, terminal, config, restart, quit), one menu per XDG
--     folder (Downloads, Documents, Music, Pictures, Videos; newest files
--     first) and Tag (layout, restore minimized).
--   * Both are plain Lua and can be replaced, see M.config.app_menu and
--     M.config.desktop below and the item format at the "builtin backend".
--
-- GTK setup (once, outside awesome; then restart your GTK apps):
--   export GTK_MODULES="${GTK_MODULES:+$GTK_MODULES:}appmenu-gtk-module"
--   ~/.config/gtk-3.0/settings.ini:  [Settings] gtk-shell-shows-menubar=1
--   ~/.config/gtk-4.0/settings.ini:  [Settings] gtk-shell-shows-menubar=1
--   ~/.gtkrc-2.0:                    gtk-shell-shows-menubar=1
---------------------------------------------------------------------------
local lgi       = require("lgi")
local Gio       = lgi.Gio
local GLib      = lgi.GLib
local GObject   = lgi.GObject
local GdkPixbuf = lgi.GdkPixbuf

local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local REG_NAME  = "com.canonical.AppMenu.Registrar"
local REG_PATH  = "/com/canonical/AppMenu/Registrar"
local DBUSMENU  = "com.canonical.dbusmenu"
local GTK_MENUS = "org.gtk.Menus"
local GTK_ACTS  = "org.gtk.Actions"
-- dbusmenu registrations are mirrored into X properties on the client window
-- so they survive `awesome.restart()` (apps only register once).
local PROP_SVC  = "_AWESOME_APPMENU_SERVICE"
local PROP_PATH = "_AWESOME_APPMENU_PATH"
-- set by GTK itself / appmenu-gtk-module
local GTK_PROPS = {
    bus     = "_GTK_UNIQUE_BUS_NAME",
    menubar = "_GTK_MENUBAR_OBJECT_PATH",
    app     = "_GTK_APPLICATION_OBJECT_PATH",
    win     = "_GTK_WINDOW_OBJECT_PATH",
    app_id  = "_GTK_APPLICATION_ID",
}

local M = {
    config = {
        show_app_name  = true,   -- bold application name before the menus
        show_shortcuts = true,   -- show "Ctrl+Q" right-aligned in menu entries
        -- Shortcut look: drawn at this opacity (follows the item's normal and
        -- highlighted colors), or in a fixed color if shortcut_fg is set.
        shortcut_opacity = beautiful.globalmenu_shortcut_opacity or 0.6,
        shortcut_fg      = beautiful.globalmenu_shortcut_fg,
        -- Submenu arrow: an image (path or surface), or a text such as "›".
        -- nil = your theme's (menu_submenu_icon / menu_submenu).
        submenu_icon   = beautiful.globalmenu_submenu_icon,
        submenu_text   = beautiful.globalmenu_submenu_text,
        show_icons     = true,
        menu_width     = 280,
        -- Fonts, e.g. "Inter 10". nil = your theme's font (beautiful.font,
        -- beautiful.menu_font for the dropdowns). menu_height = nil fits the
        -- item height to the menu font.
        font           = beautiful.globalmenu_font,
        menu_font      = beautiful.globalmenu_menu_font,
        menu_height    = beautiful.globalmenu_menu_height,
        -- Menu border. nil = your theme's menu_border_width / menu_border_color.
        menu_border_width = beautiful.globalmenu_border_width,
        menu_border_color = beautiful.globalmenu_border_color,
        -- Rounded menus: a corner radius in px or a gears.shape function(cr, w, h).
        -- The border follows the shape; menu_padding (default 4) keeps the items
        -- off the edge. Smooth corners need a compositor (picom, ...).
        menu_shape     = beautiful.globalmenu_shape,
        menu_padding   = beautiful.globalmenu_padding,
        -- Mouse cursor over clickable menu items and bar entries, e.g. "hand2"
        -- (or "pointer" if your cursor theme has it). nil = no change.
        cursor         = beautiful.globalmenu_cursor,
        disabled_fg    = beautiful.globalmenu_disabled_fg or "#7f7f7f",
        item_padding   = 6,      -- horizontal padding of each top-level entry
        close_on_outside_click = true, -- a click outside the open menu closes it
        timeout        = 2000,   -- D-Bus call timeout in ms

        -- true = M.default_app_menu, false = plain label, or function(c) -> items
        app_menu       = true,
        -- true = M.default_desktop_menu, false = empty bar without a client, or
        -- function(s) -> { name = "...", items = {...}, menus = { {label=, children=}, ... } }
        desktop        = true,
        desktop_name   = "awesome",
        terminal       = os.getenv("TERMINAL") or "xterm",
        -- "Edit Config" opens your config folder with this editor. It can be a
        -- table with arguments, e.g. { "code-oss", "--new-window" }. Terminal
        -- editors run inside `terminal`; set editor_in_terminal = false for
        -- graphical ones. (nano can't open folders.)
        editor         = os.getenv("EDITOR") or "nano",
        editor_in_terminal = true,
        files_limit    = 30,     -- entries per folder menu
    },
}

local bus           = Gio.bus_get_sync(Gio.BusType.SESSION)
local registry      = {}     -- [xid] = { service = ":1.42", path = "/MenuBar/1" }
local own_registrar = false  -- false if another process owns the registrar name
local instances     = setmetatable({}, { __mode = "k" }) -- layout -> screen|false

-- What is currently shown. `gen` invalidates late async replies.
local state = { gen = 0 }

for _, name in ipairs({ PROP_SVC, PROP_PATH, GTK_PROPS.bus, GTK_PROPS.menubar,
                        GTK_PROPS.app, GTK_PROPS.win, GTK_PROPS.app_id }) do
    pcall(awesome.register_xproperty, name, "string") -- may already be registered
end

---------------------------------------------------------------------------
-- Small helpers
---------------------------------------------------------------------------
-- Messages also go to M._log, so they can be read without finding awesome's
-- stderr:  awesome-client 'return table.concat(require("globalmenu")._log, "\n")'
M._log = {}
local function log(...)
    local msg = table.concat({ ... }, " ")
    io.stderr:write("globalmenu: ", msg, "\n")
    table.insert(M._log, os.date("%H:%M:%S ") .. msg)
    if #M._log > 30 then table.remove(M._log, 1) end
end

local function client_for_xid(xid)
    for _, c in ipairs(client.get()) do
        if c.window == xid then return c end
    end
end

-- GLib.Variant -> plain Lua value (recursively)
local function unvariant(v)
    local t = v.type
    if t == "v" then return unvariant(v:get_variant()) end
    if t == "ay" then return v:get_data_as_bytes():get_data() end
    if v:is_container() then
        local out = {}
        for i = 0, v:n_children() - 1 do
            out[i + 1] = unvariant(v:get_child_value(i))
        end
        return out
    end
    return v.value
end

-- a{sv} -> Lua table
local function props_of(dict)
    local t = {}
    for i = 0, dict:n_children() - 1 do
        local entry = dict:get_child_value(i)
        t[entry:get_child_value(0).value] = unvariant(entry:get_child_value(1))
    end
    return t
end

-- Async D-Bus call; cb(result_variant_or_nil, err). `quiet` suppresses logging.
local function call(service, path, iface, method, params, reply_type, cb, quiet)
    bus:call(service, path, iface, method, params,
        reply_type and GLib.VariantType(reply_type) or nil,
        Gio.DBusCallFlags.NONE, M.config.timeout, nil,
        function(conn, res)
            local ret, err = conn:call_finish(res)
            if not ret and not quiet then log(iface .. "." .. method, "failed:", tostring(err)) end
            if cb then cb(ret, err) end
        end)
end

-- Run several async jobs (functions taking a `done` callback), then `finish`.
local function all(jobs, finish)
    local left = #jobs
    if left == 0 then return finish() end
    for _, job in ipairs(jobs) do
        job(function()
            left = left - 1
            if left == 0 then finish() end
        end)
    end
end

-- Both protocols use "_F" for mnemonics and "__" for a literal "_".
-- awful.menu uses "&F" (underlined + keyboard accelerator).
local function convert_label(label, mnemonic_char)
    local first = true
    local out = (label or ""):gsub("__", "\1"):gsub("_", function()
        if first and mnemonic_char then
            first = false
            return mnemonic_char
        end
        return ""
    end):gsub("\1", "_")
    return out
end

local MOD_NAMES = { primary = "Ctrl", control = "Ctrl", ctrl = "Ctrl", shift = "Shift",
                    alt = "Alt", mod1 = "Alt", super = "Super", meta = "Meta" }

-- X keysym names (Electron, GTK) and Qt key names -> what's printed on the key
local KEY_NAMES = {
    comma = ",", period = ".", minus = "-", equal = "=", plus = "+", grave = "`",
    apostrophe = "'", semicolon = ";", slash = "/", backslash = "\\",
    bracketleft = "[", bracketright = "]", space = "Space", ["return"] = "Enter",
    escape = "Esc", delete = "Del", backspace = "Backspace", insert = "Ins",
    prior = "PgUp", next = "PgDn", page_up = "PgUp", page_down = "PgDn", pgup = "PgUp", pgdown = "PgDn",
    up = "↑", down = "↓", left = "←", right = "→",
    kp_add = "Num +", kp_subtract = "Num -", kp_multiply = "Num *", kp_divide = "Num /",
}

local function format_keys(mods, key)
    key = KEY_NAMES[key:lower()] or key
    if #key == 1 then key = key:upper() end
    mods[#mods + 1] = key
    return table.concat(mods, "+")
end

-- Some apps put the shortcut into the label: "Open\tCtrl+O" (common in Qt and
-- Windows-style apps), or "Open Folder... [Ctrl+K Ctrl+O]" (VS Code does this
-- for shortcuts Electron can't express, like chords).
local MODIFIER_WORDS = { ctrl = true, control = true, alt = true, shift = true,
                         super = true, meta = true, cmd = true, win = true }

local function split_shortcut(label)
    local text, keys = label:match("^(.-)\t+(.+)$")
    if not text then
        text, keys = label:match("^(.-)%s+%[([^%[%]]+)%]$")
        local looks_like_keys = keys and keys:match("^F%d%d?$")
        for word in (keys or ""):gmatch("%a+") do
            if MODIFIER_WORDS[word:lower()] then looks_like_keys = true end
        end
        if not looks_like_keys then return label, nil end
    end
    return text, (keys:gsub("__", "_"))
end

---------------------------------------------------------------------------
-- Both backends produce the same node format:
--   { key, label, visible, enabled, separator, header, submenu, children,
--     toggle = "checkmark"|"radio"|nil, checked, shortcut, icon_name,
--     icon_data, activate = function() }
-- and implement: load_top(target, cb(root)), load_menu(target, node, cb(node)),
-- subscribe(target, on_change), release(target), closed(target, node).
---------------------------------------------------------------------------
local backends = {}

---------------------------------------------------------------------------
-- dbusmenu backend (com.canonical.dbusmenu)
---------------------------------------------------------------------------
local dbusmenu = {}
backends.dbusmenu = dbusmenu

local function dm_call(target, method, params, reply_type, cb)
    call(target.service, target.path, DBUSMENU, method, params, reply_type, cb)
end

-- (ia{sv}av) -> node
local function dm_parse(target, v)
    local id = v:get_child_value(0).value
    local p  = props_of(v:get_child_value(1))
    local node = {
        key       = id,
        id        = id,
        label     = p.label or "",
        visible   = p.visible ~= false,
        enabled   = p.enabled ~= false,
        separator = p.type == "separator",
        icon_name = p["icon-name"],
        icon_data = p["icon-data"],
        children  = {},
    }
    if p["toggle-type"] == "checkmark" or p["toggle-type"] == "radio" then
        node.toggle, node.checked = p["toggle-type"], p["toggle-state"] == 1
    end
    if type(p.shortcut) == "table" and type(p.shortcut[1]) == "table" and #p.shortcut[1] > 0 then
        local keys = {}
        for i = 1, #p.shortcut[1] - 1 do
            local k = p.shortcut[1][i]
            keys[i] = MOD_NAMES[k:lower()] or k
        end
        node.shortcut = format_keys(keys, p.shortcut[1][#p.shortcut[1]])
    end
    local kids = v:get_child_value(2)
    for i = 0, kids:n_children() - 1 do
        node.children[#node.children + 1] = dm_parse(target, kids:get_child_value(i):get_variant())
    end
    node.submenu  = p["children-display"] == "submenu" or #node.children > 0
    node.activate = function()
        dm_call(target, "Event", GLib.Variant("(isvu)", { id, "clicked", GLib.Variant("i", 0), 0 }))
    end
    return node
end

local function dm_get_layout(target, id, depth, cb)
    dm_call(target, "GetLayout", GLib.Variant("(iias)", { id, depth, {} }),
        "(u(ia{sv}av))", function(ret)
            cb(ret and dm_parse(target, ret:get_child_value(1)) or nil)
        end)
end

function dbusmenu.load_top(target, cb)
    dm_get_layout(target, 0, 1, cb) -- depth 1: only the bar entries
end

-- Many apps only fill a submenu when it receives AboutToShow (most Qt/KDE
-- apps, "Recent files" menus, and Electron, which builds every submenu
-- lazily). So: announce the menu, read it, announce the submenus that
-- appeared, read again -- until no new submenus show up.
local function dm_announce(target, ids, done)
    dm_call(target, "AboutToShowGroup", GLib.Variant("(ai)", { ids }), "(aiai)", function(ret)
        if ret then return done() end
        -- AboutToShowGroup is optional in the spec: fall back to one call per menu
        local jobs = {}
        for _, sid in ipairs(ids) do
            jobs[#jobs + 1] = function(job_done)
                dm_call(target, "AboutToShow", GLib.Variant("(i)", { sid }), "(b)", job_done)
            end
        end
        all(jobs, done)
    end)
end

-- Announce every submenu we haven't announced yet, re-read, and repeat
-- until nothing new shows up. Submenus are remembered by their label path,
-- not by id: apps like Firefox fill menus asynchronously and may hand out
-- new ids for the same entries, which must not start the cycle again.
local function dm_settle(target, id, tree, seen, cb)
    local rounds = 0
    local function round(t)
        local fresh = {}
        local function walk(node, path)
            for _, child in ipairs(node.children) do
                if child.submenu then
                    local p = path .. "\0" .. (child.label or "")
                    if not seen[p] then
                        seen[p] = true
                        fresh[#fresh + 1] = child.id
                    end
                    walk(child, p)
                end
            end
        end
        walk(t, "")
        rounds = rounds + 1
        if #fresh == 0 or rounds > 8 then return cb(t) end
        dm_announce(target, fresh, function()
            dm_get_layout(target, id, -1, function(t2)
                if t2 then round(t2) else cb(t) end
            end)
        end)
    end
    round(tree)
end

-- `seen` is shared by one opening of a menu and its later re-reads.
function dbusmenu.load_menu(target, node, cb, seen)
    local id = node.id
    dm_call(target, "AboutToShow", GLib.Variant("(i)", { id }), "(b)", function()
        dm_get_layout(target, id, -1, function(tree)
            if not tree then return cb(nil) end
            dm_settle(target, id, tree, seen or {}, cb)
        end)
    end)
end

-- Re-read an open menu after the app changed it. The menu itself is not
-- announced again (that would make apps like Firefox fill it again, and
-- again ...), but submenus that appeared since then are.
function dbusmenu.reload_menu(target, node, cb, seen)
    dm_get_layout(target, node.id, -1, function(tree)
        if not tree then return cb(nil) end
        dm_settle(target, node.id, tree, seen or {}, cb)
    end)
end

function dbusmenu.subscribe(target, changed)
    target.subs = {
        bus:signal_subscribe(target.service, DBUSMENU, "LayoutUpdated", target.path,
            nil, Gio.DBusSignalFlags.NONE, changed),
        bus:signal_subscribe(target.service, DBUSMENU, "ItemsPropertiesUpdated", target.path,
            nil, Gio.DBusSignalFlags.NONE, changed),
    }
end

function dbusmenu.release(target)
    for _, id in ipairs(target.subs or {}) do bus:signal_unsubscribe(id) end
    target.subs = nil
end

function dbusmenu.closed() end

---------------------------------------------------------------------------
-- GTK backend (org.gtk.Menus + org.gtk.Actions)
--
-- A menu model is split into numbered groups of menus; items link to other
-- menus through ":section" and ":submenu" attributes. Items name an action
-- ("app.quit", "win.wrap", "unity.-New") whose prefix selects the object path
-- the action lives on, and whose state gives us check/radio marks.
---------------------------------------------------------------------------
local gtk = {}
backends.gtk = gtk

-- lgi hands out integers as floats; "%d" keeps the keys stable
local function menu_key(g, m) return string.format("%d:%d", g, m) end

local function gtk_action_path(target, prefix)
    return target.paths[prefix] or target.path
end

-- Subscribe to `groups`, storing their menus into `menus`.
local function gtk_start(target, groups, menus, subscribed, cb)
    call(target.service, target.path, GTK_MENUS, "Start", GLib.Variant("(au)", { groups }),
        "(a(uuaa{sv}))", function(ret)
            if not ret then return cb(false) end
            for _, g in ipairs(groups) do subscribed[#subscribed + 1] = g end
            local list = ret:get_child_value(0)
            for i = 0, list:n_children() - 1 do
                local entry = list:get_child_value(i)
                local g, m  = entry:get_child_value(0).value, entry:get_child_value(1).value
                local arr   = entry:get_child_value(2)
                local items = {}
                for j = 0, arr:n_children() - 1 do
                    local dict = arr:get_child_value(j)
                    local item = props_of(dict)
                    item._target = dict:lookup_value("target", nil) -- keep the typed variant
                    items[j + 1] = item
                end
                menus[menu_key(g, m)] = items
            end
            cb(true)
        end)
end

-- Load the whole menu model: group 0, then every group a link points to.
local function gtk_load_menus(target, cb)
    local menus, subscribed, seen = {}, {}, { [0] = true }
    local function step(groups)
        gtk_start(target, groups, menus, subscribed, function(ok)
            if not ok then return cb(nil, subscribed) end
            local missing = {}
            for _, items in pairs(menus) do
                for _, item in ipairs(items) do
                    for _, link in ipairs({ item[":section"] or false, item[":submenu"] or false }) do
                        if link and not seen[link[1]] then
                            seen[link[1]] = true
                            missing[#missing + 1] = link[1]
                        end
                    end
                end
            end
            if #missing > 0 then step(missing) else cb(menus, subscribed) end
        end)
    end
    step({ 0 })
end

-- DescribeAll on every action prefix the menus use.
local function gtk_load_actions(target, menus, cb)
    local prefixes = {}
    for _, items in pairs(menus) do
        for _, item in ipairs(items) do
            for _, name in ipairs({ item.action or false, item["submenu-action"] or false }) do
                local prefix = name and name:match("^([^.]+)%.")
                if prefix then prefixes[prefix] = true end
            end
        end
    end
    local actions, jobs = {}, {}
    for prefix in pairs(prefixes) do
        jobs[#jobs + 1] = function(done)
            call(target.service, gtk_action_path(target, prefix), GTK_ACTS, "DescribeAll", nil,
                "(a{s(bgav)})", function(ret)
                    local acts = {}
                    if ret then
                        local dict = ret:get_child_value(0)
                        for i = 0, dict:n_children() - 1 do
                            local entry = dict:get_child_value(i)
                            local desc  = entry:get_child_value(1)
                            local st    = desc:get_child_value(2)
                            local value -- (no `a and b or c` here: the state may be `false`)
                            if st:n_children() > 0 then value = unvariant(st:get_child_value(0)) end
                            acts[entry:get_child_value(0).value] = {
                                enabled = desc:get_child_value(0).value,
                                state   = value,
                            }
                        end
                    end
                    actions[prefix] = acts
                    done()
                end)
        end
    end
    all(jobs, function() cb(actions) end)
end

local function gtk_split(name)
    if type(name) ~= "string" then return nil end
    return name:match("^([^.]+)%.(.+)$")
end

local function gtk_item_node(target, item, actions, key, build)
    local prefix, short = gtk_split(item.action)
    local info   = prefix and actions[prefix] and actions[prefix][short]
    local hidden = item["hidden-when"]
    local node = {
        key       = key,
        label     = item.label or "",
        visible   = not ((hidden == "action-missing" and not info) or
                         (hidden == "action-disabled" and not (info and info.enabled))),
        children  = {},
        submenu_action = item["submenu-action"],
    }
    if type(item.icon) == "table" and item.icon[1] == "themed" and type(item.icon[2]) == "table" then
        node.icon_name = item.icon[2][1]
    end
    if type(item.accel) == "string" and item.accel ~= "" then
        local mods = {}
        local key_name = item.accel:gsub("<(%w+)>", function(m)
            mods[#mods + 1] = MOD_NAMES[m:lower()] or m
            return ""
        end)
        node.shortcut = format_keys(mods, key_name)
    end
    if item[":submenu"] then
        node.submenu  = true
        node.enabled  = not info or info.enabled
        node.children = build(item[":submenu"][1], item[":submenu"][2], key)
        return node
    end
    node.enabled = info ~= nil and info.enabled
    if info and info.state ~= nil then
        if item._target ~= nil then
            node.toggle, node.checked = "radio", info.state == item.target
        elseif type(info.state) == "boolean" then
            node.toggle, node.checked = "checkmark", info.state
        end
    end
    local target_variant = item._target
    node.activate = function()
        call(target.service, gtk_action_path(target, prefix), GTK_ACTS, "Activate",
            GLib.Variant("(sava{sv})", { short, target_variant and { target_variant } or {}, {} }))
    end
    return node
end

local function trim_separators(list)
    while list[1] and list[1].separator do table.remove(list, 1) end
    while list[#list] and list[#list].separator do table.remove(list) end
    return list
end

local function gtk_build(target, menus, actions)
    local build
    local function fill(out, g, m, key)
        local function separator()
            if #out > 0 and not out[#out].separator then
                out[#out + 1] = { separator = true, visible = true, children = {} }
            end
        end
        for i, item in ipairs(menus[menu_key(g, m)] or {}) do
            local k = key .. "/" .. i
            if item[":section"] then
                separator()
                if item.label then
                    out[#out + 1] = { header = true, visible = true, label = item.label, children = {} }
                end
                fill(out, item[":section"][1], item[":section"][2], k)
                separator()
            else
                out[#out + 1] = gtk_item_node(target, item, actions, k, build)
            end
        end
        return out
    end
    build = function(g, m, key) return trim_separators(fill({}, g, m, key)) end
    return { key = "", submenu = true, visible = true, enabled = true, children = build(0, 0, "") }
end

local function gtk_end(target, groups)
    if groups and #groups > 0 then
        call(target.service, target.path, GTK_MENUS, "End", GLib.Variant("(au)", { groups }),
            nil, nil, true)
    end
end

-- (Re)load menus and action states. New subscriptions are made before the
-- old ones are ended so the app never tears the model down in between.
local function gtk_reload(target, cb)
    gtk_load_menus(target, function(menus, subscribed)
        local old = target.subscribed
        target.subscribed = subscribed
        gtk_end(target, old)
        if not menus then return cb(nil) end
        gtk_load_actions(target, menus, function(actions)
            cb(gtk_build(target, menus, actions))
        end)
    end)
end

local function gtk_find(node, key)
    if node.key == key then return node end
    for _, child in ipairs(node.children or {}) do
        local found = gtk_find(child, key)
        if found then return found end
    end
end

local function gtk_submenu_actions(node, list)
    if node.submenu_action then list[#list + 1] = node.submenu_action end
    for _, child in ipairs(node.children or {}) do gtk_submenu_actions(child, list) end
    return list
end

-- appmenu-gtk-module (and some apps) populate submenus lazily: a submenu's
-- "submenu-action" state is set to true while it is open, false afterwards.
local function gtk_set_submenu_states(target, names, value, cb)
    local jobs = {}
    for _, name in ipairs(names) do
        local prefix, short = gtk_split(name)
        if prefix then
            jobs[#jobs + 1] = function(done)
                call(target.service, gtk_action_path(target, prefix), GTK_ACTS, "SetState",
                    GLib.Variant("(sva{sv})", { short, GLib.Variant("b", value), {} }),
                    nil, done, true)
            end
        end
    end
    all(jobs, cb or function() end)
end

function gtk.load_top(target, cb)
    gtk_reload(target, cb)
end

function gtk.load_menu(target, node, cb)
    local names = gtk_submenu_actions(node, {})
    gtk_set_submenu_states(target, names, true, function()
        gtk_reload(target, function(root)
            local found = root and gtk_find(root, node.key)
            if found then found._opened = gtk_submenu_actions(found, {}) end
            cb(found)
        end)
    end)
end

function gtk.reload_menu(target, node, cb)
    gtk_reload(target, function(root) cb(root and gtk_find(root, node.key)) end)
end

function gtk.closed(target, node)
    if node._opened then gtk_set_submenu_states(target, node._opened, false) end
end

function gtk.subscribe(target, changed)
    target.subs = {
        bus:signal_subscribe(target.service, GTK_MENUS, "Changed", target.path,
            nil, Gio.DBusSignalFlags.NONE, changed),
    }
end

function gtk.release(target)
    dbusmenu.release(target)
    gtk_end(target, target.subscribed)
    target.subscribed = nil
end

---------------------------------------------------------------------------
-- builtin backend: menus defined in Lua (app menu, desktop menu, your own)
--
-- Item format. Labels use "_" for the mnemonic and "__" for a literal "_"
-- (use M.escape(text) for arbitrary text such as file names):
--   { label = "_Restart", action = awesome.restart, shortcut = "Mod4+Ctrl+R" }
--   { label = "_Floating", checked = c.floating, action = function() ... end }
--   { label = "Tag 1", radio = true, checked = true, action = ... }
--   { label = "_Files", children = { ... } }  -- or a function returning the
--                                             -- items, called when it opens
--   { label = "Not now", enabled = false }
--   "-"                                       -- separator
---------------------------------------------------------------------------
local builtin = { kind = "builtin" } -- doubles as the target of builtin menus
backends.builtin = builtin

function M.escape(text)
    return (tostring(text or ""):gsub("_", "__"))
end

local function spec_node(spec, key, deep)
    if spec == "-" or spec.separator then
        return { key = key, separator = true, visible = true, children = {} }
    end
    local node = {
        key       = key,
        spec      = spec,
        label     = spec.label or "",
        visible   = spec.visible ~= false,
        enabled   = spec.enabled ~= false,
        shortcut  = spec.shortcut,
        icon_name = spec.icon,
        children  = {},
    }
    if spec.checked ~= nil then
        node.toggle  = spec.radio and "radio" or "checkmark"
        node.checked = spec.checked and true or false
    end
    if spec.children then
        node.submenu = true
        if deep then
            local items = spec.children
            if type(items) == "function" then
                local ok, res = pcall(items)
                if not ok then log("menu function failed:", tostring(res)) end
                items = ok and res or {}
            end
            for i, child in ipairs(items or {}) do
                node.children[i] = spec_node(child, key .. "/" .. i, true)
            end
        end
    elseif spec.action then
        node.activate = function()
            local ok, err = pcall(spec.action)
            if not ok then log("menu action failed:", tostring(err)) end
        end
    end
    return node
end

-- Menu functions run each time the menu opens, so state is always fresh.
function builtin.load_menu(_, node, cb) cb(spec_node(node.spec, node.key, true)) end
function builtin.closed() end

---------------------------------------------------------------------------
-- Default app menu
---------------------------------------------------------------------------
-- GLib 2.80 moved GDesktopAppInfo into the GioUnix namespace, and newer
-- releases no longer provide it under Gio at all.
local DesktopAppInfo = (function()
    local ok, GioUnix = pcall(lgi.require, "GioUnix", "2.0")
    if ok and GioUnix then
        local found, class = pcall(function() return GioUnix.DesktopAppInfo end)
        if found and class then return class end
    end
    local found, class = pcall(function() return Gio.DesktopAppInfo end)
    if found and class then return class end
    log("GDesktopAppInfo not found in GioUnix or Gio; app menus won't list .desktop actions")
end)()

local desktop_cache = {}

-- Find the .desktop file of a client: GTK application id, WM_CLASS, or a
-- desktop file whose StartupWMClass matches.
local function find_desktop_info(c, app_id)
    for _, name in ipairs({ app_id or false, c.class or false, c.instance or false }) do
        if name and name ~= "" then
            local info = DesktopAppInfo.new(name .. ".desktop")
                      or DesktopAppInfo.new(name:lower() .. ".desktop")
            if info then return info end
        end
    end
    local class, instance = (c.class or ""):lower(), (c.instance or ""):lower()
    for _, app in ipairs(Gio.AppInfo.get_all()) do
        local ok, wm = pcall(function() return app:get_startup_wm_class() end)
        if ok and wm and (wm:lower() == class or wm:lower() == instance) then return app end
    end
end

local function desktop_info(c)
    if not DesktopAppInfo then return nil end
    local ok, app_id = pcall(c.get_xproperty, c, GTK_PROPS.app_id)
    app_id = ok and app_id or nil
    local key = table.concat({ app_id or "", c.class or "", c.instance or "" }, "\0")
    if desktop_cache[key] == nil then
        local found, info = pcall(find_desktop_info, c, app_id)
        if not found then log("desktop file lookup failed:", tostring(info)) end
        desktop_cache[key] = found and info or false
    end
    return desktop_cache[key] or nil
end

local function app_name(c)
    local info = desktop_info(c)
    return info and info:get_name() or c.class or c.name or ""
end

-- All windows of the same app: same process, or same class if there's no pid.
local function app_clients(c)
    local list = {}
    for _, other in ipairs(client.get()) do
        if (c.pid and other.pid == c.pid) or (not c.pid and other.class == c.class) then
            list[#list + 1] = other
        end
    end
    return list
end

function M.default_app_menu(c)
    local items, info = {}, desktop_info(c)
    if info then
        items[#items + 1] = { label = "_New Window", action = function() info:launch(nil, nil) end }
        for _, action in ipairs(info:list_actions()) do
            items[#items + 1] = {
                label  = M.escape(info:get_action_name(action)),
                action = function() info:launch_action(action, nil) end,
            }
        end
        items[#items + 1] = "-"
    end
    local function toggle(label, prop)
        return { label = label, checked = c[prop] and true or false,
                 action = function() if c.valid then c[prop] = not c[prop] end end }
    end
    items[#items + 1] = { label = "Mi_nimize", action = function() c.minimized = true end }
    items[#items + 1] = toggle("Ma_ximize", "maximized")
    items[#items + 1] = toggle("_Fullscreen", "fullscreen")
    items[#items + 1] = toggle("F_loating", "floating")
    items[#items + 1] = toggle("Always on _Top", "ontop")
    items[#items + 1] = toggle("_Sticky", "sticky")
    items[#items + 1] = { label = "Move to T_ag", children = function()
        local tags = {}
        for i, t in ipairs(c.screen.tags) do
            tags[i] = { label = M.escape(t.name ~= "" and t.name or i), radio = true,
                        checked = c.first_tag == t,
                        action = function() if c.valid then c:move_to_tag(t) end end }
        end
        return tags
    end }
    items[#items + 1] = "-"
    items[#items + 1] = { label = "_Close Window", action = function() if c.valid then c:kill() end end }
    items[#items + 1] = { label = "_Quit " .. M.escape(app_name(c)), action = function()
        for _, other in ipairs(app_clients(c)) do other:kill() end
    end }
    return items
end

---------------------------------------------------------------------------
-- Default desktop menu
---------------------------------------------------------------------------
local function open_uri(uri)
    local ok, err = Gio.AppInfo.launch_default_for_uri(uri, nil)
    if not ok then
        log("no default app for", uri .. " (" .. tostring(err) .. "), trying xdg-open")
        awful.spawn({ "xdg-open", uri })
    end
end

local function is_dir(path)
    return path and Gio.File.new_for_path(path):query_file_type(Gio.FileQueryInfoFlags.NONE, nil) == "DIRECTORY"
end

-- The folders that get a menu of their own on the desktop: label, XDG
-- user directory, fallback name below $HOME.
local FOLDER_MENUS = {
    { "_Downloads", "DIRECTORY_DOWNLOAD",  "Downloads" },
    { "D_ocuments", "DIRECTORY_DOCUMENTS", "Documents" },
    { "_Music",     "DIRECTORY_MUSIC",     "Music"     },
    { "_Pictures",  "DIRECTORY_PICTURES",  "Pictures"  },
    { "_Videos",    "DIRECTORY_VIDEOS",    "Videos"    },
}

local function user_dir(enum_name, fallback)
    local home = GLib.get_home_dir()
    if not enum_name then return home end
    local dir = GLib.get_user_special_dir(GLib.UserDirectory[enum_name])
    if not dir or dir == home then dir = home .. "/" .. fallback end
    return is_dir(dir) and dir or nil
end

-- Folder contents, newest first (like a "recent" list).
local function folder_items(path)
    local folder = Gio.File.new_for_path(path)
    local items = { { label = "_Open Folder", action = function() open_uri(folder:get_uri()) end }, "-" }
    local entries = {}
    local ok, err = pcall(function()
        local enum = folder:enumerate_children(
            "standard::name,standard::display-name,standard::is-hidden,standard::type,time::modified",
            Gio.FileQueryInfoFlags.NONE)
        while true do
            local fi = enum:next_file()
            if not fi then break end
            if not fi:get_is_hidden() then
                entries[#entries + 1] = {
                    name  = fi:get_display_name(),
                    uri   = folder:get_child(fi:get_name()):get_uri(),
                    dir   = fi:get_file_type() == "DIRECTORY",
                    mtime = fi:get_attribute_uint64("time::modified") or 0,
                }
            end
        end
        enum:close()
    end)
    if not ok then log("cannot list", path .. ":", tostring(err)) end
    table.sort(entries, function(a, b) return a.mtime > b.mtime end)
    for i = 1, math.min(#entries, M.config.files_limit) do
        local e = entries[i]
        items[#items + 1] = { label = M.escape(e.name) .. (e.dir and "/" or ""),
                              action = function() open_uri(e.uri) end }
    end
    if #entries > M.config.files_limit then
        items[#items + 1] = { label = string.format("%d more...", #entries - M.config.files_limit),
                              enabled = false }
    elseif #entries == 0 then
        items[#items + 1] = { label = "(empty)", enabled = false }
    end
    return items
end

--- Items for a folder menu: "Open Folder", then its files, newest first.
--- Handy for your own menus: { label = "_Projects", children = function()
---     return globalmenu.folder_items(os.getenv("HOME") .. "/projects") end }
M.folder_items = folder_items

function M.default_desktop_menu(s)
    local menus = {}
    for _, d in ipairs(FOLDER_MENUS) do
        local path = user_dir(d[2], d[3]) -- folders that don't exist get no menu
        if path then
            menus[#menus + 1] = { label = d[1], children = function() return folder_items(path) end }
        end
    end
    menus[#menus + 1] = { label = "_Tag", children = function()
        local t = s.selected_tag
        if not t then return { { label = "(no tag selected)", enabled = false } } end
        local items = {}
        for _, layout in ipairs(awful.layout.layouts) do
            items[#items + 1] = { label = M.escape(awful.layout.getname(layout)), radio = true,
                                  checked = t.layout == layout,
                                  action = function() awful.layout.set(layout, t) end }
        end
        items[#items + 1] = "-"
        items[#items + 1] = { label = "Restore _Minimized Windows", action = function()
            for _, c in ipairs(t:clients()) do c.minimized = false end
        end }
        return items
    end }
    return {
        name  = M.config.desktop_name,
        items = {
            { label = "_Hotkeys", action = function() require("awful.hotkeys_popup").show_help(nil, s) end },
            { label = "Open _Terminal", action = function() awful.spawn(M.config.terminal) end },
            { label = "_Edit Config", action = function()
                -- the folder rc.lua was loaded from (also right with `awesome -c`)
                local dir = awesome.conffile:match("^(.*)/[^/]*$") or gears.filesystem.get_configuration_dir()
                local ed = M.config.editor
                local cmd = {}
                if M.config.editor_in_terminal then cmd = { M.config.terminal, "-e" } end
                for _, part in ipairs(type(ed) == "table" and ed or { ed }) do cmd[#cmd + 1] = part end
                cmd[#cmd + 1] = dir
                awful.spawn(cmd)
            end },
            "-",
            { label = "_Restart", action = awesome.restart },
            { label = "_Quit", action = function() awesome.quit() end },
        },
        menus = menus,
    }
end

local function resolve(setting, default)
    if setting == true then return default end
    return setting or nil
end

---------------------------------------------------------------------------
-- Turning nodes into awful.menu items
---------------------------------------------------------------------------
local function icon_for(node)
    if not M.config.show_icons then return nil end
    if node.icon_name and node.icon_name ~= "" then
        local ok, path = pcall(require("menubar.utils").lookup_icon, node.icon_name)
        if ok and path then return path end
    end
    if node.icon_data and #node.icon_data > 0 then
        local ok, surf = pcall(function()
            local loader = GdkPixbuf.PixbufLoader()
            loader:write(node.icon_data)
            loader:close()
            return gears.surface(awesome.pixbuf_to_surface(loader:get_pixbuf()._native,
                                                           "globalmenu-icon"))
        end)
        if ok then return surf end
    end
end

local function separator_entry()
    return {
        new = function()
            return { widget = wibox.widget {
                widget      = wibox.widget.separator,
                orientation = "horizontal",
                color       = M.config.disabled_fg,
                thickness   = 1,
                span_ratio  = 0.92,
            } }
        end,
    }
end

-- Shaped menus draw their border themselves.
local function custom_frame()
    return M.config.menu_shape ~= nil
end

local function menu_theme()
    local font = M.config.menu_font or M.config.font -- nil: awful.menu's default
    local height = M.config.menu_height
    if not height and font then height = beautiful.get_font_height(font) + 6 end
    return { width = M.config.menu_width, font = font, height = height,
             border_width = custom_frame() and 0 or M.config.menu_border_width,
             border_color = M.config.menu_border_color }
end

---------------------------------------------------------------------------
-- Rounded menus. awful.menu only knows rectangular X borders, so a shaped
-- menu gets a frame of its own: the items inside a padded, shaped background
-- plus a layer on top that strokes the border. With a compositor the corners
-- are transparent and antialiased; without one X can only cut the window to
-- the shape, which gives hard (jagged) edges.
---------------------------------------------------------------------------
local decorate -- forward declaration

-- awful.menu creates submenus on demand and shows them right away; create
-- them here first so they are framed before they appear.
local function framed_exec(self, num, opts)
    local item = self.items[num]
    if item and type(item.cmd) == "table" and #item.cmd > 0 and not self.child[num] then
        self.child[num] = awful.menu.new(item.cmd, self)
        decorate(self.child[num])
    end
    return awful.menu.exec(self, num, opts)
end

-- awful.menu sizes the window to the items on every show; add the frame's
-- padding afterwards (and keep the grown menu on the screen).
local function framed_show(self, args)
    awful.menu.show(self, args)
    local pad, w = self._globalmenu_pad, self.wibox
    if not pad or not w.visible then return end
    local width, height = w.width + 2 * pad, w.height + 2 * pad
    local wa = (w.screen or awful.screen.focused()).workarea
    local x = math.max(wa.x, math.min(w.x, wa.x + wa.width - width))
    local y = math.max(wa.y, math.min(w.y, wa.y + wa.height - height))
    w:geometry({ x = x, y = y, width = width, height = height })
    self.x, self.y, self.width, self.height = x, y, width, height -- submenus are placed from these
end

decorate = function(m)
    if m._globalmenu_framed then return end
    m._globalmenu_framed = true
    m.exec = framed_exec
    if not custom_frame() then return end

    local shape = M.config.menu_shape
    if type(shape) == "number" then
        local radius = shape
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, radius) end
    end
    -- same fallbacks as awful.menu's own border
    local bw = M.config.menu_border_width or beautiful.menu_border_width or beautiful.border_width or 1
    local color = M.config.menu_border_color or beautiful.menu_border_color
                  or beautiful.border_color_normal or beautiful.border_normal or "#000000"
    local pad = (M.config.menu_padding or 4) + bw
    local bg = m.theme.bg_normal

    local body = wibox.container.background(wibox.container.margin(m.layout, pad, pad, pad, pad))
    body.bg = bg
    if shape then
        body.shape = shape
        body.shape_clip = true
    end
    local frame = wibox.widget.base.make_widget()
    frame.fit = function(_, _, w, h) return w, h end
    frame.draw = function(_, _, cr, w, h)
        if bw <= 0 then return end
        cr:translate(bw / 2, bw / 2)
        shape(cr, w - bw, h - bw)
        cr:set_line_width(bw)
        cr:set_source(gears.color(color))
        cr:stroke()
    end

    local stack = wibox.layout.stack() -- (awesome 4.3's constructor drops all but one widget)
    stack:add(body)
    stack:add(frame)
    m.wibox.widget = stack
    m._globalmenu_pad = pad
    m.show = framed_show
    if awesome.composite_manager_running then
        m.wibox.bg = "#00000000" -- the shaped background is all you see
    else
        m.wibox.bg = bg
        m.wibox.shape = shape
    end
end

-- awful.menu item constructor that shows M.config.cursor while hovering the
-- item. Items are built before their menu's wibox exists, so look it up late.
-- awful.menu item constructor: awful.menu's own entry plus our submenu
-- arrow, a right-aligned shortcut and the hover cursor. Items are built
-- before their menu's wibox exists, so that is looked up late.
local function menu_entry(parent, args)
    local cmd = args[2] or args.cmd -- awful.menu.entry normalizes this only later
    local theme, submenu = args.theme, type(cmd) == "table"
    if submenu and M.config.submenu_icon then
        theme.submenu_icon = M.config.submenu_icon
    elseif submenu and M.config.submenu_text then
        theme.submenu_icon, theme.submenu = nil, M.config.submenu_text
    end

    local item = awful.menu.entry(parent, args)

    if submenu and (M.config.submenu_icon or M.config.submenu_text) and item.sep then
        item.widget:set_right(wibox.container.margin(item.sep, 0, 6))
    elseif not submenu and args.shortcut and M.config.show_shortcuts then
        local keys = wibox.widget.textbox()
        if theme.font then keys.font = theme.font end
        if M.config.shortcut_fg then
            keys.markup = string.format('<span foreground="%s">%s</span>',
                M.config.shortcut_fg, gears.string.xml_escape(args.shortcut))
        else
            keys.text = args.shortcut
            keys.opacity = M.config.shortcut_opacity
        end
        item.widget:set_right(wibox.container.margin(keys, 16, 8))
    end

    if cmd then
        item.widget:connect_signal("mouse::enter", function()
            if M.config.cursor and parent.wibox then parent.wibox.cursor = M.config.cursor end
        end)
        item.widget:connect_signal("mouse::leave", function()
            if M.config.cursor and parent.wibox then parent.wibox.cursor = "left_ptr" end
        end)
    end
    return item
end

-- column width of "✓ " so unchecked toggles line up with checked ones
local CHECK_PAD = "\226\128\131\226\128\137" -- em space + thin space

-- The visible children, without separators at the start, at the end or next
-- to each other. Apps leave those behind when they hide items (Firefox does).
local function visible_children(node)
    local list = {}
    for _, child in ipairs(node.children) do
        if child.visible and not (child.separator and (#list == 0 or list[#list].separator)) then
            list[#list + 1] = child
        end
    end
    if list[#list] and list[#list].separator then list[#list] = nil end
    return list
end

local function build_items(node)
    local items  = {}
    local dimmed = { fg_normal = M.config.disabled_fg, fg_focus = M.config.disabled_fg }
    local children = visible_children(node)

    local has_toggles = false
    for _, child in ipairs(children) do
        if child.toggle then has_toggles = true end
    end

    for _, child in ipairs(children) do
        do
            if child.separator then
                items[#items + 1] = separator_entry()
            elseif child.header then
                items[#items + 1] = { convert_label(child.label), nil, theme = dimmed }
            else
                local prefix = has_toggles and CHECK_PAD or ""
                if child.checked then
                    prefix = child.toggle == "radio" and "● " or "✓ "
                end
                local text, shortcut = child.label, child.shortcut
                if not shortcut then text, shortcut = split_shortcut(text or "") end
                local label = prefix .. convert_label(text, "&")
                local entry
                if child.submenu then
                    entry = { label, build_items(child), icon_for(child) }
                elseif child.enabled and child.activate then
                    entry = { label, function() child.activate() end, icon_for(child) }
                else
                    entry = { label, nil, icon_for(child) }
                end
                entry.new = menu_entry
                entry.shortcut = shortcut
                if not child.enabled then entry.theme = dimmed end
                items[#items + 1] = entry
            end
        end
    end
    if #items == 0 then items[1] = { "(empty)", nil, theme = dimmed } end
    -- every (sub)menu gets the theme: awful.menu passes the border width on
    -- to submenus, but not the border color
    items.theme = menu_theme()
    return items
end

local function close_menu()
    if state.menu then
        state.menu:hide()
        state.menu = nil
    end
end

---------------------------------------------------------------------------
-- Closing the menu with a click outside of it
--
-- awful.menu can't do that by itself, so while the pointer is outside the
-- open menu we grab it: a click then closes the menu (or, on another entry
-- of the bar, switches to that menu), and moving back into the menu
-- releases the grab so the menu works normally.
---------------------------------------------------------------------------
local entry_handlers = setmetatable({}, { __mode = "k" }) -- bar entry -> { key, open }
local watched = setmetatable({}, { __mode = "k" })        -- menu wiboxes with a leave hook
local outside_grab = false
local grab_if_outside -- forward declaration

-- The (sub)menu containing (x, y), if any.
local function menu_at(m, x, y)
    if not m then return nil end
    local w = m.wibox
    if w and w.visible then
        local g, bw = w:geometry(), w.border_width or 0
        if x >= g.x and x < g.x + g.width + 2 * bw and y >= g.y and y < g.y + g.height + 2 * bw then
            return m
        end
    end
    return menu_at(m.active_child, x, y) -- open submenus
end

-- Leaving a menu re-arms the grab. awesome only emits mouse::leave per
-- wibox, and submenus are created lazily, so each menu the pointer reaches
-- gets its hook then.
local function watch_leave(m)
    if watched[m.wibox] then return end
    watched[m.wibox] = true
    m.wibox:connect_signal("mouse::leave", function()
        if state.menu and not outside_grab then gears.timer.delayed_call(grab_if_outside) end
    end)
end

-- The bar entry under (x, y), and where its menu should open.
local function bar_entry_at(x, y)
    local w = mouse.current_wibox
    if not w then return nil end
    local g = w:geometry()
    for _, hit in ipairs(w:find_widgets(x - g.x, y - g.y) or {}) do
        local entry = entry_handlers[hit.widget]
        if entry then
            return entry, { x = g.x + hit.x, y = g.y + hit.y + hit.height }
        end
    end
end

local function stop_outside_grab()
    if not outside_grab then return end
    outside_grab = false
    if mousegrabber.isrunning() then mousegrabber.stop() end
end

local function start_outside_grab()
    if outside_grab or not state.menu or mousegrabber.isrunning()
       or not M.config.close_on_outside_click then
        return
    end
    -- only a new press counts, not the release of the click that opened the menu
    local b = mouse.coords().buttons
    local was_down = b[1] or b[2] or b[3]
    outside_grab = true
    mousegrabber.run(function(ev)
        local inside = menu_at(state.menu, ev.x, ev.y)
        if not state.menu or inside then
            outside_grab = false
            if inside then watch_leave(inside) end
            return false -- back in the menu: give it the pointer again
        end
        local down = ev.buttons[1] or ev.buttons[2] or ev.buttons[3]
        if down and not was_down then
            outside_grab = false
            local entry, coords = bar_entry_at(ev.x, ev.y)
            local switch = entry and entry.key ~= state.open_key
            close_menu()
            if switch then gears.timer.delayed_call(entry.open, coords) end
            return false
        end
        was_down = down
        return true
    end, "left_ptr")
end

grab_if_outside = function()
    if not state.menu or outside_grab then return end
    local mc = mouse.coords()
    local m = menu_at(state.menu, mc.x, mc.y)
    if m then watch_leave(m) else start_outside_grab() end
end

-- awesome only reports leaving a menu once it has seen motion inside it, so
-- a quick flick across the edge can go unnoticed: check now and then too.
local outside_check = gears.timer { timeout = 0.25, callback = function() grab_if_outside() end }

-- A fingerprint of a menu tree, to tell whether an update changed anything.
local function signature(node)
    local parts = {}
    local function walk(n)
        parts[#parts + 1] = table.concat({ tostring(n.id), n.label or "", tostring(n.visible), tostring(n.enabled),
            tostring(n.checked), n.separator and "-" or "", n.submenu and ">" or "" }, "\1")
        for _, child in ipairs(n.children or {}) do walk(child) end
        parts[#parts + 1] = "\2"
    end
    walk(node)
    return table.concat(parts, "\3")
end

-- Build and show the awful.menu described by `info` (see show_menu).
local function present(info)
    local items = build_items(info.node)
    items.theme = menu_theme()
    local m = awful.menu(items)
    decorate(m)
    info.menu = m
    state.menu, state.menu_info = m, info
    m.wibox:connect_signal("property::visible", function()
        if m.wibox.visible or m._replaced then return end
        if state.menu == m then
            state.menu, state.menu_info = nil, nil
            stop_outside_grab()
            outside_check:stop()
        end
        backends[info.target.kind].closed(info.target, info.node)
        if info.on_hide then info.on_hide() end
    end)
    m:show({ coords = info.coords })
    watch_leave(m)
    gears.timer.delayed_call(grab_if_outside)
    if M.config.close_on_outside_click and not outside_check.started then outside_check:start() end
end

-- `source` is the node to re-read when the app changes the menu while it is
-- open (Firefox fills History only after the menu was opened).
local function show_menu(target, node, coords, on_hide, source, seen)
    close_menu()
    present({ target = target, node = node, coords = coords, on_hide = on_hide,
              source = source, seen = seen, sig = signature(node) })
end

local function refresh_open_menu()
    local info = state.menu_info
    if not (info and info.source and backends[info.target.kind].reload_menu) then return end
    backends[info.target.kind].reload_menu(info.target, info.source, function(full)
        if state.menu_info ~= info or not full then return end
        local sig = signature(full)
        if sig == info.sig then return end -- nothing visible changed
        info.sig = sig
        full._opened = info.node._opened
        info.node = full
        local old = info.menu
        old._replaced = true
        old:hide()
        present(info)
    end, info.seen)
end

local menu_refresh_timer = gears.timer {
    timeout = 0.1, single_shot = true, callback = function() refresh_open_menu() end,
}

---------------------------------------------------------------------------
-- The wibar widget
---------------------------------------------------------------------------
local redraw -- forward declaration

local function make_entry(text, markup, on_click)
    local tb = wibox.widget.textbox()
    if M.config.font then tb.font = M.config.font end
    tb.markup = markup or gears.string.xml_escape(text)
    local bg = wibox.container.background(
        wibox.container.margin(tb, M.config.item_padding, M.config.item_padding))
    if on_click then
        local bar, old_cursor
        bg:connect_signal("mouse::enter", function()
            bar = M.config.cursor and mouse.current_wibox
            if bar then old_cursor, bar.cursor = bar.cursor, M.config.cursor end
        end)
        bg:connect_signal("mouse::leave", function()
            if bar then bar.cursor, bar = old_cursor or "left_ptr", nil end
        end)
        bg:connect_signal("button::press", function(self, lx, ly, button, _, geo)
            if button ~= 1 then return end
            local mc = mouse.coords()
            -- open right below the clicked entry
            on_click(self, { x = mc.x - lx, y = mc.y - ly + geo.height })
        end)
    end
    return bg
end

local function open_top_menu(target, gen, node, bg, coords)
    -- clicking the entry whose menu is open closes it (like a toggle)
    if state.menu and state.open_key == node.key then return close_menu() end
    local seen = {} -- submenus announced to the app during this opening
    backends[target.kind].load_menu(target, node, function(full)
        if gen ~= state.gen or not full then return end
        state.open_key = node.key
        bg.bg = beautiful.bg_focus
        bg.fg = beautiful.fg_focus
        show_menu(target, full, coords, function()
            bg.bg, bg.fg = nil, nil
            if state.open_key == node.key then state.open_key = nil end
            if state.dirty then state.dirty = false; redraw() end
        end, node, seen)
    end, seen)
end

local function add_menu_entry(layout, target, gen, node, text, markup)
    local bg
    local function open(coords) open_top_menu(target, gen, node, bg, coords) end
    bg = make_entry(text, markup, function(_, coords) open(coords) end)
    entry_handlers[bg] = { key = node.key, open = open }
    layout:add(bg)
    layout._entries[#layout._entries + 1] = { target = target, node = node, text = text or markup, open = open }
end

local function bold(text)
    return "<b>" .. gears.string.xml_escape(text) .. "</b>"
end

local function app_node(c, app_menu, deep)
    return spec_node({ label = M.escape(app_name(c)), children = function() return app_menu(c) end },
                     "builtin:app", deep)
end

local function desktop_nodes(s, deep)
    local make = resolve(M.config.desktop, M.default_desktop_menu)
    if not make then return nil end
    local ok, desk = pcall(make, s)
    if not ok then log("desktop menu failed:", tostring(desk)); return nil end
    local nodes = { spec_node({ label = M.escape(desk.name or ""), children = desk.items or {} },
                              "builtin:desktop", deep) }
    for i, menu in ipairs(desk.menus or {}) do
        nodes[#nodes + 1] = spec_node(menu, "builtin:desktop/" .. i, deep)
    end
    return nodes, desk.name or ""
end

local function fill(layout, s)
    layout:reset()
    layout._entries = {}
    local gen = state.gen
    local c = client.focus

    if not c or (s and c.screen ~= s) then
        -- no focused client here: desktop menu
        local nodes, name = desktop_nodes(s or awful.screen.focused())
        if not nodes then return end
        add_menu_entry(layout, builtin, gen, nodes[1], nil, bold(name))
        for i = 2, #nodes do
            add_menu_entry(layout, builtin, gen, nodes[i], convert_label(nodes[i].label))
        end
        return
    end

    if M.config.show_app_name then
        local ok, err = pcall(function()
            local app_menu = resolve(M.config.app_menu, M.default_app_menu)
            if app_menu then
                add_menu_entry(layout, builtin, gen, app_node(c, app_menu), nil, bold(app_name(c)))
            else
                layout:add(make_entry(nil, bold(app_name(c))))
            end
        end)
        if not ok then
            log("app menu failed:", tostring(err))
            layout:add(make_entry(nil, bold(c.class or c.name or "")))
        end
    end
    if not (state.client == c and state.root) then return end

    local target = state.target
    for _, node in ipairs(state.root.children) do
        if node.visible and not node.separator and not node.header then
            local text = convert_label(node.label)
            if node.enabled == false then
                layout:add(make_entry(nil, string.format('<span foreground="%s">%s</span>',
                    M.config.disabled_fg, gears.string.xml_escape(text))))
            elseif not node.submenu and node.activate then
                -- a plain action directly in the menubar
                layout:add(make_entry(text, nil, function() node.activate() end))
            else
                add_menu_entry(layout, target, gen, node, text)
            end
        end
    end
end

local function safe_fill(layout, s)
    local ok, err = pcall(fill, layout, s)
    if not ok then log("drawing the bar failed:", tostring(err)) end
end

redraw = function()
    if state.menu then state.dirty = true; return end -- don't yank the bar under an open menu
    for layout, s in pairs(instances) do safe_fill(layout, s or nil) end
end

--- Create a global menu widget. args.screen restricts it to clients on that screen.
function M.widget(args)
    args = args or {}
    local layout = wibox.layout.fixed.horizontal()
    instances[layout] = args.screen or false
    safe_fill(layout, args.screen)
    return layout
end

---------------------------------------------------------------------------
-- Following focus
---------------------------------------------------------------------------
local refresh_timer -- debounces change-signal storms

local function load_top()
    local target, gen = state.target, state.gen
    backends[target.kind].load_top(target, function(root)
        if gen ~= state.gen then return end
        state.root = root
        redraw()
    end)
end

local function gtk_target_for(c)
    local service = c:get_xproperty(GTK_PROPS.bus)
    local menubar = c:get_xproperty(GTK_PROPS.menubar)
    if not (service and service ~= "" and menubar and menubar ~= "") then return nil end
    local function prop(name)
        local v = c:get_xproperty(name)
        return v ~= "" and v or nil
    end
    return {
        kind    = "gtk",
        service = service,
        path    = menubar,
        paths   = { app = prop(GTK_PROPS.app), win = prop(GTK_PROPS.win), unity = menubar },
    }
end

local function lookup(c, cb)
    local e = registry[c.window]
    if not e then
        local svc, path = c:get_xproperty(PROP_SVC), c:get_xproperty(PROP_PATH)
        if svc and svc ~= "" and path and path ~= "" then
            e = { service = svc, path = path }
            registry[c.window] = e
        end
    end
    if e then return cb({ kind = "dbusmenu", service = e.service, path = e.path }) end

    local gtk_target = gtk_target_for(c)
    if gtk_target or own_registrar then return cb(gtk_target) end

    -- someone else is the registrar: ask them
    call(REG_NAME, REG_PATH, REG_NAME, "GetMenuForWindow", GLib.Variant("(u)", { c.window }),
        "(so)", function(ret)
            local svc  = ret and ret:get_child_value(0).value
            local path = ret and ret:get_child_value(1).value
            cb(svc and svc ~= "" and { kind = "dbusmenu", service = svc, path = path } or nil)
        end, true)
end

--- Re-read the focused client's menu.
function M.refresh()
    close_menu()
    if state.target then backends[state.target.kind].release(state.target) end
    state.gen    = state.gen + 1
    state.client = client.focus
    state.target, state.root = nil, nil
    redraw()

    local c, gen = client.focus, state.gen
    if not c then return end
    lookup(c, function(target)
        if gen ~= state.gen or not target then return end
        state.target = target
        backends[target.kind].subscribe(target, function()
            refresh_timer:again()
            -- the app changed its menu: re-read an open dropdown of it too
            if state.menu_info and state.menu_info.target == target then menu_refresh_timer:again() end
        end)
        load_top()
    end)
end

refresh_timer = gears.timer {
    timeout     = 0.15,
    single_shot = true,
    callback    = function() if state.target then load_top() end end,
}

--- Open the complete menu of the focused app (or the desktop menu) as one
--- cascading menu at the mouse -- handy on a keybinding.
function M.show_all()
    local gen, c = state.gen, client.focus
    if not c then
        local nodes = desktop_nodes(awful.screen.focused(), true)
        if nodes then show_menu(builtin, { children = nodes }) end
        return
    end
    local app_menu = resolve(M.config.app_menu, M.default_app_menu)
    local first = app_menu and { app_node(c, app_menu, true) } or {}
    local target, root = state.target, state.root
    if not (target and root and state.client == c) then
        if #first > 0 then show_menu(builtin, { children = first }) end
        return
    end
    backends[target.kind].load_menu(target, root, function(full)
        if gen ~= state.gen or not full then return end
        for _, node in ipairs(full.children) do first[#first + 1] = node end
        full.children = first
        show_menu(target, full)
    end)
end

local pending = false
local function schedule_refresh()
    if pending then return end
    pending = true
    gears.timer.delayed_call(function()
        pending = false
        if client.focus ~= state.client or not state.target then M.refresh() end
    end)
end

client.connect_signal("focus", schedule_refresh)
client.connect_signal("unfocus", schedule_refresh)
client.connect_signal("unmanage", schedule_refresh)
client.connect_signal("property::class", function(c) if c == client.focus then redraw() end end)
client.connect_signal("manage", function(c)
    -- the app may have registered before awesome managed its window
    local e = registry[c.window]
    if e then
        c:set_xproperty(PROP_SVC, e.service)
        c:set_xproperty(PROP_PATH, e.path)
    end
end)
-- appmenu-gtk-module sets its properties after the window is mapped
client.connect_signal("xproperty::" .. GTK_PROPS.menubar, function(c)
    if c == client.focus then M.refresh() end
end)

---------------------------------------------------------------------------
-- The com.canonical.AppMenu.Registrar service
---------------------------------------------------------------------------
local REGISTRAR_XML = [[
<node>
  <interface name="com.canonical.AppMenu.Registrar">
    <method name="RegisterWindow">
      <arg name="windowId" type="u" direction="in"/>
      <arg name="menuObjectPath" type="o" direction="in"/>
    </method>
    <method name="UnregisterWindow">
      <arg name="windowId" type="u" direction="in"/>
    </method>
    <method name="GetMenuForWindow">
      <arg name="windowId" type="u" direction="in"/>
      <arg name="service" type="s" direction="out"/>
      <arg name="menuObjectPath" type="o" direction="out"/>
    </method>
    <method name="GetMenus">
      <arg name="menus" type="a(uso)" direction="out"/>
    </method>
    <signal name="WindowRegistered">
      <arg name="windowId" type="u"/>
      <arg name="service" type="s"/>
      <arg name="menuObjectPath" type="o"/>
    </signal>
    <signal name="WindowUnregistered">
      <arg name="windowId" type="u"/>
    </signal>
  </interface>
</node>]]

local function set_entry(xid, service, path)
    registry[xid] = service and { service = service, path = path } or nil
    local c = client_for_xid(xid)
    if c then
        c:set_xproperty(PROP_SVC, service or "")
        c:set_xproperty(PROP_PATH, path or "")
        if c == client.focus then M.refresh() end
    end
end

local function on_method_call(_, sender, _, _, method, params, invocation)
    if method == "RegisterWindow" then
        local xid, path = params:get_child_value(0).value, params:get_child_value(1).value
        set_entry(xid, sender, path)
        bus:emit_signal(nil, REG_PATH, REG_NAME, "WindowRegistered",
            GLib.Variant("(uso)", { xid, sender, path }))
        invocation:return_value(nil)
    elseif method == "UnregisterWindow" then
        local xid = params:get_child_value(0).value
        set_entry(xid, nil)
        bus:emit_signal(nil, REG_PATH, REG_NAME, "WindowUnregistered", GLib.Variant("(u)", { xid }))
        invocation:return_value(nil)
    elseif method == "GetMenuForWindow" then
        local e = registry[params:get_child_value(0).value]
        if e then
            invocation:return_value(GLib.Variant("(so)", { e.service, e.path }))
        else
            invocation:return_dbus_error("com.canonical.AppMenu.Registrar.Error.NoMenu",
                "No menu registered for this window")
        end
    elseif method == "GetMenus" then
        local list = {}
        for xid, e in pairs(registry) do list[#list + 1] = { xid, e.service, e.path } end
        invocation:return_value(GLib.Variant("(a(uso))", { list }))
    else
        invocation:return_dbus_error("org.freedesktop.DBus.Error.UnknownMethod", method)
    end
end

local iface = Gio.DBusNodeInfo.new_for_xml(REGISTRAR_XML):lookup_interface(REG_NAME)
bus:register_object(REG_PATH, iface, GObject.Closure(on_method_call))

Gio.bus_own_name_on_connection(bus, REG_NAME, Gio.BusNameOwnerFlags.NONE,
    GObject.Closure(function() own_registrar = true end),
    GObject.Closure(function()
        if not own_registrar then
            log("another process owns " .. REG_NAME .. ", using it instead")
        end
        own_registrar = false
    end))

-- Forget menus of apps that quit.
bus:signal_subscribe("org.freedesktop.DBus", "org.freedesktop.DBus", "NameOwnerChanged",
    "/org/freedesktop/DBus", nil, Gio.DBusSignalFlags.NONE,
    function(_, _, _, _, _, params)
        local name, new_owner = params:get_child_value(0).value, params:get_child_value(2).value
        if new_owner ~= "" then return end
        for xid, e in pairs(registry) do
            if e.service == name then registry[xid] = nil end
        end
        if state.target and state.target.service == name then
            state.target.subscribed = nil -- the app is gone, nothing to End
            M.refresh()
        end
    end)

-- If an external registrar is in charge, follow its announcements.
bus:signal_subscribe(nil, REG_NAME, "WindowRegistered", REG_PATH, nil,
    Gio.DBusSignalFlags.NONE, function(_, _, _, _, _, params)
        if own_registrar then return end
        local c = client.focus
        if c and c.window == params:get_child_value(0).value then M.refresh() end
    end)

-- for debugging via awesome-client
M._state, M._registry, M._backends, M._instances = state, registry, backends, instances
return M
