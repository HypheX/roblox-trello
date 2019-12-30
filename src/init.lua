--[[
    Name: init.lua
    From roblox-trello v2

    Description: Fetches and groups class constructors for Trello.


    Copyright (c) 2019 Luis, David Duque

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
--]]

local CLASS = {}
local VERSION = "2.0.0-dev.12"

for _, c in pairs(script.TrelloClass:GetChildren()) do
    CLASS[c.Name] = require(c).Public
end

warn("Using Roblox-Trello, VERSION " .. VERSION .. ".")

return CLASS
