--[[
    Name: Commons.lua
    From roblox-trello v2

    Description: Common functions to be shared across constructors

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

local COMMONS = {}

function COMMONS.getValue(data, index, indexDictionary)
    local i = indexDictionary[index]

    if not i then
        return nil
    elseif type(index) == "string" then
        return data[index]
    else
        local x = data
        for y = 1, #i do
            x = x[i[y]]
        end
        return i.mut(x) or x
    end
end

function COMMONS.generateMeta(className)
    return {
        __tostring = className,
    
        __metatable = className,
    
        -- Hopefully this will not throw false positives. Functions that will eventually work with this should be aware.
        __index = function(_, index)
            error("["..className.."]: Attempted to index non-existant property "..tostring(index)..".", 0)
        end,
    
        -- This can be bypassed using rawset, but at that point it's not on us
        __newindex = function(_, index, _)
            error("["..className.."]: Attempted to set non-existant property "..tostring(index)..".", 0)
        end
    }
end

return COMMONS