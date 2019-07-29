--[[
    Name: trello-init.server.lua
    From roblox-trello v2

    Description: Makes some testing on the 
    This script is in public domain.
--]]

local Trello = require(game.ServerScriptService.Trello)
local TrelloHttp = require(game.ServerScriptService.Trello.TrelloHttp)

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