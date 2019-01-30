local Board = {}

local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.Parent.auth)

Board.new = function(data, BoardCon, ListCon, CardCon)
	
	if data.id == nil then
		local purl = "https://api.trello.com/1/boards/"..auth
		if data then
			for i,v in pairs (data) do
				purl = purl.."&"..i.."="..v
			end
			if data["defaultLists"] == nil then
				purl = purl.."&defaultLists=false"
			end
		end
		local Ret
		pcall(function()
			Ret = HTTP:JSONDecode(HTTP:PostAsync(purl,"{}"))
		end)
	else
		Ret = data
	end
	
	local NewBoard = {}
	if Ret then
		local FixedId = Ret.id
		function NewBoard:GetId()
			return FixedId
		end
		
		function NewBoard:GetData(suff)
			local JSON
			pcall(function()
				JSON = HTTP:GetAsync("https://api.trello.com/1/boards/"..self:GetId()..(suff or "")..auth)
			end)
			return (HTTP:JSONDecode(JSON))
		end
		
		function NewBoard:GetUrl()
			return (self:GetData().url)
		end	
		
		function NewBoard:GetShortUrl()
			return (self:GetData().shortUrl)
		end
		
		function NewBoard:GetName()
			return (self:GetData().name)
		end
		
		function NewBoard:GetDesc()
			return (self:GetData().desc)
		end
		
		function NewBoard:isClosed()
			return self:GetData().closed
		end
		
		function NewBoard:GetLists()
			local listData, obTab = self:GetData("/lists"),{}
			for _,v in pairs (listData) do
				table.insert(obTab, ListCon.new({id = v.id}, BoardCon, ListCon, CardCon))
			end
			return obTab
		end
		
		function NewBoard:GetCards()
			local cardData, obTab = self:GetData("/cards"),{}
			for _,v in pairs (cardData) do
				table.insert(obTab, CardCon.new({id = v.id}, BoardCon, ListCon, CardCon))
			end
			return obTab
		end
		
		
		function NewBoard:SetProperty(property, value)
			pcall(function()
				HTTP:RequestAsync({Url = "https://api.trello.com/1/boards/"..self:GetId().."/"..property..auth.."&value="..value, Method = "PUT"})
			end)
		end
		
		function NewBoard:SetName(newName)
			if newName then
				if type(newName) == "string" then
					self:SetProperty("name", newName)
				else
					error("Board:SetName() - string expected, got "..type(newName),0)
				end
			else
				error("Board:SetName() - Argument #1 missing or nil.", 0)
			end
		end
		
		function NewBoard:SetDesc(newDesc)
			if newDesc then
				if type(newDesc) == "string" then 
					self:SetProperty("desc", newDesc)
				else
					error("Board:SetDesc() - string expected, got "..type(newDesc),0)
				end
			else
				error("Board:SetDesc() - Argument #1 missing or nil.", 0)
			end
		end	
		
		function NewBoard:SetClosed(newVal)
			if newVal then
				if type(newVal) == "boolean" then
					self:SetProperty("closed", newVal)
				else
					error("Board:SetClosed() - boolean expected, got "..type(newVal))
				end
			else
				error("Board:SetClosed() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewBoard:Delete()
			pcall(function()
				HTTP:RequestAsync({Url = "https://api.trello.com/1/boards/"..self:GetId()..auth, Method = "DELETE"})
			end)
		end
		
		function NewBoard:ClassName()
			return "Board"
		end
		
	end
	return NewBoard
end

return Board
