local List = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.Parent.auth)

List.new = function(data, BoardCon, ListCon, CardCon)
	local Ret
	if data.id == nil then
		local purl = "https://api.trello.com/1/lists/"..auth
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
	
	local NewList = {}
	if Ret then
		local FixedId = Ret.id
		function NewList:GetId()
			return FixedId
		end
		
		function NewList:GetData(suff)
			local JSON
			pcall(function()
				JSON = HTTP:GetAsync("https://api.trello.com/1/lists/"..self:GetId()..(suff or "")..auth)
			end)
			return (HTTP:JSONDecode(JSON))
		end
		
		function NewList:GetName()
			return (self:GetData().name)
		end
		
		function NewList:GetBoard()
			return (BoardCon.new({id = self:GetData().idBoard}))
		end
		
		function NewList:isSubscribed()
			return (self:GetData().subscribed)
		end
		
		function NewList:isClosed()
			return (self:GetData().closed)
		end
		
		function NewList:GetPosition()
			return (self:GetData().pos)
		end
		
		function NewList:GetCards()
			local cardData, obTab = self:GetData("/cards"),{}
			for _,v in pairs (cardData) do
				table.insert(obTab, CardCon.new({id = v.id}, BoardCon, ListCon, CardCon))
			end
			return obTab
		end
		
		function NewList:GetCardByName(name)
			if name then
				if type(name) == "string" then
					local cards, fcard = self:GetData("/cards"), nil
					for _,v in pairs (cards) do
						if v.name == name then
							fcard = CardCon.new({id = v.id}, BoardCon, ListCon, CardCon)
						end
					end
					return fcard	
				else
					error("List:GetListByName() - string expected, got "..type(name) , 0)
				end
			else
				error("List:GetListByName() - Argument #1 is missing or nil." , 0)
			end
		end
		
		function NewList:SetProperty(property, value)
			HTTP:RequestAsync({Url = "https://api.trello.com/1/lists/"..self:GetId().."/"..property..auth.."&value="..value, Method = "PUT"})
		end
		
		function NewList:SetName(newName)
			if newName then
				if type(newName) == "string" then
					self:SetProperty("name", newName)
				else
					error("List:SetName() - string expected, got "..type(newName), 0)
				end
				
			else
				error("List:SetName() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewList:Move(newIdBoard)
			if newIdBoard then
				if newIdBoard:ClassName() == "Board" then
					NewList:SetProperty("idBoard", newIdBoard:GetId())
				else
					error("List:Move() - argument is not a Board object.", 0)
				end
			else
				error("List:Move() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewList:ClassName()
			return "List"
		end
	
	end
	return NewList
end

return List
