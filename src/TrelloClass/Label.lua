--[[
    Name: Label.lua
    From roblox-trello v2

    Description: Constructor for Trello labels.


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

local HTTP = require(script.Parent.Parent.TrelloHttp)

local TrelloLabelMeta = {
    __tostring = "TrelloLabel",

    __metatable = "TrelloLabel",

    -- Hopefully this will not throw false positives. Functions that will eventually work with this should be aware.
    __index = function(_, index)
        error("[TrelloLabel]: Attempted to index non-existant property "..tostring(index)..".", 0)
    end,

    -- This can be bypassed using rawset, but at that point it's not on us
    __newindex = function(_, index, _)
        error("[TrelloLabel]: Attempted to set non-existant property "..tostring(index)..".", 0)
    end
}

-- Local function prototype to make a board based on a body dump
local makeLabel

local TrelloLabel = {}

--[[**
    Creates a new label and assigns it to the board

    @param [t:String] name The label's name. Must to be a string with a maximum of 16384 characters.
    @param [t:LabelColor] color The label's color. 
    @param [t:TrelloClient] board The board where the label will be attached to.

    @returns [t:TrelloBoard] A new TrelloBoard that was freshly created.
**--]]
function TrelloLabel.new(name, color, board)
    local commitURL = board.Client:MakeURL("/labels", {
        name = name,
        color = color,
        idBoard = board.RemoteId
    })

    local labelDump = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.POST, "{}", true)
    local label = makeLabel(labelDump.Body)

    board._pkg.appendLabel(label)

    return label
end

makeLabel = function(board, data)
    if not data then
        return nil
    end

    local tracking = {
        Name = data.name,
        Color = data.color
    }

    local trelloLabel = {
        RemoteId = data.id,
        Board = board,
        Loaded = true,
        Name = data.name,
        Color = data.color
    }

    --[[**
        Pushes the label's changes to Trello.

        @param [t:Boolean] force Whether to push all changes to the board even though nothing has been changed.

        @returns [t:Void]
    **--]]
    function trelloLabel:Update(force)
        local count = 0
        local commit = {}

        for i, v in pairs (tracking) do
            if v ~= self[i] or force then
                commit[i] = self[i]
                count = count + 1
            end
        end

        if count == 0 then
            warn("[Trello/Label.Update]: Nothing to change. Skipping.")
        end

        local commitURL = board.Client:MakeURL("/labels/"..self.RemoteId, {
            name = commit.Name,
            color = commit.Color
        })

        HTTP.RequestInsist(commitURL, HTTP.HttpMethod.PUT, "{}", true)

        for i, v in pairs(commit) do
            tracking[i] = v
        end
    end

    --[[**
        Deletes the label from Trello. All garbage collection is up to the developer to perform.

        @returns [t:Void]
    **--]]
    function trelloLabel:Delete()
        local commitURL = board.Client:MakeURL("/labels/" .. self.RemoteId)

        HTTP.RequestInsist(commitURL, HTTP.HttpMethod.DELETE, nil, true)

        trelloLabel = nil
    end

    return setmetatable(trelloLabel, TrelloLabelMeta)
end

return {Public = TrelloLabel, Make = makeLabel}