--[[
    Name: trello-init.server.lua
    From roblox-trello v2

    Description: Makes some testing on the 
    This script is in public domain.
--]]

local Trello = require(game.ServerScriptService.Trello)
local TrelloClass = require(game.ServerScriptService.Trello.TrelloClass)

wait(2)

-----------------------------------------------------
-- MAKE SURE TO CHANGE THESE WITH YOUR OWN VALUES! --
-----------------------------------------------------
local id = Trello.new("API KEY", "API TOKEN")

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

boardIWillEdit = TrelloClass.Board.new(id, "This")
print("Waiting 3 seconds until starting to edit...")
wait(3)
print("Editing.")
print(boardIWillEdit.RemoteId)

boardIWillEdit.Name = "Maybe this name is cooler!"
boardIWillEdit.Description = "Hey, what about we oof?"
boardIWillEdit.Public = true
print("Changing name and description, making it public.")
boardIWillEdit:Commit()

wait(10)
boardIWillEdit.Public = false
print("Making it private again.")
boardIWillEdit:Commit()

wait(3)
boardIWillEdit.Closed = true
print("Closing the board.")
boardIWillEdit:Commit()

wait(3)
boardIWillEdit.Closed = false
print("Reopening the board.")
boardIWillEdit:Commit()
boardIWillEdit:Commit()
print("Force committing this time.")
boardIWillEdit:Commit(true)

wait(3)
print("Deleting the board.")
boardIWillEdit:Delete()

-- Was also board1, should return a 404.
myAwesomeBoard:Delete()

warn("TEST END.")