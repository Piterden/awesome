-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : init.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-01-26 16:52:44 (Marcel Arpogaus)
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
    root      = root,
    client    = client,
    screen    = screen,
    awesome   = awesome,
    selection = selection,
}

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
local naughty = require('naughty')

-- Theme handling library
local menubar = require('menubar')

-- hotkeys widget
local hotkeys_popup = require('awful.hotkeys_popup').widget

-- helper functions
local utils = require('rc.utils')


-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module functions ] --------------------------------------------------------
module.init = function(config, mainmenu)
    -- This is used later as the default terminal and editor to run.
    local browser       = config.browser
    local terminal      = config.terminal
    local lock_command  = config.lock_command

    -- Default modkey.
    local modkey = config.modkey
    local altkey = config.altkey

    module.global_keys = gears.table.join(
        -- [ awesome ]--------------------------------------------------------------
        awful.key(
            {modkey}, 's', hotkeys_popup.show_help,
            {description = 'show help', group = 'awesome'}
        ),
        awful.key(
            {modkey, 'Control'}, 'r', capi.awesome.restart,
            {description = 'reload awesome', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'q', function()
                awful.spawn(lock_command)
            end, {description = 'lock screen', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'F2', function()
                awful.spawn.easy_async_with_shell(
                    'xwininfo',
                    function(stdout, stderr, reason, code)
                        naughty.notify({
                            preset   = naughty.config.presets.info,
                            title    = 'xwininfo',
                            text     = stdout,
                            position = 'top_middle',
                            bg       = '#8c375bd0',
                            fg       = '#6ce17e',
                            timeout  = 0,
                        })
                    end
                )
            end, {description = 'xwininfo', group = 'debug'}
        ),
        awful.key(
            {modkey}, 'F3', function()
                awful.spawn.easy_async_with_shell(
                    'xprop',
                    function(stdout, stderr, reason, code)
                        naughty.notify({
                            preset   = naughty.config.presets.info,
                            title    = 'xprop',
                            text     = stdout,
                            position = 'top_middle',
                            bg       = '#8c375bd0',
                            fg       = '#6ce17e',
                            timeout  = 0,
                        })
                    end
                )
            end, {description = 'xprop', group = 'debug'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'q', capi.awesome.quit,
            {description = 'quit awesome', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'p', function()
                mainmenu:show()
            end, {description = 'show main menu', group = 'awesome'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'b', function()
                for s in capi.screen do
                    s.mytopwibar.visible = not s.mytopwibar.visible
                    s.mybottomwibar.visible = not s.mybottomwibar.visible
                end
            end, {description = 'toggle wibox', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'a', function()
                awful.spawn('/usr/bin/rofi -width 400 -lines 20 -columns 3 -dpi 150 -show drun -modi drun')
                -- awful.spawn('/usr/bin/rofi -show drun -modi drun')
            end, {description = 'launch rofi', group = 'launcher'}
        ),
        awful.key(
            {modkey}, 'e',
            function()
                local conf_dir = awful.util.getdir('config')
                local themes_dir = conf_dir .. "themes"
                local config_file = conf_dir .. "config.lua"
                awful.spawn.easy_async_with_shell(
                    "find " .. conf_dir .. " -type f " ..
                    " -name 'theme.lua' | sed -r 's|^.*/([^/]+)/[^/]+$|\\1|'" ..
                    " | sort | uniq | rofi -dmenu -dpi 72 -eh 2" ..
                    " -window-title 'Choose theme' -font 'hack 12'" ..
                    " -width 400 -lines 20 -columns 3 -select " .. config.theme,
                    function(stdout)
                        if stdout then
                            local updated_content = string.gsub(
                                utils.readAll(config_file),
                                "(module%.theme = ')[a-z0-9_-]*(')",
                                "%1" .. stdout:match("^%s*(.-)%s*$") .. "%2"
                            )
                            utils.write(config_file, updated_content)
                            capi.awesome.restart()
                        end
                    end
                )
            end,
            {description = 'Rofi AwesomeWM theme switcher', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'F1', function()
                awful.spawn.easy_async_with_shell('flameshot gui', function() end)
            end,
            {description = 'capture a screenshot', group = 'screenshot'}
        ),
        awful.key(
            {'Control'}, '`',
            function()
                local sel = capi.selection()
                if not sel or sel == '' then return end
                awful.spawn.easy_async_with_shell(
                    "gtrans " .. "\"" .. sel .. "\"",
                    function (stdout, stderr, reason, code)
                        naughty.notify({
                            preset   = naughty.config.presets.info,
                            title    = 'Translate selection',
                            text     = stdout,
                            position = 'top_middle',
                            bg       = '#1c375bd0',
                            fg       = '#fce17e',
                            timeout  = 10,
                            font     = 'Iosevka Medium 14',
                        })
                    end
                )
            end,
            {description = 'Translate selection', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'r', function()
                awful.prompt.run(
                    {
                        prompt = 'Run: ',
                        hooks = {
                            {
                                {}, 'Return',
                                function(command)
                                    local result = awful.spawn(command)
                                    awful.screen.focused().mypromptbox.widget:set_text(
                                        type(result) == 'string' and result or
                                            ''
                                    )
                                    return true
                                end
                            },
                            {
                                {altkey}, 'Return',
                                function(command)
                                    local result =
                                        awful.spawn(
                                            command, {
                                                tag = awful.screen.focused()
                                                    .selected_tag,
                                                intrusive = true
                                            }
                                        )
                                    awful.screen.focused().mypromptbox.widget:set_text(
                                        type(result) == 'string' and result or
                                            ''
                                    )
                                    return true
                                end
                            },
                            {
                                {'Shift'}, 'Return',
                                function(command)
                                    local result =
                                        awful.spawn(
                                            command, {
                                                intrusive = true,
                                                ontop = true,
                                                floating = true
                                            }
                                        )
                                    awful.screen.focused().mypromptbox.widget:set_text(
                                        type(result) == 'string' and result or
                                            ''
                                    )
                                    return true
                                end
                            }
                        }
                    },
                    awful.screen.focused().mypromptbox.widget,
                    nil,
                    awful.completion.shell,
                    awful.util.getdir('cache') .. '/history'
                )
            end,
            {description = 'run prompt', group = 'awesome'}
        ),
        awful.key(
            {modkey}, 'i',
            function()
                awful.prompt.run {
                    prompt = 'Run Lua code: ',
                    textbox = awful.screen.focused().mypromptbox.widget,
                    history_path = awful.util.get_cache_dir() .. '/history_eval',
                    hooks = {
                        {
                            {}, 'Return',
                            function(command)
                                awful.util.eval(command)
                            end
                        },
                        {
                            {modkey}, 'Return',
                            function(command)
                                local result = awful.util.eval(command)
                                if type(result) == 'string' and result then
                                    naughty.notify({
                                        preset        = naughty.config.presets.info,
                                        title         = 'Output',
                                        text          = result,
                                        position      = 'top_middle',
                                        timeout       = 10,
                                    })
                                end
                            end
                        },
                    },
                }
            end,
            {description = 'lua execute prompt', group = 'awesome'}
        ),
        -- [ tag ]------------------------------------------------------------------
        -- awful.key(
        --     {modkey}, 'Left', awful.tag.viewprev,
        --     {description = 'view previous', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey}, 'Right', awful.tag.viewnext,
        --     {description = 'view next', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey}, 'Escape', awful.tag.history.restore,
        --     {description = 'go back', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'n', utils.add_tag,
        --     {description = 'add new tag', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'r', utils.rename_tag,
        --     {description = 'rename tag', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'Left', function()
        --         utils.move_tag(-1)
        --     end, {description = 'move tag to the left', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'Right', function()
        --         utils.move_tag(1)
        --     end, {description = 'move tag to the right', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'd', utils.delete_tag,
        --     {description = 'delete tag', group = 'tag'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'f', utils.fork_tag,
        --     {description = 'fork tag', group = 'tag'}
        -- ),
        -- [ screen ]---------------------------------------------------------------
        awful.key(
            {modkey}, '`', function()
                awful.screen.focus_relative(1)
            end, {description = 'focus the next screen', group = 'screen'}
        ),
        awful.key(
            {modkey}, 'k', function()
                awful.screen.focus_relative(-1)
            end, {description = 'focus the previous screen', group = 'screen'}
        ),
        -- [ client ]---------------------------------------------------------------
        awful.key(
            {modkey, 'Shift'}, 'j', function()
                awful.client.swap.byidx(1)
            end,
            {description = 'swap with next client by index', group = 'client'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'k', function()
                awful.client.swap.byidx(-1)
            end, {
                description = 'swap with previous client by index',
                group = 'client'
            }
        ),
        awful.key(
            {modkey}, 'u', awful.client.urgent.jumpto,
            {description = 'jump to urgent client', group = 'client'}
        ),
        -- awful.key(
        --     {modkey}, 'Tab', function()
        --         awful.client.focus.history.previous()
        --         if capi.client.focus then
        --             capi.client.focus:raise()
        --         end
        --     end, {description = 'go back', group = 'client'}
        -- ),
        -- awful.key(
        --     {modkey, 'Shift'}, 'Tab', function()
        --         awful.tag.history.restore()
        --         if capi.client.focus then
        --             capi.client.focus:raise()
        --         end
        --     end, {description = 'go back', group = 'tag'}
        -- ),
        awful.key(
            {modkey}, 'Tab', function()
                awful.client.focus.byidx(1)
            end, {description = 'focus previous by index', group = 'client'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'Tab', function()
                awful.client.focus.byidx(-1)
            end, {description = 'focus next by index', group = 'client'}
        ),
        awful.key(
            {modkey, 'Control'}, 'n', function()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                    capi.client.focus = c
                    c:raise()
                end
            end, {description = 'restore minimized', group = 'client'}
        ),
        awful.key(
            {altkey, 'Control'}, '=', function()
                utils.gaps_resize(2)
            end, {description = 'increment useless gaps', group = 'client'}
        ),
        awful.key(
            {altkey, 'Control'}, '-', function()
                utils.gaps_resize(-2)
            end, {description = 'decrement useless gaps', group = 'client'}
        ),
        -- awful.key(
        --     {altkey}, 'Tab', function()
        --         switcher.switch( 1, 'Mod1', 'Alt_L', 'Shift', 'Tab')
        --     end, {description = 'switch apps', group = 'client'}
        -- ),
        -- awful.key(
        --     {altkey, 'Shift'}, 'Tab', function()
        --         switcher.switch(-1, 'Mod1', 'Alt_L', 'Shift', 'Tab')
        --     end, {description = 'switch apps backward', group = 'client'}
        -- ),
        -- awful.key(
        --     {altkey}, 'Tab', utils.application_switcher,
        --     {description = 'restore minimized', group = 'client'}
        -- ),
        -- [ launcher ]-------------------------------------------------------------
        awful.key(
            {modkey}, 'w', function()
                menubar.show()
            end, {description = 'show the menubar', group = 'launcher'}
        ),
        awful.key(
            {modkey}, 'Return', function()
                awful.spawn(terminal, {intrusive = true})
            end, {description = 'open a terminal', group = 'launcher'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'Return', function()
                awful.spawn(
                    terminal, {intrusive = true, floating = true, ontop = true}
                )
            end, {description = 'open a floating terminal', group = 'launcher'}
        ),
        awful.key(
            {modkey}, 'b', function()
                awful.spawn(browser)
            end, {description = 'launch Browser', group = 'launcher'}
        ),
        -- [ layout ]---------------------------------------------------------------
        awful.key(
            {altkey, 'Shift'},
            'Right',
            function()
                awful.tag.incmwfact(0.05)
            end,
            {description = 'Increase master width factor', group = 'layout'}
        ),
        awful.key(
            {altkey, 'Shift'},
            'Left',
            function()
                awful.tag.incmwfact(-0.05)
            end,
            {description = 'Decrease master width factor', group = 'layout'}
        ),
        awful.key(
            {altkey, 'Shift'},
            'Down',
            function()
                awful.client.incwfact(0.05)
            end,
            {description = 'Decrease master height factor', group = 'layout'}
        ),
        awful.key(
            {altkey, 'Shift'},
            'Up',
            function()
                awful.client.incwfact(-0.05)
            end,
            {description = 'Increase master height factor', group = 'layout'}
        ),
        -- awful.key(
        --     {modkey}, 'l', function()
        --         awful.tag.incmwfact(0.05)
        --     end,
        --     {description = 'increase master width factor', group = 'layout'}
        -- ),
        -- awful.key(
        --     {modkey}, 'h', function()
        --         awful.tag.incmwfact(-0.05)
        --     end,
        --     {description = 'decrease master width factor', group = 'layout'}
        -- ),
        awful.key(
            {modkey, 'Shift'}, 'h', function()
                awful.tag.incnmaster(1, nil, true)
            end, {
                description = 'increase the number of master clients',
                group = 'layout'
            }
        ),
        awful.key(
            {modkey, 'Shift'}, 'l', function()
                awful.tag.incnmaster(-1, nil, true)
            end, {
                description = 'decrease the number of master clients',
                group = 'layout'
            }
        ),
        awful.key(
            {modkey, 'Control'}, 'h', function()
                awful.tag.incncol(1, nil, true)
            end,
            {description = 'increase the number of columns', group = 'layout'}
        ),
        awful.key(
            {modkey, 'Control'}, 'l', function()
                awful.tag.incncol(-1, nil, true)
            end,
            {description = 'decrease the number of columns', group = 'layout'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'space', function()
                awful.layout.inc(1)
            end, {description = 'select previous', group = 'layout'}
        ),
        -- [ screenshot ]-----------------------------------------------------------
        -- awful.key(
        --     {}, 'Print', function()
        --         awful.spawn.with_shell('sleep 0.1 && /usr/bin/i3-scrot -d')
        --     end, {description = 'capture a screenshot', group = 'screenshot'}
        -- ),
        -- awful.key(
        --     {'Control'}, 'Print', function()
        --         awful.spawn.with_shell('sleep 0.1 && /usr/bin/i3-scrot -w')
        --     end, {
        --         description = 'capture a screenshot of active window',
        --         group = 'screenshot'
        --     }
        -- ),
        -- awful.key(
        --     {'Shift'}, 'Print', function()
        --         awful.spawn.with_shell('sleep 0.1 && /usr/bin/i3-scrot -s')
        --     end, {
        --         description = 'capture a screenshot of selection',
        --         group = 'screenshot'
        --     }
        -- ),
        -- [ theme ]----------------------------------------------------------------
        -- awful.key(
        --     {modkey, altkey, 'Control'}, 'l', utils.set_light,
        --     {description = 'set light colorscheme', group = 'theme'}
        -- ),
        -- awful.key(
        --     {modkey, altkey, 'Control'}, 'm', utils.set_mirage,
        --     {description = 'set mirage colorscheme', group = 'theme'}
        -- ),
        -- awful.key(
        --     {modkey, altkey, 'Control'}, 'd', utils.set_dark,
        --     {description = 'set dark colorscheme', group = 'theme'}
        -- ),
        awful.key(
            {modkey, altkey, 'Control'}, '=', function()
                utils.inc_dpi(10)
            end, {description = 'increase dpi', group = 'theme'}
        ),
        awful.key(
            {modkey, altkey, 'Control'}, '-', function()
                utils.dec_dpi(10)
            end, {description = 'decrease dpi', group = 'theme'}
        ),
        -- [ widgets ]--------------------------------------------------------------
        awful.key(
            {modkey, 'Shift'}, 'w', utils.toggle_wibar_widgets,
            {description = 'toggle wibar widgets', group = 'widgets'}
        ),
        -- awful.key(
        --     {modkey, altkey, 'Shift'}, 'w',
        --     utils.toggle_desktop_widget_visibility, {
        --         description = 'toggle desktop widget visibility',
        --         group = 'widgets'
        --     }
        -- ),
        awful.key(
            {modkey, 'Shift'}, 'u', utils.update_widgets,
            {description = 'update widgets', group = 'widgets'}
        )
    )

    module.client_keys = gears.table.join(
        awful.key(
            {modkey}, 'f', function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end, {description = 'toggle fullscreen', group = 'client'}
        ),
        awful.key(
            {modkey}, 'x', function(c)
                c:kill()
            end, {description = 'close', group = 'client'}
        ),
        awful.key(
            {modkey, 'Control'}, 'space', function(c)
                awful.client.floating.toggle(c)
                c:raise()
            end, {description = 'toggle floating', group = 'client'}
        ),
        awful.key(
            {modkey, 'Control'}, 'Return', function(c)
                c:swap(awful.client.getmaster())
            end, {description = 'move to master', group = 'client'}
        ),
        awful.key(
            {modkey}, 'o', function(c)
                c:move_to_screen()
            end, {description = 'move to screen', group = 'client'}
        ),
        awful.key(
            {modkey}, 't', function(c)
                c.ontop = not c.ontop
            end, {description = 'toggle keep on top', group = 'client'}
        ),
        awful.key(
            {modkey}, 'n', function(c)
                c.minimized = true
            end, {description = 'minimize', group = 'client'}
        ),
        awful.key(
            {modkey}, 'm', function(c)
                c.maximized = not c.maximized
                c:raise()
            end, {description = '(un)maximize', group = 'client'}
        ),
        awful.key(
            {modkey, 'Control'}, 'm', function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end, {description = '(un)maximize vertically', group = 'client'}
        ),
        awful.key(
            {modkey, 'Shift'}, 'm', function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end, {description = '(un)maximize horizontally', group = 'client'}
        )
    )

    -- Bind all key numbers to tags.
    -- Be careful: we use keycodes to make it works on any keyboard layout.
    -- This should map on the top row of your keyboard, usually 1 to 9.
    for i = 1, 9 do
        -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
        local descr_view, descr_toggle, descr_move, descr_toggle_focus
        if i == 1 or i == 9 then
            descr_view = {description = 'view tag #', group = 'tag'}
            descr_toggle = {description = 'toggle tag #', group = 'tag'}
            descr_move = {
                description = 'move focused client to tag #',
                group = 'tag'
            }
            descr_toggle_focus = {
                description = 'toggle focused client on tag #',
                group = 'tag'
            }
        end
        module.global_keys = gears.table.join(
            module.global_keys, -- View tag only.
            awful.key(
                {modkey}, '#' .. i + 9, function()
                    local s = awful.screen.focused()
                    local tag = s.tags[i]
                    if tag then
                        tag:view_only()
                    end
                end, descr_view
            ),
            -- [ toggle tag display ]-----------------------------------------------
            awful.key(
                {modkey, 'Control'}, '#' .. i + 9, function()
                    local s = awful.screen.focused()
                    local tag = s.tags[i]
                    if tag then
                        awful.tag.viewtoggle(tag)
                    end
                end, descr_toggle
            ),
            -- [ move client to tag ]-----------------------------------------------
            awful.key(
                {modkey, 'Shift'}, '#' .. i + 9, function()
                    if capi.client.focus then
                        local tag = capi.client.focus.screen.tags[i]
                        if tag then
                            capi.client.focus:move_to_tag(tag)
                        end
                    end
                end, descr_move
            ),
            -- [ toggle tag on focused client ]-------------------------------------
            awful.key(
                {modkey, 'Control', 'Shift'}, '#' .. i + 9, function()
                    if capi.client.focus then
                        local tag = capi.client.focus.screen.tags[i]
                        if tag then
                            capi.client.focus:toggle_tag(tag)
                        end
                    end
                end, descr_toggle_focus
            )
        )
    end

    -- register global key bindings
    capi.root.keys(module.global_keys)
end

-- [ return module ] -----------------------------------------------------------
return module
