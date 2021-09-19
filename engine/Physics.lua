local Box2dWorld = require 'engine.Physics.Box2dWorld'

local worlds = {}

-- to-do:
-- figure out collision filtering: https://love2d.org/wiki/World:setContactFilter , https://love2d.org/wiki/Fixture:setFilterData
-- https://love2d.org/forums/viewtopic.php?p=155547#p155547
-- so that you can say one collisionClass ignores another collisionClass

local createBox2dWorld = function(xGravity, yGravity, bodiesCanSleep)
    bodiesCanSleep = bodiesCanSleep or true
    local world = Box2dWorld(xGravity, yGravity, bodiesCanSleep)
    table.insert(worlds, world)
    return world
end

local Physics = {
    worlds = worlds,
    createBox2dWorld = createBox2dWorld
}

return Physics