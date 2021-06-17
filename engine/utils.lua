global_type_table = nil

local UUID = function()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

local type_name = function(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
            global_type_table[v] = k
        end
    global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

local count_all = function(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
        seen[t] = true
        for k,v in pairs(t) do
            if type(v) == "table" then
            count_table(v)
            elseif type(v) == "userdata" then
            f(v)
            end
    end
    end
    count_table(_G)
end

local type_count = function()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

local collectGarbage = function()
    print("Before collection: " .. collectgarbage("count")/1024)
    collectgarbage()
    print("After collection: " .. collectgarbage("count")/1024)
    print("Object count: ")
    local counts = type_count()
    for k, v in pairs(counts) do print(k, v) end
    print("-------------------------------------")
end

local pushRotate = function(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

local pushRotateScale = function(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.scale(sx or 1, sy or sx or 1)
    love.graphics.translate(-x, -y)
end

local random = function(min, max)
    return love.math.random() * (max - min) + min
end

return {
    random = random,
    UUID = UUID,
    collectGarbage = collectGarbage,
    pushRotate = pushRotate,
    pushRotateScale = pushRotateScale
}