local Label = {}
local HTTP = game:GetService("HttpService")
local auth = require(script.Parent.Parent.auth)

Label.new = function(data, BoardCon, ListCon, CardCon)
	local Ret
	if data.id == nil then
		local purl = "https://api.trello.com/1/labels/"..auth
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
	
	local NewLabel = {}
	if Ret then
		local FixedId = Ret.id
		function NewLabel:GetId()
			return FixedId
		end
		
		function NewLabel:GetData(suff)
			local JSON
			pcall(function()
				JSON = HTTP:GetAsync("https://api.trello.com/1/cards/"..self:GetId()..(suff or "")..auth)
			end)
			return (HTTP:JSONDecode(JSON))
		end
		
		function NewLabel:GetName()
			return (self:GetData().name)
		end
		
		function NewLabel:GetColor()
			return (self:GetData().color)
		end
		
		function NewLabel:GetBoard()
			return (self:GetData().idBoard)
		end
		
		function NewLabel:SetProperty(property, value)
			HTTP:RequestAsync({Url = "https://api.trello.com/1/labels/"..self:GetId().."/"..property..auth.."&value="..value, Method = "PUT"})
		end
		
		function NewLabel:SetName(newName)
			if newName then
				if type(newName) == "string" then
					self:SetProperty("name", newName)
				else
					error("Label:SetName() - string expected, got "..type(newName), 0)
				end
				
			else
				error("Label:SetName() - Argument #1 is missing or nil.", 0)
			end
		end
		
		function NewLabel:SetColor(newColor)
			local colors = {
				yellow = true,
				purple = true,
				blue = true,
				red = true,
				green = true,
				orange = true,
				black = true,
				sky = true,
				pink = true, 
				lime = true,
				null = true
				}
			if newColor then
				if colors.newColor then
					self:SetProperty("color", newColor)
				else
					error("Label:SetColor() - given color is not a valid color.",0)
				end
			else
				error("Label:SetColor() - Argument #1 is missing or nil.", 0)
			end
			
		end
		
		function NewLabel:Delete()
			pcall(function()
				HTTP:RequestAsync({Url = "https://api.trello.com/1/labels/"..self:GetId()..auth, Method = "DELETE"})
			end)
		end
		
		function NewLabel:ClassName()
			return "Label"
		end
	end
end
return Label
