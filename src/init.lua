--[[
    Name: init.lua
    From roblox-trello v2

    Description: Front-Ends for Trello Entity management
    This script is in public domain.
--]]

-- Module Global Version
local VERSION = "2.0.0-dev.1"
local HTTP = require(script.http)

-- TrelloEnity Metatable
local META_TrelloEntity = {
    __tostring = "TrelloEntity",

    -- Hopefully this will not throw false positives. Functions that will eventually work with this should be aware. 
    __index = function(_, index)
        error("[TrelloEntity]: Attempted to index non-existant property "..tostring(index)..".", 0)
    end,

    -- This can be bypassed using rawset, but at that point it's not on us
    __newindex = function(_, index, _)
        error("[TrelloEntity]: Attempted to set non-existant property "..tostring(index)..".", 0)
    end
}

local TrelloEntity = {}

--[[**
    Creates a new TrelloEntity, that represents a Trello account.

    @param [t:String] key Your developer key. Cannot be empty or nil.
    @param [t:Variant<String,nil>] token Your developer token. Optional if you're only reading from a public board.
    @param [t:Boolean] pedantic_assert Whether an error should be thrown (instead of a warning) if key validation fails.

    @returns [t:TrelloEntity] A new TrelloEntity, representing your account.
**--]]
function TrelloEntity.new(key, token, pedantic_assert)
    if not key or key == "" then
        error("[TrelloEntity.new]: You need a key to authenticate yourself!", 0)
    end

    local AUTH_STR = "key="..key.."&token="..(token or "")

	-- Perform authentication validation and assertation
	local dummyRequest = HTTP.Request("https://api.trello.com/1/members/me?"..AUTH_STR, HTTP.HttpMethod.GET)

	if not dummyRequest.LuaSuccess then
		error("[TrelloEntity.new]: Fatal Error has been thrown by HttpService ("..dummyRequest.SystemResponse..").", 0)
	else
        print("[TrelloEntity.new]: Measured Latency: "..tostring(math.ceil(dummyRequest.Latency*1000)).."ms.")
        for _,l in pairs ({5, 3, 2, 1, 0.5}) do
            if dummyRequest.Latency >= l then
                warn("[TrelloEntity.new]: API Latency is higher than "..tostring(l*1000).."ms!")
                break
            end
        end

        if dummyRequest.StatusCode == 200 then
            print("[TrelloEntity.new]: All OK.")
        elseif dummyRequest.StatusCode >= 500 then
            warn("[TrelloEntity.new]: Bad Server Response - "..tostring(dummyRequest.StatusCode)..". Service might be experiencing issues.")
        elseif dummyRequest.StatusCode >= 400 then
            if pedantic_assert then
                error("[TrelloEntity.new]: Bad Client Request - "..tostring(dummyRequest.StatusCode)..". Check your authentication keys!", 0)
            end
			warn("[TrelloEntity.new]: Bad Client Request - "..tostring(dummyRequest.StatusCode)..". Check your authentication keys!")
		end
    end

    -- All tests passed, we can make the TrelloEntity.
    local TrelloEntity = {}
    TrelloEntity.Auth = AUTH_STR
    TrelloEntity.User = dummyRequest.Body.fullName

    print("Successfully authenticated as "..TrelloEntity.User..". Welcome!")
    return setmetatable(TrelloEntity, META_TrelloEntity)
end

warn("Using Roblox-Trello, VERSION "..VERSION..".")
return TrelloEntity