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

board1:Delete()
board2:Delete()
board3:Delete()

-- Was also board1, should return a 404.
myAwesomeBoard:Delete()

warn("TEST END.")