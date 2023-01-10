local gears = require('gears')
local awful = require('awful')
local xresources = require('beautiful.xresources')
local dpi = xresources.apply_dpi

local module = {}

-- [ applications ] ------------------------------------------------------------
module.browser = 'google-chrome-stable'
module.filemanager = 'thunar'
module.telegram = 'telegram-desktop'
module.gui_editor = os.getenv('EDITOR') or 'nano'
module.lock_command = 'blurlock -f'
module.terminal = os.getenv('TERMINAL') or 'xterm'

-- [ key bindings ] ------------------------------------------------------------
-- Default modkey.
module.altkey = 'Mod1'
module.modkey = 'Mod4'

-- [ behavior ] ----------------------------------------------------------------
-- use dynamic tagging
-- module.dynamic_tagging = true

-- add exitmenu to wibar
module.exitmenu = true

-- add awesome menu and launcher to wibar
module.mainmenu = true

-- behavior of the task list. set to 'windows' to get windows-like client grouping
-- module.tasklist = 'windows'

-- overwrite default layout list
-- module.layouts = {
--   awful.layout.suit.corner.nw,
--   awful.layout.suit.tile,
--   awful.layout.suit.tile.left,
--   awful.layout.suit.fair,
--   awful.layout.suit.fair.horizontal,
--   awful.layout.suit.spiral.dwindle,
--   awful.layout.suit.magnifier,
--   awful.layout.suit.floating,
-- }
-- -- index of default layout to use on new tags
-- module.default_layout = 1

-- [ appearance ] --------------------------------------------------------------
-- module.dpi = 144 -- set explicit dpi for every screen
-- module.auto_dpi = true

-- set custom theme assets ('recolor', 'mac')
-- module.assets = 'mac'

-- Select theme
module.theme = 'redhalo'
local themedir = awful.util.getdir("config") .. "/themes/" .. module.theme
module.theme_overwrite = {
  gap_single_client       = false,
  fullscreen_hide_border  = true,
  useless_gap             = 1,
  border_width            = dpi(1),
  menu_bg_normal          = '#262729d8',
  menu_height             = dpi(32),
  menu_width              = dpi(300),
  menu_font               = 'Iosevka Bold 11',
  top_bar_height          = dpi(24),
  bottom_bar_height       = dpi(40),
  icon_theme              = 'Numix Circle',
  menu_icon_theme         = 'Numix Circle',
  titlebar_font           = 'Iosevka Light 10',

  titlebar_bg_focus       = '#a6e22e80',
  titlebar_fg_focus       = '#262729',
  titlebar_bg_normal      = '#262729d8',
  -- titlebar_fg_normal       = '#262729',
  -- bg_focus                = '#14b879FF',
  -- fg_focus                = '#000000',
  -- tasklist_font            = 'Iosevka Regular 8',
  -- tasklist_fg_normal       = '#ffffff',
  -- tasklist_fg_focus        = '#000000',
  font                    = 'Iosevka Medium 9',
  -- tabbar_style            = 'xresources',
  -- tabbar_fg_focus          = '#ff2500',
  -- tabbar_bg_focus          = '#16A085',
  -- tabbar_font              = 'Iosevka Medium 11',
  -- tabbar_size              = dpi(12),
  -- titlebar_marked_button_normal_active = themedir .. "/titlebar/close_normal-red.png",
  -- titlebar_marked_button_normal_inactive = themedir .. "/titlebar/close_normal-red.png",
  -- titlebar_marked_button_focus_active = themedir .. "/titlebar/close_normal-red.png",
  -- titlebar_marked_button_focus_inactive = themedir .. "/titlebar/close_normal-red.png",
  -- titlebar_marked_button_normal_active = gears.surface.load_from_shape(dpi(15), dpi(30), gears.shape.rectangle, '#00000088'),
  -- titlebar_marked_button_normal_inactive = gears.surface.load_from_shape(dpi(15), dpi(30), gears.shape.rectangle, '#ffffff88'),
  -- titlebar_marked_button_focus_active = gears.surface.load_from_shape(dpi(15), dpi(30), gears.shape.rectangle, '#FFFFFF'),
  -- titlebar_marked_button_focus_inactive = gears.surface.load_from_shape(dpi(15), dpi(30), gears.shape.rectangle, '#FFFFFF'),
}

-- path to your wallpaper or 'xfconf-query' to use xconf
-- module.wallpaper

-- [ widgets ] -----------------------------------------------------------------

-- select desktop elements ('arcs')
-- module.desktop = 'arcs'

-- hide desktop widgets
-- module.desktop_widgets_visible = false

-- widgets to be added to the desktop pop up
-- module.arc_widgets = {'cpu', 'mem', 'fs', 'bat'}

-- select wibar configuration ('default'|'dual')
module.wibar = 'dual'

-- widgets to be added to wibar
module.wibar_widgets = {
-- 	'net_down',
-- 	'net_up',
    'temp',
    'cpu',
    'fs',
--	'weather',
   	'mem',
--  'bat',
--  'vol',
    'datetime',
}


-- configure widgets
module.widgets_arg = {
--     weather = {
--         -- city and app id for the weather widget
--         city_id = 'change_me',
--         app_id = 'change_me'
--     },
    temp = {
        -- set resource for temperature widget
        thermal_zone = 'thermal_zone0'
--    },
--    net = {
--        -- network interface
--        net_interface = 'wlp3s0'
    }
}

return module
