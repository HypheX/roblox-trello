local API = require(game.ServerScriptService.Trello.Main)
local session = game:GetService("HttpService"):GenerateGUID()

local RaceBoard = API:GetBoardByName("Information Server | AUTOMATED")

function addPlayer (Host,SessionID)
    local SessionList = API.new("List", tostring(SessionID), RaceBoard)
    print(SessionList:GetName())
    SessionList:SetProperty("pos", "bottom")
    local serverCard = API.new("Card","Server",SessionList)
    local clientCard = API.new("Card", Host.UserId, SessionList)
    clientCard:SetDesc(Host.Name)
    return print("Added!!")
end

-- Check for players yet to come
game:GetService('Players').PlayerAdded:Connect(function(p)
    addPlayer(p, session)
end)

-- Check for players that already arrived
for _,p in pairs(game:GetService('Players'):GetPlayers()) do
	addPlayer(p, session)
end