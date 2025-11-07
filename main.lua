local Dispatcher = require("dispatcher") -- luacheck:ignore
local TadokuConnect = require("TadokuConnect")
local KeyValuePage = require("ui/widget/keyvaluepage")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

-- Enforce line-buffering for stdout (this is the default if it points to a tty, but we redirect to a file on most platforms).
io.stdout:setvbuf("line")
-- Enforce a reliable locale for numerical representations
os.setlocale("C", "numeric")

io.write([[ WARN TADOKU [*] Current time: ]], os.date("%x-%X"), "\n")
local Tadoku = WidgetContainer:extend({
    name = "tadoku",
})

function Tadoku:init()
    io.write([[ WARN TADOKU Startup [*] Current time: ]], os.date("%x-%X"), "\n")
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

local function defer_top3()
    local raw_top = TadokuConnect:get_top_x(3)
    local res = {}
    for i = 1, 3 do
        local toInsert = "▒▒ "
        toInsert = toInsert .. i .. " ▒▒ " .. raw_top[i].name .. " ░ " .. raw_top[i].score
        table.insert(res, {
            text = toInsert,
            keep_menu_open = true,
        })
    end
    return res
end

function Tadoku:genericPopup(title, messageTable)
    local kv = KeyValuePage:new({
        title = title,
        kv_pairs = messageTable,
        callback = function()
            print("hello")
        end,
        callback_return = function()
            UIManager:close(self.kv)
        end,
    })
    UIManager:show(kv)
end

function Tadoku:getSubMenuItems()
    local sub_item_table
    sub_item_table = {
        {
            text = _("See Current Contest"),
            keep_menu_open = true,
        },
        {
            text = _("See Top 3"),
            keep_menu_open = true,
            sub_item_table_func = function()
                return defer_top3()
            end,
        },
    }
    return sub_item_table
end

io.write([[ WARN TADOKU we still exist [*] Current time: ]], os.date("%x-%X"), "\n")
return Tadoku
