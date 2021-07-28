local Object = require 'lib.classic'
local Collider = require 'engine.Physics.Collider'
local lume = require 'lib.lume'
local utils = require 'engine.utils'

-- Forward Declare Local Functions
local collide, collisionOnEnter, collisionOnExit, collisionPre, collisionPost

local World = Object:extend()

function World:new(xGravity, yGravity, bodiesCanSleep)
    self.box2d_world = love.physics.newWorld(xGravity, yGravity, bodiesCanSleep)
    self.box2d_world:setCallbacks(collisionOnEnter, collisionOnExit, collisionPre, collisionPost)

    self.id = utils.UUID()
    self.colliders = {}
    self.collisions = {}
    self.collision_classes = {}
    self.world_collision_events = {}
end

function World:update(dt)
    self.box2d_world:update(dt)

    for i, event in pairs(self.world_collision_events) do
        event(dt)
        self.world_collision_events[i] = nil
    end
end

function World:draw(alpha)
    -- get the current color values to reapply?
    local r, g, b, a = love.graphics.getColor()

    -- alpha value is optional
    alpha = alpha or 255

    -- Colliders debug
    -- Joint Debug
    -- Query Debug

    love.graphics.setColor(r, g, b, a)
end

function World:destroy()
    local bodies = self.box2d_world:getBodies()
    for _, body in ipairs(bodies) do
        local firstFixture = body:getFixtures()[1] -- get first fixture of body
        local collider = firstFixture:getUserData() -- see in `Collider:new` where this gets set
        collider:destroy()
    end

    self.colliders = {}
    self.collisions = {}
    self.collision_classes = {}
    self.world_collision_events = {}
    self.box2d_world:destroy() -- internal love method
    self.box2d_world = nil
end

function World:newCircleCollider(x, y, radius, settings)
    local collider = Collider(self, 'Circle', x, y, radius, settings)
    table.insert(self.colliders, collider)
    return collider
end

function World:newRectangleCollider(x, y, width, height, settings)
    local collider = Collider(self, 'Rectangle', x, y, width, height, settings)
    table.insert(self.colliders, collider)
    return collider
end

function World:addCollisionClass(class_name)
    if self.collision_classes[class_name] then
        error('Collision class ' .. class_name .. ' already exists.')
        return
    end

    self.collision_classes[class_name] = 1
end

-- Local Functions

collide = function(fixture_a, fixture_b, collision_type, ...)
    local collider_a, collider_b = fixture_a:getUserData(), fixture_b:getUserData()

    local function runCollision(collider_a, collider_b, ...)
        local eventFactory = collider_a.collision_events[collision_type] or nil
        if eventFactory then
            local event = eventFactory(collider_a, collider_b, ...)
            if type(event) == 'function' then
                local world = collider_a.world -- grab world from one of the colliders; doesnt matter which
                world.world_collision_events[#world.world_collision_events + 1] = event
            end
        end
    end

    if collider_a ~= nil and collider_b ~= nil then
        runCollision(collider_a, collider_b, ...)
        runCollision(collider_b, collider_a, ...)
    end
end

collisionOnEnter = function(fixture_a, fixture_b, contact)
    collide(fixture_a, fixture_b, 'enter', contact)
end

collisionOnExit = function(fixture_a, fixture_b, contact)
    collide(fixture_a, fixture_b, 'exit', contact)
end

collisionPre = function(fixture_a, fixture_b, contact)
    collide(fixture_a, fixture_b, 'pre', contact)
end

collisionPost = function(fixture_a, fixture_b, contact, normalImpulse, tangentImpulse)
    collide(fixture_a, fixture_b, 'post', contact, normalImpulse, tangentImpulse)
end

return World