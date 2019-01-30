local Trello = {}

Trello.new = function(className, data)
	local Constructors = script.Parent.Constructors
	local ConList = {
		Board = require(Constructors.Board),
		List = require(Constructors.List),
		Card = require(Constructors.Card)
	}
	if ConList[className] then
		return ConList[className].new(data, ConList["Board"], ConList["List"], ConList["Card"] )
	else
		error(tostring(className).." is not a valid class.")
	end
end
return Trello