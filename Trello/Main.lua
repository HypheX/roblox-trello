local VERSION = "1.3.4"

local Trello = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.auth)

local Constructors = script.Parent.Constructors
local ConList = {
		Board = require(Constructors.Board),
		List = require(Constructors.List),
		Card = require(Constructors.Card)
}

print("Trello API - Version "..VERSION)

-- Check if HttpService is even enabled. Since we can't index HttpEnabled (?), we need to send a dummy request.
local t = tick()
local enabled, dummyResult = pcall(function() return HTTP:RequestAsync({Url = "https://api.trello.com/1/boards/Lh7195Cs"..auth, Method = "GET"}) end)
local ping = tick() - t

if not enabled then
	error("Aborting - Trello API needs to have HttpService Enabled! Check your Game Settings or run the following in your command line:\ngame:GetService('HttpService').HttpEnabled = true", 0)
else
	print("Trello API - Measured Latency: "..tostring(math.ceil(ping*1000)).."ms.")
	for _,l in pairs ({5, 3, 2, 1, 0.5}) do
		if ping >= l then
			warn("Trello API - API Latency is higher than "..tostring(l*1000).."ms!")
			break
		end
	end

	if dummyResult.StatusCode == 200 then
		print("Trello API - All OK.")
	elseif dummyResult.StatusCode >= 500 then
		warn("Trello API - Bad Server Response - "..tostring(dummyResult.StatusCode)..". Service might experience issues.")
	elseif dummyResult.StatusCode >= 400 then
		warn("Trello API - Bad Client Request - "..tostring(dummyResult.StatusCode)..". Service might experience issues.")
	end
end

script.Parent.auth:Destroy()

Trello.new = function(className, name, parent)
	if ConList[className] then
		if className == "Board" then
			return (ConList.Board.new({name = name}, ConList["Board"], ConList["List"], ConList["Card"]))
		elseif className == "List" then
			if parent then
				if parent:ClassName() == "Board" then
					return (ConList.List.new({name = name, idBoard = parent:GetId()}, ConList["Board"], ConList["List"], ConList["Card"]))
				else
					error("List - argument #3 is not a board.", 0)
				end
			else
				error("List - Board not specified!", 0)
			end
		else
			if parent then
				if parent:ClassName() == "List" then
					return (ConList.Card.new({name = name, idList = parent:GetId()}, ConList["Board"], ConList["List"], ConList["Card"]))
				else	
					error("Card - argument #3 is not a card.", 0)
				end
			else
				error("Card - List not specified!", 0)
			end
		end
	else
		error(className.." is not a valid class.", 0)
	end
end

		
function Trello:GetBoardByName(name)
	if name then
		local Ret,fId
		pcall(function()
			Ret = HTTP:JSONDecode(HTTP:GetAsync("https://api.trello.com/1/members/me/boards"..auth))
		end)
		for _,v in pairs (Ret) do
			if v.name == name then
				fId = v.id
				break
			end
		end
		if fId then
			return (ConList.Board.new({id = fId}, ConList["Board"], ConList["List"], ConList["Card"], ConList["Label"]))
		else
			return nil
		end
	else
		error("No name specified!" , 0)
	end
end

function Trello:GetBoardById(id)
	if id then
		local Ret
		pcall(function()
			Ret = HTTP:JSONDecode(HTTP:GetAsync("https://api.trello.com/1/boards/"..tostring(id)..auth))
		end)
		
		if Ret then
			return (ConList.Board.new({id = tostring(id)}, ConList["Board"], ConList["List"], ConList["Card"], ConList["Label"]))
		end
	end
end

return Trello

