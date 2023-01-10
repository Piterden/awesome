-- [ author ] -*- time-stamp-pattern: '@Changed[\s]?:[\s]+%%$'; -*- ------------
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
            s.mytopwibar = awful.wibar({
                position = 'top',
                screen   = s,
                height   = beautiful.top_bar_height,
                bg       = beautiful.bg_normal,
                fg       = beautiful.fg_normal
            })

            local right_widget_container = utils.gen_wibar_widgets(s, config)
            right_widget_container.layout = wibox.layout.fixed.horizontal

            local left_widget_container = {
                s.mytaglist,
                s.mypromptbox,
                layout = wibox.layout.fixed.horizontal,
            }

            s.mytopwibar:setup{
                left_widget_container,
                nil,
                {
                    right_widget_container,
                    {
                        {
                            {
                                {
                                    markup = '<b>🔒</b>',
                                    widget = wibox.widget.textbox,
                                },
                                halign = 'center',
                                valign = 'center',
                                widget = wibox.container.place,
                            },
                            s.myexitmenu,
                            layout = wibox.layout.stack,
                        },
                        forced_width = beautiful.top_bar_height,
                        widget       = wibox.container.background,
                    },
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(4),
                },
                layout = wibox.layout.align.horizontal,
            }

            -- Create the bottom wibox
            s.mybottomwibar = awful.wibar({
                position = 'bottom',
                screen   = s,
                height   = beautiful.bottom_bar_height or dpi(32),
                bg       = beautiful.bg_normal,
                fg       = beautiful.fg_normal
            })

            -- Add widgets to the bottom wibox
            s.systray = wibox.widget.systray()

            s.mybottomwibar:setup{
                {
                    s.mymainmenu,
                    right = dpi(5),
                    widget = wibox.container.margin,
                },
                s.mytasklist,
                {
                    {
                        s.systray,
                        margins = dpi(3),
                        widget  = wibox.container.margin,
                    },
                    awful.widget.keyboardlayout(),
                    s.mylayoutbox,
                    spacing = beautiful.icon_margin_left,
                    layout  = wibox.layout.fixed.horizontal,
                },
                layout = wibox.layout.align.horizontal,
            }
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
