-- Getting the KEY/TOKEN pair:

-- The KEY field is MANDATORY: You can get yours here: https://trello.com/app-key

-- The TOKEN field is MANDATORY when:
-- -- You're trying to access a private board;
-- -- You're trying to write to a board (private or not).
-- You can leave it as an empty string if you're only READING FROM A PUBLIC BOARD.

-- Get your token here: https://trello.com/1/authorize?expiration=never&scope=read,write&response_type=token&name=Your%20Trello%20Application&key=<YOUR KEY HERE>

local KEY = ""
local TOKEN = ""

return "?key="..KEY.."&token="..TOKEN
