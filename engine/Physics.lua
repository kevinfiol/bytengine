local World = require 'engine.Physics.World'

local worlds = {}

local createNewWorld = function(xGravity, yGravity, bodiesCanSleep)
    if bodiesCanSleep == nil then bodiesCanSleep = true end
    local world = World(xGravity, yGravity, bodiesCanSleep)
    table.insert(worlds, world)
    return world
end

local Physics = {
    worlds = worlds,
    createNewWorld = createNewWorld
}

return Physics