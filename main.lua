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

local function defer_contest()
    --{"allowed_activities":[{"id":2,"name":"Listening"},{"id":1,"name":"Reading"}],"allowed_languages":null,"contest_end":"2025-11-14","contest_start":"2025-11-01","created_at":"2025-10-21T01:00:00.028055Z","deleted":false,"id":"8200d2e4-fb2a-46a0-8c25-982cb36b3ce3","official":true,"owner_user_display_name":"antonve","owner_user_id":"55e54f43-a363-4db8-a0c8-b0318cca479a","private":false,"registration_end":"2025-11-07","title":"2025 Round 6","updated_at":"2025-10-21T01:00:00.028055Z"}
    local contestInfo = TadokuConnect:get_latest_contest()
    local res = {}
    table.insert(res, {
        text = contestInfo.title .. "\n" .. "by " .. contestInfo.owner_user_display_name,
    })
    table.insert(
        res,
        -- contest_end":"2025-11-14","contest_start":"2025-11-01
        {
            text = contestInfo.contest_start .. " -> " .. contestInfo.contest_end,
        }
    )
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
            sub_item_table_func = function()
                return defer_contest()
            end,
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
