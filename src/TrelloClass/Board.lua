--[[
    Name: Board.lua
    From roblox-trello v2

    Description: Constructor for Trello Boards.


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
    customFields = false,
    card_pluginData = false,
    fields = {"name","desc","descData","closed","prefs"},
}
local indexDictionary = {
    RemoteId = "id",
    Name = "name",
    Description = "desc",
    Closed = "closed",
    Public = {"prefs", "permissionLevel", mut = function(p) return p == "public" end}
}

-- TrelloBoard Metatable
local TrelloBoardMeta = commons.generateMeta("TrelloBoard")

-- Local function prototype to make a board based on a body dump
local makeBoard

local TrelloBoard = {}

--[[**
    Creates a new board, that is then also created on Trello.

    @param [t:String] name The Board's name. Must to be a non-empty string with a maximum of 16384 characters.
    @param [t:Boolean] public Whether the board is public or not. If this field is not provided, the board will be private.
    @param [t:TrelloClient] client The client the board will be assigned to.

    @returns [t:TrelloBoard] A new TrelloBoard that was freshly created.
**--]]
function TrelloBoard.new(name, public, client)
    if not client or getmetatable(client) ~= "TrelloClient" then
        error("[TrelloBoard.new]: Invalid client!", 0)
    elseif not name or name == "" or name:len() > 16384 then
        error("[TrelloBoard.new]: Invalid name! Make sure that the name is a non-empty string with less than 16384 characters.", 0)
    end

    local commitURL = client:MakeURL("/boards", {
        name = name,
        defaultLabels = false,
        defaultLists = false,
        prefs_selfJoin = false,
        prefs_cardCovers = false,
        prefs_permissionLevel = public and "public" or "private"
    })

    local result = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.POST, "{}", true)

    return makeBoard(client, result.Body)
end

--[[**
    Fetches a board from Trello (includes lists, cards, etc.).

    @param [t:String] name The Board's ID.
    @param [t:TrelloClient] client The client the board will be assigned to.

    @returns [t:Variant<TrelloBoard,nil>] The Trello Board fetched. Returns nil if the board doesn't exist.
**--]]
function TrelloBoard.fromRemote(remoteId, client)
    if not client or getmetatable(client) ~= "TrelloClient" then
        error("[TrelloBoard.fromRemote]: Invalid client!", 0)
    elseif not remoteId or remoteId == "" then
        error("[TrelloBoard.fromRemote]: Invalid board id!", 0)
    end

    local commitURL = client:MakeURL("/boards/" .. remoteId, fetchTable)

    local result = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.GET, nil, true)

    return makeBoard(client, result.Body)
end

--[[**
    Fetches all the boards the provided client has edit access to.

    @param [t:TrelloClient] client The client where to fetch the boards from.

    @returns [t:Array<TrelloBoard>] An array containing zero or more trello boards.
**--]]
function TrelloBoard.fetchAllFrom(client)
    if not client or getmetatable(client) ~= "TrelloClient" then
        error("[TrelloBoard.fromRemote]: Invalid client!", 0)
    end

    local commitURL = client:MakeURL("/members/me/boards", {
        filter = "open",
        fields = {"name","desc","descData","closed","prefs"},
        lists = "all",
        memberships = "none",
        organization = false,
        organization_fields = ""
    })

    local result = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.GET, nil, true)
    local body = result.Body
    local boards = {}

    for _, b in pairs(body) do
        table.insert(boards, makeBoard(client, b))
    end

    return boards
end

-- Prototype implementation
makeBoard = function(client, data)
    if not data then
        return nil
    end

    local tracking = {}
    local labels = {}

    local trelloBoard = {
        Loaded = false,
        Client = client
    }

    for i, _ in pairs(indexDictionary) do
        local val = commons.getValue(data, i, indexDictionary)
        trelloBoard[i] = val
        tracking[i] = val
    end

    -- PACKAGE-PRIVATE METHODS - DO NOT USE
    trelloBoard._pkg = {}

    function trelloBoard._pkg.appendLabel(label)
        if labels[label.RemoteId] then
            error("Duplicate label id!")
        end

        labels[label.RemoteId] = label
    end

    --[[**
        Fetches the metadata from Trello and updates the board's metadata. (Doesn't apply to lists, cards, etc.)

        @param [t:Boolean] hard Whether to overwrite changes that you did not push. (Defaults to false, which will do a soft pull)

        @returns [t:Void]
    **--]]
    function trelloBoard:Pull(hard)
        local commitURL = client:MakeURL("/boards/"..self.RemoteId, fetchTable)

        local updatedData = HTTP.RequestInsist(commitURL, HTTP.HttpMethod.GET, nil, true).Body

        if not updatedData then
            -- FIXME: HANDLE THIS
            trelloBoard = nil
            self = nil
            error("OOF! Card has been deleted!")
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
        Pushes all metadata changes to Trello. (Doesn't apply to lists, cards, etc.)

        @param [t:Boolean] force Whether to push all changes to the board even though nothing has been changed.

        @returns [t:Void]
    **--]]
    function trelloBoard:Push(force)
        local count = 0
        local commit = {}

        for i, v in pairs (tracking) do
            if v ~= self[i] or force then
                commit[i] = self[i]
                count = count + 1
            end
        end

        if count == 0 then
            warn("[Trello/Board.Commit]: Nothing to change. Skipping")
        end

        local commitURL = client:MakeURL("/boards/"..self.RemoteId, {
            name = commit.Name,
            desc = commit.Description,
            closed = commit.Closed,
            prefs = (commit.Public ~= nil) and {
                permissionLevel = commit.Public and "public" or "private"
            } or nil
        })

        HTTP.RequestInsist(commitURL, HTTP.HttpMethod.PUT, "{}", true)

        for i, v in pairs(commit) do
            tracking[i] = v
        end
    end

    --[[**
        Deletes this board from Trello. All garbage collection is up to the developer to perform.

        @returns [t:Void]
    **--]]
    function trelloBoard:Delete()
        local commitURL = client:MakeURL("/boards/" .. self.RemoteId)

        HTTP.RequestInsist(commitURL, HTTP.HttpMethod.DELETE, nil, true)

        trelloBoard = nil
    end

    return setmetatable(trelloBoard, TrelloBoardMeta)
end

return {Public = TrelloBoard, Make = makeBoard}
