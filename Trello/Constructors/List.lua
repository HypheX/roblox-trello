local List = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.Parent.auth)

List.new = function(data, BoardCon, ListCon, CardCon)
	if data.id == nil then
		local purl = "https://api.trello.com/1/lists/"..auth
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
		
		function NewList:SetProperty(property, value)
			HTTP:RequestAsync({Url = "https://api.trello.com/1/lists/"..self:GetId().."/"..property..auth.."&value="..value, Method = "PUT"})
		end
		
		function NewList:SetName(newName)
			self:SetProperty("name", newName)
		end
		
		function NewList:SetBoard(newIdBoard)
			NewList:SetProperty("idBoard", newIdBoard:GetId())
		end
	
	end
	return NewList
end

return List
