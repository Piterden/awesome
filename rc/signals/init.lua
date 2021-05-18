-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : init.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-26 16:53:38 (Marcel Arpogaus)
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
    tag = tag,
    mouse = mouse,
    client = client,
    screen = screen,
    awesome = awesome,
}

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
local aclient = require("awful.client")

-- Widget and layout library
local wibox = require('wibox')

-- Theme handling library
local beautiful = require('beautiful')

-- helper functions
local utils = require('rc.utils')

-- [ local objects ] -----------------------------------------------------------
local module = {}

--- Create a new marked button for a client.
-- @param c The client for which the button is wanted.
function awful.titlebar.widget.markedbutton(c)
    local widget = awful.titlebar.widget.button(
        c,
        "marked",
        aclient.object.get_marked,
        function()
            c.marked = ~c.marked
        end
    )
    c:connect_signal("property::marked", widget.update)
    return widget
end

-- [ module functions ] --------------------------------------------------------
module.init = function()
    -- Signal function to execute when a new client appears.
    capi.client.connect_signal(
        'request::manage', function(c)
            if capi.awesome.startup and not c.size_hints.user_position and
                not c.size_hints.program_position then
                -- Prevent clients from being unreachable after screen count changes.
                awful.placement.no_offscreen(c)
            end
        end
    )

    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    capi.client.connect_signal(
        'request::titlebars', function(c)
            if c.requests_no_titlebar then
                return
            end
            -- buttons for the titlebar
            local buttons = gears.table.join(
                awful.button(
                    {}, 1,
                    function()
                        c.mouse_coords = capi.mouse.coords()
                        c:emit_signal('request::activate', 'titlebar', {raise = true})
                        c.move_timer = gears.timer({
                            timeout = 0.3,
                            callback = function()
                                capi.mouse.coords(c.mouse_coords)
                                awful.mouse.client.move(c)
                                c.move_timer   = nil
                                c.mouse_coords = nil
                            end,
                            single_shot = true,
                        })
                        c.move_timer:start()
                    end,
                    function()
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
                        c:emit_signal('request::activate', 'titlebar', {raise = true})
                        c.resize_timer = gears.timer({
                            timeout = 0.3,
                            callback = function()
                                capi.mouse.coords(c.mouse_coords)
                                awful.mouse.client.resize(c)
                                c.resize_timer = nil
                                c.mouse_coords = nil
                            end,
                            single_shot = true,
                        })
                        c.resize_timer:start()
                    end,
                    function()
                        if (c.resize_timer) then
                            c.resize_timer:stop()
                            c.resize_timer = nil
                            c.mouse_coords = nil
                        end
                    end
                )
            )

            awful.titlebar(c):setup{
                { -- Left
                    awful.titlebar.widget.iconwidget(c),
                    buttons = buttons,
                    layout = wibox.layout.fixed.horizontal
                },
                { -- Middle
                    { -- Title
                        align = 'center',
                        widget = awful.titlebar.widget.titlewidget(c)
                    },
                    buttons = buttons,
                    layout = wibox.layout.flex.horizontal
                },
                { -- Right
                    awful.titlebar.widget.markedbutton(c),
                    awful.titlebar.widget.floatingbutton(c),
                    awful.titlebar.widget.stickybutton(c),
                    awful.titlebar.widget.ontopbutton(c),
                    awful.titlebar.widget.maximizedbutton(c),
                    awful.titlebar.widget.minimizebutton(c),
                    awful.titlebar.widget.closebutton(c),
                    layout = wibox.layout.fixed.horizontal()
                },
                layout = wibox.layout.align.horizontal
            }
        end
    )

    -- Enable sloppy focus, so that focus follows mouse.
    capi.client.connect_signal(
        'mouse::enter', function(c)
            if awful.layout.get(c.screen).name ~= 'magnifier' then
                c:emit_signal(
                    'request::activate', 'mouse_enter', {raise = false}
                )
            end

            local focused_screen = awful.screen.focused()
            if not capi.awesome.startup and focused_screen.systray then
                focused_screen.systray:set_screen(focused_screen)
            end
        end
    )

    capi.client.connect_signal(
        'focus', function(c)
            c.border_color = beautiful.border_focus
        end
    )
    capi.client.connect_signal(
        'unfocus', function(c)
            c.border_color = beautiful.border_normal
        end
    )
    capi.client.connect_signal(
        'property::screen', function()
            local focused_screen = awful.screen.focused()
            if not capi.awesome.startup and focused_screen.systray then
                focused_screen.systray:set_screen(focused_screen)
            end
        end
    )

    -- Disable borders on lone windows
    -- Handle border sizes of clients.
    for s = 1, capi.screen.count() do
        capi.screen[s]:connect_signal(
            'arrange', function()
                local clients = awful.client.visible(s)
                local layout = awful.layout.getname(awful.layout.get(s))

                for _, c in pairs(clients) do
                    -- No borders with only one humanly visible client
                    if c.maximized then
                        -- NOTE: also handled in focus, but that does not cover maximizing from a
                        -- tiled state (when the client had focus).
                        c.border_width = 0
                    elseif c.floating or layout == 'floating' then
                        c.border_width = beautiful.border_width
                    elseif layout == 'max' or layout == 'fullscreen' then
                        c.border_width = 0
                    else
                        local tiled = awful.client.tiled(c.screen)
                        if #tiled == 1 then -- and c == tiled[1] then
                            tiled[1].border_width = 0
                            -- if layout ~= "max" and layout ~= "fullscreen" then
                            -- XXX: SLOW!
                            -- awful.client.moveresize(0, 0, 2, 0, tiled[1])
                            -- end
                        else
                            c.border_width = beautiful.border_width
                        end
                    end
                end
            end
        )
    end
    capi.awesome.connect_signal('screen::change', function(s)
        gears.debug.dump(s)
    end)
    -- capi.client.connect_signal(
    --     'property::floating', function(c)
    --         if c.floating and not c.requests_no_titlebars then
    --             awful.titlebar.show(c)
    --         else
    --             awful.titlebar.hide(c)
    --         end
    --     end
    -- )
    -- capi.tag.connect_signal(
    --     'property::layout', function(t)
    --         for _, c in pairs(t:clients()) do
    --             if t.layout.name == 'floating' and not c.requests_no_titlebars then
    --                 awful.titlebar.show(c)
    --             else
    --                 awful.titlebar.hide(c)
    --             end
    --         end
    --     end
    -- )
end

-- [ return module ] -----------------------------------------------------------
return module
