--[[
    Name: TrelloClass.lua
    From roblox-trello v2

    Description: Fetches class constructors for Trello.
    This script is in public domain.
--]]

local CLASS = {}

for _, c in pairs(script:GetChildren()) do
    CLASS[c.Name] = require(c)
end

return CLASS