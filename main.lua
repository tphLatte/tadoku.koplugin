local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

if true then
    return { disabled = false }
end

local Tadoku = WidgetContainer:extend({
    name = "tadoku",
})

function Tadoku:init()
    self.ui.menu:registerToMainMenu(self)

    UIManager:show(InfoMessage:new({
        text = _("Hello, Tadokz"),
    }))
end

function Tadoku:addToMainMenu(menu_items)
    menu_items.tadoku = {
        text = _("Tadoku Plugin"),
        sorting_hint = "search_settings",
        sub_item_table_func = function()
            return self:getSubMenuItems()
        end,
    }
end

function Tadoku:getSubMenuItems()
    local sub_item_table
    sub_item_table = {
        {
            text = _("Go to news folder"),
            keep_menu_open = true,
        },
    }
    return sub_item_table
end
