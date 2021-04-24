local layout = require 'awful.widget.keyboardlayout'
local menubar = require 'menubar'

local kbdlayout = {
    globally_preferred = 'us',
    menubar_preferred = 'us',
}

local function get_idx_by_name(name)
    if not name then
        return 
    end
    for i, v in ipairs(layout.get_groups_from_group_names(awesome.xkb_get_group_names())) do
        if v.file == name then
            return i - 1
        end
    end
end

require 'awful.client' .property.persist('last_layout', 'number')

local oneshot_lock = false

local function on_layout_change()
    -- so that it does not override the last_layout
    -- when we set it, e.g. from menubar.show
    if oneshot_lock then
        oneshot_lock = false
        return
    end
    local c = client.focus
    if c then
        local idx = awesome.xkb_get_layout_group()
        c.last_layout = idx
    end
end

local function on_focus_changed(c)
    local idx = c.last_layout or get_idx_by_name(c.preferred_layout or kbdlayout.globally_preferred)
    if idx and awesome.xkb_get_layout_group() ~= idx then
        awesome.xkb_set_layout_group(idx)
    end
end

awesome.connect_signal('xkb::map_changed', on_layout_change)
awesome.connect_signal('xkb::group_changed', on_layout_change)
client.connect_signal('focus', on_focus_changed)

-- menubar has no signals or anything, so just plain old monkeypatching

local menubar_show = menubar.show
local menubar_hide = menubar.hide

function menubar.show(...)
    menubar_show(...)
    local idx = get_idx_by_name(kbdlayout.menubar_preferred)
    if idx then
        oneshot_lock = true
        awesome.xkb_set_layout_group(idx)
    end
end

function menubar.hide(...)
    menubar_hide(...)
    local c = client.focus
    if c then
        on_focus_changed(c)
    end
end

return kbdlayout
