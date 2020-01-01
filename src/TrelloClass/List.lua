--[[
    Name: List.lua
    From roblox-trello v2

    Description: Constructor for Trello lists.

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
local commons = require(script.Parent.Parent.Commons)

local fetchTable = {
    fields = {"id", "name", "closed", "pos"}
}
local indexDictionary = {
    RemoteId = "id",
    Name = "name",
    Archived = "closed",
    Position = "pos"
}

local TrelloListMeta = commons.generateMeta("TrelloList")

-- Local function prototype to make a board based on a body dump
local makeList

local TrelloList = {}

--[[**
    Creates a new list that is then attached to the given board.

    @param [t:String] name The name of the list.
    @param [t:Variant<int,"first","last">] position Where the list will be located. Pass "first" to put it on the start of the board, and "last" to put it on it's end.
    @param [t:TrelloBoard] board The board where the list will be placed.

    @returns [t:TrelloList] A new, empty list that can be used to store cards.
**--]]
function TrelloList.new(name, position, board)
    if not board or getmetatable(board) ~= "TrelloBoard" then
        error("[TrelloList.new]: Invalid board!", 0)
    elseif not name or name == "" or name:len() > 16384 then
        error("[TrelloList.new]: Invalid name! Make sure that the name is a non-empty string with less than 16384 characters.", 0)
    end

    local commitURL = board.Client:MakeURL("/lists", {
        name = name,
        pos = position,
        idBoard = board.RemoteId
    })

    local listDump = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.POST, "{}", true)
    local list = makeList(listDump.Body)

    board._pkg.appendList(list)

    return list
end

makeList = function(board, data)
    if not data then
        return nil
    end

    local tracking = {}

    local trelloList = {
        Client = board.Client,
        Board = board,
        Loaded = true
    }

    for i, _ in pairs(indexDictionary) do
        local val = commons.getValue(data, i, indexDictionary)
        trelloList[i] = val
        tracking[i] = val
    end

    --[[**
        Fetches the metadata from Trello and updates the list's metadata. (Doesn't apply to cards)

        @param [t:Boolean] hard Whether to overwrite changes that you made, but did not push. (Defaults to false, which will do a soft pull)

        @returns [t:Void]
    **--]]
    function trelloList:Pull(hard)
        local commitURL = self.Client:MakeURL("/lists/"..self.RemoteId, fetchTable)

        local updatedData = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.GET, nil, true).Body

        if not updatedData then
            -- FIXME: HANDLE THIS
            trelloList = nil
            self = nil
            error("[Trello/List.Pull]: List has been deleted!")
        end

        for i, _ in pairs(indexDictionary) do
            local val = commons.getValue(updatedData, i, indexDictionary)
            if hard or self[i] == tracking[i] then
                self[i] = val
            end
            tracking[i] = val
        end
    end

    --[[**
        Pushes the list's changes to Trello.

        @param [t:Boolean] force Whether to push all changes to the list even though nothing has been changed.

        @returns [t:Void]
    **--]]
    function trelloList:Push(force)
        local count = 0
        local commit = {}

        for i, v in pairs (tracking) do
            if v ~= self[i] or force then
                commit[i] = self[i]
                count = count + 1
            end
        end

        if count == 0 then
            warn("[Trello/List.Push]: Nothing to change. Skipping.")
        end

        local commitURL = board.Client:MakeURL("/lists/"..self.RemoteId, {
            name = commit.Name,
            closed = commit.Archived,
            pos = commit.Position
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
    function trelloList:Delete()
        local commitURL = board.Client:MakeURL("/lists/" .. self.RemoteId)

        HTTP.RequestInsist(commitURL, HTTP.HttpMethod.DELETE, nil, true)

        trelloList = nil
    end

    return setmetatable(trelloList, TrelloListMeta)
end

return {Public = TrelloList, Make = makeList}