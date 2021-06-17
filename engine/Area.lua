local Object = require 'lib.classic'
local M = require 'lib.moses'
local Physics = require 'engine.Physics'

local Area = Object:extend()
local OBJ_DIR = 'obj.'

function Area:new(room)
    self.room = room
    self.game_objects = {}
    self.world = nil
end

function Area:update(dt)
    -- We update the physics world before updating all the 
    -- game objects because we want to use up to date information
    -- for our game objects, and that will happen only after the
    -- physics simulation is done for this frame.
    if self.world then self.world:update(dt) end

    -- One important thing here is that the loop is happening backwards,
    -- from the end of the list to the start. This is because if
    -- you remove elements from a Lua table while moving forward in
    -- it it will end up skipping some elements, as this discussion shows.
    -- http://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)

        if game_object.dead then
            game_object:destroy()
            table.remove(self.game_objects, i)
        end
    end
end

function Area:draw()
    if self.world then self.world:draw() end
    for _, game_object in ipairs(self.game_objects) do
        game_object:draw()
    end
end

function Area:destroy()
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:destroy()
        table.remove(self.game_objects, i)
    end

    self.game_objects = {}
    self.room = nil

    if self.world then
        self.world:destroy()
        self.world = nil
    end
end

function Area:addGameObject(game_object_type, x, y, opts)
    local object_opts = opts or {}
    local game_object = require(OBJ_DIR .. game_object_type)(self, x or 0, y or 0, object_opts)
    game_object.class = game_object_type
    table.insert(self.game_objects, game_object)
    return game_object
end

function Area:getGameObjects(fn)
    return M.select(self.game_objects, fn)
end

function Area:queryCircleArea(x, y, radius, object_types)
    local out = {}
    for _, game_object in ipairs(self.game_objects) do
        if M.any(object_types, game_object.class) then
            local d = self:distance(x, y, game_object.x, game_object.y)
            if d <= radius then
                table.insert(out, game_object)
            end
        end
    end
    return out
end

function Area:getClosestObject(x, y, radius, object_types)
    local lowest = { d = nil, object = nil }
    for _, game_object in ipairs(self.game_objects) do
        if M.any(object_types, game_object.class) then
            local d = self:distance(x, y, game_object.x, game_object.y)
            if not lowest.d then
                lowest.d = d
                lowest.object = game_object
            elseif d < lowest.d then
                lowest.d = d
                lowest.object = game_object
            end
        end
    end
    return lowest.object
end

function Area:addPhysicsWorld()
    self.world = Physics.newWorld(0, 0, true)
end

function Area:distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

return Area