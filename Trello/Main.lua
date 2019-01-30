local Trello = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.auth)

local Constructors = script.Parent.Constructors
local ConList = {
		Board = require(Constructors.Board),
		List = require(Constructors.List),
		Card = require(Constructors.Card)
}

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
					return (ConList.Card.new({name = name, idCard = parent:GetId()}, ConList["Board"], ConList["List"], ConList["Card"]))
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
			return (ConList.Board.new({id = fId}))
		else
			return nil
		end
	else
		error("No name specified!" , 0)
	end
end
return Trello
