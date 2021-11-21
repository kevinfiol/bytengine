local Object = require 'lib.classic'
local lume = require 'lib.lume'

local Area = Object:extend()

function Area:new(room, opts)
    self.room = room
    self.game_objects = {}
    self.world = nil
    self.opts = opts or {}
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
    -- draw all game objects in area
    for _, game_object in ipairs(self.game_objects) do
        game_object:draw()
    end

    -- Debug code from: https://love2d.org/wiki/Tutorial:PhysicsDrawing#Final_code
    -- if self.world and self.opts.debug then
    --     for _, body in pairs(self.world:getBodies()) do
    --         for _, fixture in pairs(body:getFixtures()) do
    --             local shape = fixture:getShape()

    --             love.graphics.setColor(1, 0, 0)
    --             if shape:typeOf('CircleShape') then
    --                 local cx, cy = body:getWorldPoints(shape:getPoint())
    --                 love.graphics.circle("line", cx, cy, shape:getRadius())
    --             elseif shape:typeOf('PolygonShape') then
    --                 love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
    --             else
    --                 love.graphics.line(body:getWorldPoints(shape:getPoints()))
    --             end
    --         end
    --     end
    -- end
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

function Area:addGameObjects(game_objects)
    for _, game_object in pairs(game_objects) do
        table.insert(self.game_objects, game_object)
    end
end

function Area:getGameObjects(fn)
    return lume.filter(self.game_objects, fn)
end

function Area:queryCircleArea(x, y, radius, object_types)
    local out = {}
    for _, game_object in ipairs(self.game_objects) do
        if lume.find(object_types, game_object.class) ~= nil then
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
        if lume.find(object_types, game_object.class) ~= nil then
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

function Area:distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

return Area