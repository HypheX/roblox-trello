--[[
    Name: http.lua
    From roblox-trello v2

    Description: Wrapper for gracious handling of HTTP(S) requests


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

local http = game:GetService("HttpService")
local MAX_TRIES = 30

--[[**
    Enum HttpMethod:
    GET, PUT, POST, HEAD, DELETE

    @returns [t:HttpMethod]
**--]]
local HttpMethod
= {
    GET = "GET",
    PUT = "PUT",
    POST = "POST",
    HEAD = "HEAD",
    DELETE = "DELETE",
}

--[[**
    Makes a request to the given URL.

    @param [t:String] url The URL where the request should be sent to.
    @param [t:HttpMethod] method The method to apply.
    @param [t:Variant<String,nil>] body The payload, in JSON format, to send to the URL.

    @returns [t:Dictionary] A dictionary containing the result of the request: Whether it succeeded, latency and response headers/body.
**--]]
local function Request(url, method, body)
    local requestBody = {
        Url = url,
        Method = method,
        Body = body,
    }

    if (method == HttpMethod.GET or method == HttpMethod.HEAD or method == HttpMethod.DELETE) and body then
        -- While the DELETE method actually accepts a body, it is ignored, so it's best to leave it empty.
        requestBody.Body = nil
        warn("[Trello/HTTP.Request]: Tried to send a payload with an invalid method (" .. method .. ").")
    elseif not body and (method == HttpMethod.PUT or method == HttpMethod.POST) then
        error("[Trello/HTTP.Request]: The method used (" .. method .. ") requires a payload body, but it doesn't exist!", 0)
    end

    if requestBody.Body then
        requestBody.Headers = {
            ["content-type"] = "application/json"
        }
    end

    -- If all pre-checks have passed, proceed and send the request
    local t = tick()
    local LuaSuccess, Result = pcall(function()
        return http:RequestAsync(requestBody)
    end)

    if LuaSuccess then
        Result.Latency = tick() - t
        Result.LuaSuccess = LuaSuccess
        if Result.Headers["content-type"]:sub(1, 16) == "application/json" then
            Result.Body = http:JSONDecode(Result.Body)
        else
            warn("[Trello/HTTP.Request]: Response is not in format 'application/json' (got '" .. Result.Headers["content-type"] .. "'). Not parsing.")
        end

        return Result
    else
        return {LuaSuccess = LuaSuccess, SystemResponse = Result}
    end
end

--[[**
    Makes a request to the given URL, retrying within intervals of 0.5 seconds in case of error not caused by the user. Gives up after 30 unsuccessful tries.

    @param [t:String] url The URL where the request should be sent to.
    @param [t:HttpMethod] method The method to apply.
    @param [t:Variant<String,nil>] body The payload, in JSON format, to send to the URL.
    @param [t:Boolean] pedantic_assert Whether an error should be thrown (instead of a warning) if a client error occurs (Errors 404 and 429 won't trigger this).

    @returns [t:Dictionary] A dictionary containing the result of the request: Whether it succeeded, latency and response headers/body.
**--]]
local function RequestInsist(url, method, body, pedantic_assert)
    local tries = 0

    while tries <= MAX_TRIES do
        local content = Request(url, method, body)
        tries = tries + 1

        if not content.LuaSuccess then
            warn("[Trello/HTTP.RequestInsist]: Request failed at Lua level: '" .. content.SystemResponse .. "'")
        elseif content.StatusCode == 429 then
            warn("[Trello/HTTP.RequestInsist]: (429 Too Many Requests) API is throttling requests. Halting for " .. tostring(content.Headers["Retry-After"]) .. " seconds.")
            wait(content.Headers["Retry-After"])
        elseif content.StatusCode == 404 then
            warn("[Trello/HTTP.RequestInsist]: (404 Not Found) Nothing was found. Returning empty (nil) body.")
            content.Body = nil
            return content
        elseif content.StatusCode >= 500 then
            warn("[Trello/HTTP.RequestInsist]: API threw server error (" .. tostring(content.StatusCode) .. ": "..content.StatusMessage..").")
        else
            if pedantic_assert and content.StatusCode >= 400 then
                error("[Trello/HTTP.RequestInsist]: Bad request from client (" .. tostring(content.StatusCode) .. ": "..content.StatusMessage..").", 0)
            elseif content.StatusCode >= 400 then
                warn("[Trello/HTTP.RequestInsist]: Bad request from client (" .. tostring(content.StatusCode) .. ": "..content.StatusMessage..").")
            end
            return content
        end

        wait(0.5)
    end

    error("[Trello/HTTP.RequestInsist]: PANIC - Maximum amount of tries for request exceeded. Giving up.", 3)
end

return 
    {
        HttpMethod = HttpMethod, Request = Request, RequestInsist = RequestInsist,
        JSONEncode = function(x) return http:JSONEncode(x) end, JSONDecode = function(x) return http:JSONDecode(x) end
    }