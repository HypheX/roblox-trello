--[[
    Name: Board.lua
    From roblox-trello v2

    Description: Constructor for Trello Boards.
    This script is in public domain.
--]]

local HTTP = require(script.Parent.Parent.TrelloHttp)

-- TrelloBoard Metatable
local META_TrelloBoard = {
    __tostring = "TrelloBoard",

    __metatable = "TrelloBoard",

    -- Hopefully this will not throw false positives. Functions that will eventually work with this should be aware.
    __index = function(_, index)
        error("[TrelloBoard]: Attempted to index non-existant property "..tostring(index)..".", 0)
    end,

    -- This can be bypassed using rawset, but at that point it's not on us
    __newindex = function(_, index, _)
        error("[TrelloBoard]: Attempted to set non-existant property "..tostring(index)..".", 0)
    end
}

local TrelloBoard = {}

--[[**
    Creates a new TrelloBoard, that represents a Trello board, that is then also created on Trello.

    @param [t:TrelloEntity] entity The entity the board will be assigned to.
    @param [t:String] name The Board's name. Must to be a non-empty string with a maximum of 16384 characters.
    @param [t:Boolean] public Whether the board is public or not. If this field is not provided, the board will be private.

    @returns [t:TrelloEntity] A new TrelloEntity, representing your account.
**--]]
function TrelloBoard.new(entity, name, public)
    if not entity or getmetatable(entity) ~= "TrelloEntity" then
        error("[TrelloBoard.new]: Invalid entity!", 0)
    elseif not name or name == "" or name:len() > 16384 then
        error("[TrelloBoard.new]: Invalid name! Make sure that the name is a non-empty string with less than 16384 characters.", 0)
    end

    local commitURL = entity:MakeURL("/boards", {
        name = name,
        defaultLabels = false,
        defaultLists = false,
        prefs_selfJoin = false,
        prefs_cardCovers = false,
        prefs_permissionLevel = public and "public" or "private"
    })

    local result = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.POST, "{}", true)

    local TrelloBoard = {}

    TrelloBoard.Name = name
    TrelloBoard.LocalId = ""
    TrelloBoard.RemoteId = result.Body.id
    TrelloBoard._Git = {}

    return setmetatable(TrelloBoard, META_TrelloBoard)
end

--[[**
    Fetches a TrelloBoard from Trello.

    @param [t:TrelloEntity] entity The entity the board will be assigned to.
    @param [t:String] name The Board's ID.

    @returns [t:TrelloBoard] The Trello Board fetched.
**--]]
function TrelloBoard.fromRemote(entity, remoteId)

end

return TrelloBoard