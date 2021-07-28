local Object = require 'lib.classic'
local utils = require 'engine.utils'

local Collider = Object:extend()

function Collider:new(world, collider_type, ...)
    local MAIN_KEY = 'main'
    self.id = utils.UUID()
    self.world = world
    self.type = collider_type
    self.object = nil

    self.shapes = {}
    self.fixtures = {}

    self.collision_class_name = nil
    self.collision_events = {}

    local args = {...}
    local shape, fixture, settings

    if self.type == 'Circle' then
        local x, y, radius = args[1], args[2], args[3]
        settings = args[4]

        local body_type = (settings and settings.body_type) or 'dynamic'
        if settings then
            body_type = settings.body_type or 'dynamic'
            if settings.body_xOffset then
                self.body_xOffset = settings.body_xOffset
                x = x + settings.body_xOffset
            end

            if settings.body_yOffset then
                self.body_yOffset = settings.body_yOffset
                y = y + settings.body_yOffset
            end
        end

        self.body = love.physics.newBody(self.world.box2d_world, x, y, body_type)
        shape = love.physics.newCircleShape(radius)
        self.shapes[MAIN_KEY] = shape
    elseif self.type == 'Rectangle' then
        local x, y, width, height = args[1], args[2], args[3], args[4]
        settings = args[5]

        local body_type = (settings and settings.body_type) or 'dynamic'
        if settings then
            body_type = settings.body_type or 'dynamic'
            if settings.body_xOffset then
                self.body_xOffset = settings.body_xOffset
                x = x + settings.body_xOffset
            end

            if settings.body_yOffset then
                self.body_yOffset = settings.body_yOffset
                y = y + settings.body_yOffset
            end
        end

        self.body = love.physics.newBody(self.world.box2d_world, x, y, body_type)
        shape = love.physics.newRectangleShape(width, height)
        self.shapes[MAIN_KEY] = shape
    end

    local fixture_density = (settings and settings.fixture_density) or 1
    fixture = love.physics.newFixture(self.body, shape, fixture_density)

    if settings.restitution then
        fixture:setRestitution(settings.restitution) -- can cause items to bounce
    end

    self.fixtures[MAIN_KEY] = fixture

    -- use setUserData to easily reference this collider at a later time
    fixture:setUserData(self)
end

function Collider:destroy()
    for name, _ in pairs(self.fixtures) do
        self.shapes[name] = nil
        self.fixtures[name]:setUserData(nil) -- remove reference if exists
        self.fixtures[name] = nil
    end

    self.body:destroy() -- internal love method
    self.body = nil

    self.world = nil
    self.object = nil

    self.shapes = {}
    self.fixtures = {}
end

function Collider:setObject(object)
    self.object = object
end

function Collider:getPosition()
    local x, y = self.body:getPosition()

    if self.body_xOffset then x = x - self.body_xOffset end
    if self.body_yOffset then y = y - self.body_yOffset end

    return x, y
end

function Collider:setCollisionClass(collision_class_name)
    if not self.world.collision_classes[collision_class_name] then
        error('Collision class ' .. collision_class_name .. ' does not exist.')
        return
    end

    self.collision_class_name = collision_class_name
end

function Collider:on(collision_type, other_collision_class_name, event)
    self.collision_events[collision_type] = function(collider_a, collider_b, ...)
        local otherCollider = nil
        if self == collider_a then
            otherCollider = collider_b
        else
            otherCollider = collider_a
        end

        if otherCollider.collision_class_name == other_collision_class_name then
            return event
        end

        return nil
    end
end

function Collider:isTouching(other)
    -- `other` may be a collision class name or specifically another body
    if type(other) == 'string' then
        -- user passed collision class string
        -- if the collision class doesn't exist, then return false
        if not self.world.collision_classes[other] then
            return false
        end

        -- we must query world for colliders with the given collision class name
        for _, collider in ipairs(self.world.colliders) do
            if collider.collision_class_name == other then
                if self.body:isTouching(collider.body) then
                    return true
                end
            end
        end

        return false
    elseif type(other) == 'table' then
        -- user passed a body
        return self.body:isTouching(other)
    end
end

return Collider