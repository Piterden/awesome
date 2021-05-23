-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : taglist.lua
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

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module functions ] --------------------------------------------------------
module.init = function(s, taglist_buttons)
    local taglist = awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        buttons         = taglist_buttons,
        widget_template = {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                    -- valign = 'center',
                    -- halign = 'center',
                },
                id = 'text_margin_role',
                left = 7,
                right = 7,
                widget = wibox.container.margin,
            },
            forced_width = 20,
            -- forced_height = 20,
            id     = 'background_role',
            -- bg = '#000000',
            -- border_width = 1,
            -- border_color = '#ffffff',
            widget = wibox.container.background,
            create_callback = function(self, t, index, objects) --luacheck: no unused args
                -- BLING: Update the widget with the new tag
                self:get_children_by_id('text_role')[1]:set_markup('<b> '..t.name..' </b>')
                -- self:get_children_by_id('text_role')[1].markup = '<b> '..t.name..' </b>'

                self:connect_signal('mouse::enter', function(w)
                    -- gears.debug.dump(f)
                    -- BLING: Only show widget when there are clients in the tag
                    if #t:clients() > 0 then
                        -- BLING: Update the widget with the new tag
                        awesome.emit_signal("bling::tag_preview::update", t)
                        -- BLING: Show the widget
                        awesome.emit_signal("bling::tag_preview::visibility", s, true)
                    end
                end)

                self:connect_signal('mouse::leave', function()
                    if #t:clients() > 0 then
                        -- BLING: Turn the widget off
                        awesome.emit_signal("bling::tag_preview::visibility", s, false)
                    end
                end)
            end,
            update_callback = function(self, t, index, objects) --luacheck: no unused args
                -- BLING: Update the widget with the new tag
                -- self:get_children_by_id('text_role')[1].markup = '<b> '..t.name..' </b>'
            end,
        },
    }
    return taglist
end

-- [ return module ] -----------------------------------------------------------
return module

