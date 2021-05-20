-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : tasklist.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-21 18:27:36 (Marcel Arpogaus)
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
local capi = {client = client}

local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module functions ] --------------------------------------------------------
module.default = function(s, tasklist_buttons)
    local tasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style   = {
            shape_border_width  = 2,
            shape_border_color  = '#777777',
            shape               = gears.shape.rounded_bar,
        },
        layout  = {
            spacing         = 3,
            max_widget_size = 260,
            layout          = wibox.layout.flex.horizontal,
        },
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = 'icon_role',
                                widget = wibox.widget.imagebox,
                            },
                            -- shape_border_width = 0,
                            shape              = gears.shape.rounded_bar,
                                forced_width        = 34,
                                forced_height        = 34,
                            shape_clip         = gears.shape.rounded_bar,
                            widget             = wibox.container.background,
                        },
                        margins = 2,
                        left    = 3,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    {
                        {
                            {
                                id     = 'tag_name',
                                widget = wibox.widget.textbox,
                                align  = 'center',
                                valign = 'center',
                            },
                            bg                  = '#fbdb65',
                            fg                  = '#000000',
                            shape_border_width  = 1,
                            shape_border_color  = '#00770080',
                            shape               = gears.shape.rounded_bar,
                            forced_width        = 20,
                            widget              = wibox.container.background,
                        },
                        id      = 'tag_role',
                        margins = 5,
                        widget  = wibox.container.margin,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                margins = 0,
                widget  = wibox.container.margin,
            },
            id              = 'background_role',
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('tag_name')[1].text    = c:tags()[1].name
                self:get_children_by_id('tag_role')[1].visible = #s.selected_tags > 1
            end,
            update_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('tag_name')[1].text    = c:tags()[1].name
                self:get_children_by_id('tag_role')[1].visible = #s.selected_tags > 1
                self:emit_signal('widget::redraw_needed')
            end,
        },
        source = function()
            -- Get all clients
            local cls = capi.client.get()

            -- Filter by an existing filter function and allowing only one client per class
            -- local clients = {}
            local class_seen = {}
            for _, c in pairs(cls) do
                if awful.widget.tasklist.filter.currenttags(c, s) then
                    if not class_seen[c.class] then
                        class_seen[c.class] = 1
                        -- clients[c.class] = c
                    else
                        class_seen[c.class] = class_seen[c.class] + 1
                        -- clients[c.class] = c
                    end
                    -- clients[c.class].multiple_instances = class_seen[c.class]
                end
            end
            local ret = {}
            for _, c in pairs(cls) do
                c.instances = class_seen[c.class]
                table.insert(ret, c)
            end
            -- local tsort = gears.sort.topological()
            -- gears.table.sort(ret)

            -- gears.debug.dump(ret, '1', 30)
            -- print('\n')

            return ret
        end,
    }
    return tasklist
end

module.windows = function(s, tasklist_buttons)
    local tasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout  = {
            spacing = beautiful.systray_icon_spacing,
            layout  = wibox.layout.fixed.horizontal,
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                wibox.widget.base.make_widget(),
                forced_height = 5,
                id = 'clientstack',
                widget = wibox.container.background
            },
            {
                nil,
                {id = 'clienticon', widget = awful.widget.clienticon},
                nil,
                -- expand = 'none',
                id = 'clienticoncontainer',
                widget = wibox.layout.align.horizontal
            },
            nil,
            create_callback = function(self, c, index, objects) -- luacheck: no unused args
                self:get_children_by_id('clienticon')[1].client = c
            end,
            update_callback = function(self, c, index, objects) -- luacheck: no unused args
                if c.multiple_instances and c.multiple_instances > 1 then
                    self:get_children_by_id('clientstack')[1].bg =
                        beautiful.fg_normal
                else
                    self:get_children_by_id('clientstack')[1].bg =
                        beautiful.bg_normal
                end
                if capi.client.focus and capi.client.focus.class == c.class then
                    self:get_children_by_id('clienticoncontainer')[1].opacity =
                        1
                else
                    self:get_children_by_id('clienticoncontainer')[1].opacity =
                        0.5
                end
                self:emit_signal('widget::redraw_needed')
            end,
            layout = wibox.layout.align.vertical
        },
        source = function()
            -- Get all clients
            local cls = capi.client.get()

            -- Filter by an existing filter function and allowing only one client per class
            local clients = {}
            local class_seen = {}
            for _, c in pairs(cls) do
                if awful.widget.tasklist.filter.currenttags(c, s) then
                    if not class_seen[c.class] then
                        class_seen[c.class] = 1
                        clients[c.class] = c
                    else
                        class_seen[c.class] = class_seen[c.class] + 1
                    end
                    clients[c.class].multiple_instances = class_seen[c.class]
                end
            end
            local ret = {}
            for _, v in pairs(clients) do
                table.insert(ret, v)
            end
            return ret
        end
    }
    return tasklist
end

-- [ return module ] -----------------------------------------------------------
return module

