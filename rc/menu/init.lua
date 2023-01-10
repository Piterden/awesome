-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : init.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-26 16:52:54 (Marcel Arpogaus)
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
local capi = {awesome = awesome}

-- Standard awesome library
local awful = require('awful')

-- Theme handling library

local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup').widget

-- Freedesktop menu
local freedesktop = require('freedesktop')

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module objects ] ----------------------------------------------------------
module.init = function(config)

    -- This is used later as the default terminal and editor to run.
    local browser = config.browser
    local filemanager = config.filemanager
    local gui_editor = config.gui_editor
    local terminal = config.terminal
    local lock_command = config.lock_command
    local telegram = config.telegram
    local icon = menubar.utils.lookup_icon

    local myawesomemenu = {
        {
            'hotkeys',
            function()
                return false, hotkeys_popup.show_help
            end,
            icon('preferences-desktop-keyboard-shortcuts'),
        },
        {
            'manual',
            terminal .. ' -e man awesome',
            icon('system-help'),
        },
        {
            'edit config',
            gui_editor .. ' ' .. capi.awesome.conffile,
            icon('accessories-text-editor'),
        },
        {
            'restart',
            capi.awesome.restart,
            icon('system-restart'),
        }
    }

    module.mainmenu = freedesktop.menu.build(
        {
            icon_size = 64,
            before = {
                {
                    'Telegram',
                    telegram,
                    icon('telegram-desktop'),
                },
                {
                    'Terminal',
                    terminal,
                    icon('utilities-terminal'),
                },
                {
                    'Browser',
                    browser,
                    icon('internet-web-browser'),
                },
                {
                    'Files',
                    filemanager,
                    icon('system-file-manager'),
                }
            },
            after = {
                {
                    'Awesome',
                    myawesomemenu,
                    '/usr/share/awesome/icons/awesome32.png'
                }
            }
        }
    )

    if config.exitmenu then
        local myexitmenu = {
            {
                'Log out',
                function()
                    capi.awesome.quit()
                end,
                icon('system-log-out'),
            },
            {
                'Lock screen',
                lock_command,
                icon('system-lock-screen'),
            },
            {
                'Suspend',
                'systemctl suspend',
                icon('system-suspend'),
            },
            {
                'Hibernate',
                'systemctl hibernate',
                icon('system-suspend-hibernate'),
            },
            {
                'Reboot',
                'systemctl reboot',
                icon('system-reboot'),
            },
            {
                'Shutdown',
                'poweroff',
                icon('system-shutdown'),
            }
        }
        module.exitmenu = awful.menu({icon_size = 64, items = myexitmenu})
    end

    module.client_menu = awful.menu({ items = {
        { 'Maximize' },
        { 'Minimize' },
        { 'Move' },
        { '' },
        {},
        {},
    } })

    awesome.connect_signal('menus::hide::all', function ()
        module.mainmenu:hide()
        module.exitmenu:hide()
    end)
end

-- [ return module ] -----------------------------------------------------------
return module
