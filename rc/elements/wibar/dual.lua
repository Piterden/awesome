-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : wibars.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-22 09:11:30 (Marcel Arpogaus)
-- @Changed: 2021-01-23 20:30:11 (Marcel Arpogaus)
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
local capi = {root = root}
local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = require('beautiful.xresources').apply_dpi

local abstract_element = require('rc.elements.abstract_element')
local utils = require('rc.elements.wibar.utils')

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module functions ] --------------------------------------------------------
module.init = function(config)
    local element = abstract_element.new {
        register_fn = function(s)
            s.mytopwibar = awful.wibar(
                {
                    position = 'top',
                    screen = s,
                    -- height = 32,
                    height = beautiful.top_bar_height,
                    bg = beautiful.bg_normal,
                    fg = beautiful.fg_normal
                }
            )

            -- Add widgets to the wibox
            s.right_widget_container = utils.gen_wibar_widgets(s, config)
            s.right_widget_container.layout = wibox.layout.fixed.horizontal
            if s.myexitmenu then
                local myexitmenu = {
                    -- add margins
                    s.myexitmenu,
                    left = beautiful.wibar_widgets_spacing or dpi(12),
                    widget = wibox.container.margin
                }
                table.insert(s.right_widget_container, myexitmenu)
            end

            s.left_widget_container = {}
            table.insert(s.left_widget_container, s.mytaglist)
            table.insert(s.left_widget_container, s.mypromptbox)
            s.left_widget_container.layout = wibox.layout.fixed.horizontal

            s.mytopwibar:setup{
                layout = wibox.layout.align.horizontal,
                s.left_widget_container, -- Left widgets
                {
                    layout = wibox.layout.flex.horizontal,
                    widget = wibox.widget.graph,
                }, -- Middle widget
                s.right_widget_container -- Right widgets
            }

            -- Create the bottom wibox
            s.mybottomwibar = awful.wibar(
                {
                    position = 'bottom',
                    screen = s,
                    -- height = 32,
                    height = beautiful.bottom_bar_height or dpi(32),
                    bg = beautiful.bg_normal,
                    fg = beautiful.fg_normal
                }
            )

            -- Add widgets to the bottom wibox
            s.systray = wibox.widget.systray()
            s.mybottomwibar:setup{
                layout = wibox.layout.align.horizontal,
                -- {
                --     layout = wibox.layout.align.horizontal,
                -- },
                {
                    s.mymainmenu,
                    right = dpi(5),
                    widget = wibox.container.margin,
                },
                s.mytasklist,
                -- nil,
                {
                    {
                        s.systray,
                        margins = dpi(3),
                        widget = wibox.container.margin,
                    },
                    awful.widget.keyboardlayout(),
                    s.mylayoutbox,
                    spacing = beautiful.icon_margin_left,
                    layout  = wibox.layout.fixed.horizontal
                }
            }
            local geom  = s.geometry
            s.myoverlay = wibox({
                screen  = s,
                x       = geom.x,
                y       = geom.y + beautiful.top_bar_height,
                visible = true,
                opacity = 0,
                ontop   = false,
                type    = 'splash',
                width   = geom.width,
                height  = geom.height - beautiful.top_bar_height - beautiful.bottom_bar_height,
            })

            s.systray_set_screen = function()
                if s.systray then
                    s.systray:set_screen(s)
                end
            end

            s.myoverlay:buttons(gears.table.join(
                awful.button({}, 1,
                    function()
                        s.mymainmenu:show()
                    end
                )
                -- awful.button({}, 3,
                --     function(self)
                --         local coords = mouse.coords()
                --         -- gears.debug.dump(x, y)
                --         self.input_passthrough = true
                --         capi.root.fake_input('button_press', 3)
                --         self.input_passthrough = false
                --     end,
                --     capi.root.fake_input('button_release', 3)
                -- ),
                -- awful.button({}, 4,
                --     function(self)
                --         local coords = mouse.coords()
                --         -- gears.debug.dump(coords.x, coords.y)
                --         self.input_passthrough = true
                --         capi.root.fake_input('button_press', 4)
                --         self.input_passthrough = false
                --     end,
                --     capi.root.fake_input('button_release', 4)
                -- ),
                -- awful.button({}, 5,
                --     function(self)
                --         local coords = mouse.coords()
                --         -- gears.debug.dump(coords.x, coords.y)
                --         self.input_passthrough = true
                --         capi.root.fake_input('button_press', 5)
                --         self.input_passthrough = false
                --     end,
                --     capi.root.fake_input('button_release', 5)
                -- )
            ))

            s.myoverlay:connect_signal('mouse::enter', s.systray_set_screen)
            s:connect_signal('mouse::enter', s.systray_set_screen)
        end,
        unregister_fn = function(s)
            utils.unregister_wibar_widgtes(s)

            s.myoverlay:remove()
            s.myoverlay = nil

            s.mytopwibar.widget:reset()
            s.mytopwibar:remove()
            s.mytopwibar = nil

            s.mybottomwibar.widget:reset()
            s.mybottomwibar:remove()
            s.mybottomwibar = nil
        end,
        update_fn = function(s)
            utils.update_wibar_widgets(s)
        end
    }
    return element
end

-- [ sequential code ] ---------------------------------------------------------

-- [ return module ] -----------------------------------------------------------
return module
