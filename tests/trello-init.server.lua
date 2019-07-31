--[[
    Name: trello-init.server.lua
    From roblox-trello v2

    Description: Makes some testing on the 
    This script is in public domain.
--]]

local Trello = require(game.ServerScriptService.Trello)
local TrelloHttp = require(game.ServerScriptService.Trello.TrelloHttp)
local TrelloClass = require(game.ServerScriptService.Trello.TrelloClass)

wait(2)

-----------------------------------------------------
-- MAKE SURE TO CHANGE THESE WITH YOUR OWN VALUES! --
-----------------------------------------------------
local id = Trello.new("API KEY", "API TOKEN")

print("Authentication string: " .. id.Auth)

function mkurlsend(p, q)
    local url = id:MakeURL(p, q)
    warn("\nURL: " .. url)
    
    local x = TrelloHttp.RequestInsist(url, TrelloHttp.HttpMethod.GET)
    print(TrelloHttp.JSONEncode(x.Body))
end

mkurlsend("/members/me")
mkurlsend("members/me", {boardsInvited = "all"})
mkurlsend("batch", {urls = {"/members/me", "/members/me?boardsInvited=all"}})

local board1 = TrelloClass.Board.new(id, "My Awesome Private Board")
print(board1.RemoteId)
local board2 = TrelloClass.Board.new(id, "My Awesome Explicit Private Board", false)
print(board2.RemoteId)
local board3 = TrelloClass.Board.new(id, "My Awesome Public Board", true)
print(board3.RemoteId)

local myAwesomeBoard = TrelloClass.Board.fromRemote(id, board1.RemoteId)
for i, v in pairs(myAwesomeBoard) do
    print(i .. ": ".. tostring(v))
end

warn("TEST END.")