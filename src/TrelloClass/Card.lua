--[[
    Name: Card.lua
    From roblox-trello v2

    Description: Constructor for Trello cards.


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
    fields = {"id", "closed", "desc", "name", "pos", "idLabels", "idList"}
}
local indexDictionary = {
    RemoteId = "id",
    Name = "name",
    Description = "desc",
    Archived = "closed",
    Position = "pos"
}

local TrelloCardMeta = commons.generateMeta("TrelloCard")

local makeCard

local TrelloCard = {}

--[[**
    Creates a new card, and appends it to the given list.

    @param [t:String] name The name of the new card.
    @param [t:String] description The description of the card.
    @param [t:Variant<float,"top","bottom">] position Where the card will be placed within the list (defaults to the bottom).
    @param [t:TrelloList] list The list the card will be appended to.

    @returns [t:TrelloCard]
**--]]
function TrelloCard.new(name, description, position, list)
    if not list or getmetatable(list) ~= "TrelloList" then
        error("[TrelloCard.new]: Invalid board!", 0)
    elseif not name or name == "" or name:len() > 16384 then
        error("[TrelloCard.new]: Invalid name! Make sure that the name is a non-empty string with less than 16384 characters.", 0)
    elseif not description or name == "" or description:len() > 16384 then
        error("[TrelloCard.new]: Invalid description! Make sure that the card's description is a non-empty string with less than 16384 characters.", 0)
    end

    local commitURL = list.Client:MakeURL("/cards", {
        name = name,
        desc = description,
        pos = position,
        idList = list.RemoteId
    })

    local cardDump = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.POST, "{}", true)
    local card = makeCard(cardDump.Body)

    list._pkg.appendCard(card)

    return list
end

makeCard = function(list, data)
    if not data then
        return nil
    end

    local tracking = {}

    local trelloList = {
        Client = list.Client,
        List = list,
        Board = list.Board,
        Loaded = true
    }

    for i, _ in pairs(indexDictionary) do
        local val = commons.getValue(data, i, indexDictionary)
        trelloList[i] = val
        tracking[i] = val
    end

    --[[**
        Fetches the metadata from Trello and updates the board's metadata. (Doesn't apply to lists, cards, etc.)

        @param [t:Boolean] hard Whether to overwrite changes that you made, but did not push. (Defaults to false, which will do a soft pull)

        @returns [t:Void]
    **--]]
    function trelloList:Pull(hard)
        local commitURL = self.Client:MakeURL("/cards/"..self.RemoteId, fetchTable)

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
        Pushes the label's changes to Trello.

        @param [t:Boolean] force Whether to push all changes to the board even though nothing has been changed.

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

        local commitURL = list.Client:MakeURL("/cards/"..self.RemoteId, {
            name = commit.Name,
            desc = commit.Description,
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
        local commitURL = list.Client:MakeURL("/lists/" .. self.RemoteId)

        HTTP.RequestInsist(commitURL, HTTP.HttpMethod.DELETE, nil, true)

        trelloList = nil
    end

    return setmetatable(trelloList, TrelloCardMeta)
end

return {Public = TrelloCard, Make = makeCard}
