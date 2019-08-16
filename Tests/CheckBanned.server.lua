local Trello = require(script.Parent.Trello.Main)
local MainBoard = Trello:GetBoardByName("Banned Noobs")
local Banned = MainBoard:GetListByName("Banned")

function checkBanned(Player)
	local isBanned = Banned:GetCardByName(tostring(Player.UserId))
	print(isBanned)
	if isBanned then
		Player:Kick("You have been banned from this game.\n\nModerator Note: "..isBanned:GetDesc())
	end
end

-- Check for players yet to come
game:GetService('Players').PlayerAdded:Connect(checkBanned)

-- Check for players that already arrived
for _,p in pairs(game:GetService('Players'):GetPlayers()) do
	checkBanned(p)
end

print("All set!")