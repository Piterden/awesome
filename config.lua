local gears = require('gears')
local awful = require('awful')
local xresources = require('beautiful.xresources')
local dpi = xresources.apply_dpi

local module = {}

-- [ applications ] ------------------------------------------------------------
module.browser = 'exo-open --launch WebBrowser' or 'firefox'
module.filemanager = 'exo-open --launch FileManager' or 'thunar'
module.gui_editor = os.getenv('EDITOR') or 'nano'
module.lock_command = 'blurlock -f'
module.telegram = 'telegram-desktop'
module.terminal = os.getenv('TERMINAL') or 'urxvt'

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
module.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.magnifier,
  awful.layout.suit.floating,
  awful.layout.suit.corner.nw,
}
-- index of default layout to use on new tags
module.default_layout = 4

-- [ appearance ] --------------------------------------------------------------
-- module.dpi = 144 -- set explicit dpi for every screen
-- module.auto_dpi = true

-- set custom theme assets ('recolor', 'mac')
-- module.assets = 'mac'

-- Select theme
module.theme = 'xresources'
module.theme_overwrite = {
  gap_single_client  = false,
  -- useless_gap        = dpi(3),
  -- border_width       = dpi(1),
  menu_bg_normal     = '#00000065',
  menu_height        = dpi(24),
  menu_width         = dpi(220),
  top_bar_height     = dpi(24),
  bottom_bar_height  = dpi(40),
  icon_theme         = 'sunjack',
  -- menu_icon_theme    = 'Numix Circle',
  titlebar_font      = 'Iosevka Light 9',
  titlebar_bg_focus  = '#14b87950',
  titlebar_fg_focus  = '#000000',
  bg_focus           = '#14b87950',
  fg_focus           = '#000000',
  -- tasklist_font      = 'Iosevka Regular 8',
  -- tasklist_fg_normal = '#ffffff',
  -- tasklist_fg_focus  = '#000000',
  font               = 'Iosevka Medium 9',
  tabbar_style       = 'xresources',
  -- tabbar_fg_focus    = '#ff2500',
  -- tabbar_bg_focus    = '#16A085',
  -- tabbar_font        = 'Iosevka Medium 11',
  -- tabbar_size        = dpi(12),
  titlebar_marked_button_normal = gears.surface.load_from_shape(dpi(15), dpi(30), gears.shape.rectangle, '#000000'),
  titlebar_marked_button_focus = gears.surface.load_from_shape(dpi(15), dpi(30), gears.shape.rectangle, '#FFFFFF'),
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
