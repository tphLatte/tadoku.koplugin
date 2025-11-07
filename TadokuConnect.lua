--local http_request = require("http.request")
--local http_headers = require("http.headers")
--local http_cookie = require("http.cookie")
local socket_http = require("socket.http")
local json = require("rapidjson")
local ssl = require("ssl") -- LuaSec

local TadokuConnect = {}

function TadokuConnect:get_url()
    local host = "tadoku.app"
    local path = "/api/internal/immersion/"
    return "https://" .. host .. path
end

function TadokuConnect:general_get(url)
    local body, code, headers, status = socket_http.request(url)
    return body
end

function TadokuConnect:get_latest_contest()
    local our_uri = self:get_url() .. "contests/latest-official"
    return json.decode(self:general_get(our_uri))
end

function TadokuConnect:get_current_leaderboard()
    local latest_contest = self:get_latest_contest()
    local leaderboard = self:general_get(self:get_url() .. "contests/" .. latest_contest.id .. "/leaderboard")
    return leaderboard
end

function TadokuConnect:get_user_latest_score(userid)
    local latest_contest = json.decode(self.get_latest_contest(self))
    local output_sink = {} -- contains data returned by request

    local l_url = self:get_url() .. "contests/" .. latest_contest.id .. "/profile/" .. userid .. "/" .. "scores"
    local latest = self:general_get(l_url)
    return latest
end

function TadokuConnect:get_cur_top_3()
    local leaderboard = json.decode(self:get_current_leaderboard()).entries
    local top3 = "["
    for i = 1, 3 do
        top3 = top3
            .. string.format(
                "{rank:%d,score:%s,user_id:%s,user_display_name:%s}",
                leaderboard[i].rank,
                leaderboard[i].score,
                leaderboard[i].user_id,
                leaderboard[i].user_display_name
            )
    end
    top3 = top3 .. "]"

    return top3
end

function TadokuConnect:get_top_x(x)
    local leaderboard = json.decode(self:get_current_leaderboard()).entries
    local res = {}
    for i = 1, x do
        local cur = leaderboard[i]
        table.insert(res, {
            rank = cur.rank,
            id = cur.user_id,
            name = cur.user_display_name,
            score = cur.score,
        })
    end
    return res
end

-- function TadokuConnect:startFlow()
--     local url = "https://account.tadoku.app/kratos/self-service/login/api"
--
--     local req = http_request.new_from_uri(url)
--
--     -- Set headers correctly
--     req.headers:upsert(":method", "GET")
--     req.headers:upsert("accept", "application/json")
--     req.headers:upsert("cookie", "foo=bar; baz=qux")
--
--     local headers, stream = assert(req:go())
--     local body = assert(stream:get_body_as_string())
--
--     local status = headers:get(":status")
--     if status ~= "200" then
--         error(string.format("Request failed with status %s\nBody: %s", status, body))
--     end
--
--     return body
-- end

function TadokuConnect:whoami(cookie)
    local url = "https://account.tadoku.app/kratos/sessions/whoami"
    TadokuConnect:general_get(url)
    return url
end
--print(TadokuConnect:get_cur_top_3())
local top3 = (TadokuConnect:get_top_x(3))

print(tostring(top3))
print(TadokuConnect:get_latest_contest())
return TadokuConnect
