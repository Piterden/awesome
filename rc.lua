-- [ author ] -*- time-stamp-pattern: '@Changed[\s]?:[\s]+%%$'; -*- ------------
-- @File   : rc.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-26 16:56:54 (Marcel Arpogaus)
-- @Changed: 2021-01-26 17:18:28 (Marcel Arpogaus)
-- [ description ] -------------------------------------------------------------
-- This file is part of my modular awesome WM configuration.
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
local os = os
local client = client

-- Standard awesome library
local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local naughty = require('naughty')

-- rc modules
local menu = require('rc.menu')
local tags = require('rc.tags')
local rules = require('rc.rules')
local utils = require('rc.utils')
local assets = require('rc.assets')
local screen = require('rc.screen')
local themes = require('rc.themes')
local layouts = require('rc.layouts')
local signals = require('rc.signals')
local elements = require('rc.elements')
local key_bindings = require('rc.key_bindings')
local error_handling = require('rc.error_handling')
local mouse_bindings = require('rc.mouse_bindings')

-- Mac OSX like 'Expose' view of all clients.
-- local revelation = require('revelation')

-- configuration file
local config = utils.load_config()

-- ensure that there's always a client that has focus
require('awful.autofocus')

local vicious = require('vicious')

naughty.config.icon_dirs = {
  '/home/den/.local/share/icons',
  '/usr/share/pixmaps',
  '/usr/share/icons/ArchLabs/48x48/status/',
  '/usr/share/icons/ArchLabs/48x48/devices/',
}
naughty.config.icon_formats = { 'png', 'gif', 'svg' }

-- [ initialization ] ----------------------------------------------------------
-- error handling
error_handling.init()

-- tags
tags.init(config)

-- layouts
layouts.init(config)

-- theme
themes.init(config)
local bling = require('bling')
local tabbed = require('bling.module.tabbed')
awful.client.object.tabbed_module = tabbed

bling.widget.tag_preview.enable {
    show_client_content = true, -- Whether or not to show the client content
    x                   = 0,    -- The x-coord of the popup
    y                   = 30,    -- The y-coord of the popup
    scale               = 0.2,  -- The scale of the previews compared to the screen
    honor_padding       = false, -- Honor padding when creating widget size
    honor_workarea      = false, -- Honor work area when creating widget size
}

-- assets
assets.init(config)

-- wibars and widgest
elements.init(config)

-- menues
menu.init(config)

-- mouse bindings
mouse_bindings.init(config, menu.mainmenu, menu.clientmenu)

-- key bindings
key_bindings.init(config, menu.mainmenu)

-- connect signals
signals.init(mouse_bindings.titlebar_buttons)

-- rules
rules.init(config, mouse_bindings.client_buttons, key_bindings.client_keys)

-- wibars and widgets
screen.init(
    config, tags.tagnames, mouse_bindings.taglist_buttons,
    mouse_bindings.tasklist_buttons, menu.mainmenu, menu.exitmenu
)
screen.register(elements.wibar)
if elements.desktop then
  screen.register(elements.desktop)
end

-- Initialize revelation
-- revelation.init()

local kbdlayout = require('rc.kbdlayout')


-- [[ ls -l ~/.config/awesome/themes | grep -P '^d.*' | awk '{print $NF}' | grep -Fv 'icons' ]]
-- [[ find ~/.config/awesome/themes -type f -name 'theme.lua' | sed -r 's|^.*/([^/]+)/[^/]+$|\1|' | sort | uniq ]]

-- [ autorun programs ] --------------------------------------------------------
awful.spawn.with_shell('~/.config/awesome/autorun.sh')
