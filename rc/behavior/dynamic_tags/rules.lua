-- [ author ] -*- time-stamp-pattern: "@Changed[\s]?:[\s]+%%$"; -*- ------------
-- @File   : rules.lua
-- @Author : Marcel Arpogaus <marcel dot arpogaus at gmail dot com>
--
-- @Created: 2021-02-03 17:41:25 (Marcel Arpogaus)
-- @Changed: 2021-01-20 08:37:53 (Marcel Arpogaus)
-- [ description ] -------------------------------------------------------------
-- ...
-- [ license ] -----------------------------------------------------------------
-- ...
--------------------------------------------------------------------------------
-- [ required modules ] --------------------------------------------------------
local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')

-- [ local objects ] -----------------------------------------------------------
local module = {}

-- [ module functions ] --------------------------------------------------------
module.init = function(config, client_buttons, client_keys)
    -- workaround for now
    function awful.rules.high_priority_properties.dynamic_tag(c, value, props)
        local tag = awful.tag.find_by_name(c.screen, value.name)
        if not tag then
            awful.rules.high_priority_properties.new_tag(c, value, props)
        end
        awful.rules.high_priority_properties.tag(c, value.name, props)
    end

    local rules = {
        all = {
            rule = {},
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                switchtotag = true,
                keys = client_keys,
                buttons = client_buttons,
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap +
                    awful.placement.no_offscreen
            }
        }
    }
    for tag, def in pairs(config.dynamic_tags) do
        local rule = gears.table.clone(def.rule)
        def.rule = nil
        local new_tag = def
        new_tag.name = tag
        new_tag.volatile = new_tag.volatile or true
        if not rule.properties then rule.properties = {} end
        rule.properties.dynamic_tag = new_tag
        rules[tag] = rule
    end

    return rules
end

-- [ return module ] -----------------------------------------------------------
return module
