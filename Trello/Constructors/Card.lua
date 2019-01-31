local Card = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.Parent.auth)

Card.new = function(data, BoardCon, ListCon, CardCon)
	local Ret
	if data.id == nil then
		local purl = "https://api.trello.com/1/cards/"..auth
		if data then
			for i,v in pairs (data) do
				purl = purl.."&"..i.."="..v
			end
		end
	
		pcall(function()
			Ret = HTTP:JSONDecode(HTTP:PostAsync(purl,"{}"))
		end)
	else
		Ret = data
	end
	
	local NewCard = {}
	if Ret then
		
		local FixedId = Ret.id	
		function NewCard:GetId()
			return FixedId
		end
		
		function NewCard:GetData()
			local JSON
			pcall(function()
				JSON = HTTP:GetAsync("https://api.trello.com/1/cards/"..self:GetId()..auth)
			end)
			return (HTTP:JSONDecode(JSON))
		end
		
		function NewCard:GetName()
			return (self:GetData().name)
		end
		
		function NewCard:GetBoard()
			return (BoardCon.new({id = self:GetData().idBoard}))
		end
		
		function NewCard:GetList()
			return (ListCon.new({id = self:GetData().idList}))
		end
		
		function NewCard:isSubscribed()
			return (self:GetData().subscribed)
		end
		
		function NewCard:isArchived()
			return (self:GetData().closed)
		end
		
		function NewCard:GetPosition()
			return (self:GetData().pos)
		end
		
		function NewCard:SetProperty(property, value)
			pcall(function()
				HTTP:RequestAsync({Url = "https://api.trello.com/1/cards/"..self:GetId().."/"..property..auth.."&value="..value, Method = "PUT"})
			end)
		end
		
		function NewCard:SetName(newName)
			if newName then
				if type(newName) == "string" then
					self:SetProperty("name", newName)
				else
					error("Card:SetName() - string expected, got "..type(newName), 0)
				end
			else
				error("Card:SetName() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewCard:Move(newIdList)
			if newIdList then
				if newIdList:ClassName() == "List" then
					self:SetProperty("idList", newIdList:GetId())
				else
					error("Card:Move() - argument is not a List object.", 0)
				end
			else
				error("Card:Move() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewCard:SetClosed(newVal)
			if newVal then
				if type(newVal) == "boolean" then
					self:SetProperty("closed", newVal)
				else
					error("Card:SetClosed() - boolean expected, got "..type(newVal), 0)
				end
			else
				error("Card:SetClosed() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewCard:Comment(text)
			if text then
				if type(text) == "string" then
					pcall(function()
						HTTP:PostAsync("https://api.trello.com/1/cards/"..self:GetId().."/actions/comments"..auth.."&text="..text, "{}")
					end)
				else
					error("Card:Comment() - string expected, got "..type(text), 0)
				end
			else
				error("Card:Comment() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewCard:Delete()
			pcall(function()
				HTTP:RequestAsync({Url = "https://api.trello.com/1/cards/"..self:GetId()..auth, Method = "DELETE"})
			end)
		end
		
		function NewCard:ClassName()
			return "Card"
		end
		
	
	end
	return NewCard
end

return Card
