local Card = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.Parent.auth)

Card.new = function(data, BoardCon, ListCon, CardCon)
	
	if data.id == nil then
		local purl = "https://api.trello.com/1/cards/"..auth
		if data then
			for i,v in pairs (data) do
				purl = purl.."&"..i.."="..v
			end
		end
		local Ret
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
			self:SetProperty("name", newName)
		end
		
		function NewCard:Move(newIdList)
			self:SetProperty("idCard", newIdList:GetId())
		end
		
		function NewCard:SetClosed(newVal)
			self:SetProperty("closed", newVal)
		end	
		
	
	end
	return NewCard
end

return Card
