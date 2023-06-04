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
local dpi = require('beautiful.xresources').apply_dpi
local preview = require('rc.screen.task_preview')

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module functions ] --------------------------------------------------------
module.default = function(s, tasklist_buttons)
    preview.enable {
        screen = s,
        x = 50,                    -- The x-coord of the popup
        y = 50,                    -- The y-coord of the popup
        height = 400,              -- The height of the popup
        width = 400,               -- The width of the popup
        placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
            awful.placement.next_to(c, {
                preferred_positions = 'top',
                preferred_anchors   = 'middle',
                -- geometry            = ,
            })
        end
    }
    local tasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style   = {
            shape_border_width  = dpi(1),
            shape_border_color  = '#777777',
            shape               = gears.shape.rounded_bar,
        },
        layout  = {
            spacing         = dpi(3),
            max_widget_size = dpi(260),
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
                            shape         = gears.shape.rounded_bar,
                            forced_width  = dpi(36),
                            forced_height = dpi(36),
                            shape_clip    = gears.shape.rounded_bar,
                            widget        = wibox.container.background,
                        },
                        margins = dpi(2),
                        -- left    = dpi(3),
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
                            bg                  = '#fbdb6599',
                            fg                  = '#000000',
                            shape_border_width  = dpi(1),
                            shape_border_color  = '#00770080',
                            shape               = gears.shape.rounded_bar,
                            forced_width        = dpi(20),
                            widget              = wibox.container.background,
                        },
                        id      = 'tag_role',
                        margins = dpi(5),
                        widget  = wibox.container.margin,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                margins = dpi(0),
                widget  = wibox.container.margin,
            },
            id              = 'background_role',
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('tag_name')[1].text    = c:tags()[1].name
                self:get_children_by_id('tag_role')[1].visible = #s.selected_tags > 1
                self:connect_signal('mouse::enter', function()
                    awesome.emit_signal('bling::task_preview::visibility', s, true, c, self)
                end)
                self:connect_signal('mouse::leave', function()
                    awesome.emit_signal('bling::task_preview::visibility', s, false, c, self)
                end)
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




-- [ return module ] -----------------------------------------------------------
return module

