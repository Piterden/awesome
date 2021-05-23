-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : init.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-26 16:53:14 (Marcel Arpogaus)
-- @Changed: 2021-01-20 08:37:53 (Marcel Arpogaus)
-- [ description ] -------------------------------------------------------------
-- ...
-- [ license ] -----------------------------------------------------------------
-- Copyright (C) 2021 Marcel Arpogaus
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
-- [ required modules ] --------------------------------------------------------
-- grab environment
local capi = {
    root = root,
    mouse = mouse,
    client = client,
}

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
local beautiful = require('beautiful')

-- helper functions
local utils = require('rc.utils')

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ local functions ] ---------------------------------------------------------
local function client_menu_toggle_fn()
    local instance = nil
    return function()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({theme = {width = 1000}})
        end
    end
end

-- ref.: https://stackoverflow.com/questions/62286322/grouping-windows-in-the-tasklist
local function client_label(c)
    local theme = beautiful.get()
    local sticky = theme.tasklist_sticky or '▪'
    local ontop = theme.tasklist_ontop or '⌃'
    local above = theme.tasklist_above or '▴'
    local below = theme.tasklist_below or '▾'
    local floating = theme.tasklist_floating or '✈'
    local minimized = theme.tasklist_maximized or '-'
    local maximized = theme.tasklist_maximized or '+'
    local maximized_horizontal = theme.tasklist_maximized_horizontal or '⬌'
    local maximized_vertical = theme.tasklist_maximized_vertical or '⬍'

    local name = c.name
    if c.sticky then
        name = sticky .. name
    end

    if c.ontop then
        name = ontop .. name
    elseif c.above then
        name = above .. name
    elseif c.below then
        name = below .. name
    end

    if c.minimized then
        name = minimized .. name
    end
    if c.maximized then
        name = maximized .. name
    else
        if c.maximized_horizontal then
            name = maximized_horizontal .. name
        end
        if c.maximized_vertical then
            name = maximized_vertical .. name
        end
        if c.floating then
            name = floating .. name
        end
    end

    return name
end

local function client_stack_toggle_fn()
    local cl_menu

    return function(c)
        if cl_menu then
            cl_menu:hide()
            cl_menu = nil
        else
            local client_num = 0
            local client_list = {}
            local t = awful.screen.focused().selected_tag
            for i, cl in ipairs(capi.client.get()) do
                if cl.class == c.class and gears.table.hasitem(cl:tags(), t) then
                    client_num = client_num + 1
                    client_list[i] = {
                        client_label(cl),
                        function()
                            capi.client.focus = cl
                            cl:tags()[1]:view_only()
                            cl:raise()
                        end,
                        cl.icon
                    }
                end
            end

            if client_num > 1 then
                cl_menu = awful.menu({items = client_list})
                cl_menu:show()
            else
                c:emit_signal('request::activate', 'taskbar', {raise = true})
            end
        end
    end
end

-- [ module function ] ---------------------------------------------------------
module.init = function(config, mainmenu, client_actions_menu)
    -- Default modkey.
    local modkey = config.modkey
    local function activateClient (c)
        c:emit_signal('request::activate', 'mouse', {raise = true})
        awesome.emit_signal('menus::hide::all', 'mouse')
    end

    module.taglist_buttons = gears.table.join(
        awful.button(
            {}, 1, function(t)
                t:view_only()
            end
        ),
        awful.button(
            {modkey}, 1, function(t)
                if capi.client.focus then
                    capi.client.focus:move_to_tag(t)
                end
            end
        ),
        awful.button({}, 3, awful.tag.viewtoggle),
        awful.button(
            {modkey}, 3, function(t)
                if capi.client.focus then
                    capi.client.focus:toggle_tag(t)
                end
            end
        ),
        awful.button(
            {}, 4, function(t)
                awful.tag.viewprev(t.screen)
            end
        ),
        awful.button(
            {}, 5, function(t)
                awful.tag.viewnext(t.screen)
            end
        )
    )

    if config.tasklist == 'windows' or beautiful.tasklist == 'windows' then
        module.tasklist_buttons = gears.table.join(
            awful.button({}, 1, client_stack_toggle_fn()),
            awful.button({}, 3, client_menu_toggle_fn()),
            awful.button(
                {}, 4, function()
                    awful.client.focus.byidx(1)
                end
            ), awful.button(
                {}, 5, function()
                    awful.client.focus.byidx(-1)
                end
            )
        )
    else
        module.tasklist_buttons = gears.table.join(
            awful.button({}, 1, function(c)
                activateClient(c)
            end),
            awful.button(
                {}, 3, function()
                    awful.menu.client_list({theme = {width = 250}})
                end
            ),
            awful.button({}, 4, activateClient),
            awful.button({}, 5, activateClient)
        )
    end

    module.client_buttons = gears.table.join(
        awful.button({modkey}, 1, awful.mouse.client.move),
        awful.button({modkey}, 3, awful.mouse.client.resize)
    )

    module.titlebar_buttons = function(c)
        return gears.table.join(
            awful.button(
                {}, 1,
                function()
                    c.mouse_coords = capi.mouse.coords()
                    capi.root.cursor('watch')
                    c.move_timer = gears.timer({
                        timeout = 0.3,
                        callback = function()
                            capi.mouse.coords(c.mouse_coords)
                            awful.mouse.client.move(c)
                            c.move_timer   = nil
                            c.mouse_coords = nil
                            capi.root.cursor('left_ptr')
                        end,
                        single_shot = true,
                    })
                    c.move_timer:start()
                end,
                function()
                    capi.root.cursor('left_ptr')
                    if (c.move_timer) then
                        c.move_timer:stop()
                        c.move_timer   = nil
                        c.mouse_coords = nil
                        utils.single_double_tap(function() end, function()
                            awful.client.setmaster(c)
                        end)
                    end
                end
            ),
            awful.button({}, 2, nil,
                function()
                    c.tabbed_module.pick()
                end
            ),
            awful.button({}, 3,
                function()
                    c.mouse_coords = capi.mouse.coords()
                    capi.root.cursor('watch')
                    c.resize_timer = gears.timer({
                        timeout = 0.3,
                        callback = function()
                            capi.mouse.coords(c.mouse_coords)
                            awful.mouse.client.resize(c)
                            c.resize_timer = nil
                            c.mouse_coords = nil
                            capi.root.cursor('left_ptr')
                        end,
                        single_shot = true,
                    })
                    c.resize_timer:start()
                end,
                function()
                    capi.root.cursor('left_ptr')
                    if (c.resize_timer) then
                        c.resize_timer:stop()
                        c.resize_timer = nil
                        c.mouse_coords = nil
                    end
                end
            )
        )
    end

    local root = gears.table.join(
        awful.button(
            {}, 1, function()
                awesome.emit_signal('menus::hide::all', 'mouse')
            end
        ), awful.button(
            {}, 3, function()
                mainmenu:toggle()
            end
        ),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    )
    capi.root.buttons(root)
end

-- [ return module ] -----------------------------------------------------------
return module
