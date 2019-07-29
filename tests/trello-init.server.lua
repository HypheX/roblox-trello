local Trello = require(game.ServerScriptService.Trello)
wait(2)
print(Trello.new("API KEY", "API TOKEN").Auth)