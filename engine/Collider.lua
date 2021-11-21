local Object = require 'lib.classic'
local lume = require 'lib.lume'
local collisions = require 'collisions'

local Collider = Object:extend()

-- https://love2d.org/forums/viewtopic.php?f=4&t=75441
function Collider:new(world, collider_type, opts)
    --[[
        opts = {
            collision_class,
            x, y,
            body_type,
            body_offset?,
            fixed_rotation?
            radius?,
            width?,
            height?,
            fixture_density?,
            restitution?
        }
    --]]

    self.collision_class = opts.collision_class or 'Default'
    self.world = world
    self.type = collider_type
    self.body = nil
    self.shape = nil
    self.fixture = nil
    self.width = nil
    self.height = nil
    self.radius = nil
    self.body_offset = { x = nil, y = nil }

    local x, y = opts.x, opts.y
    local body_type = opts.body_type or 'dynamic'

    -- default fixed_rotation to true
    local fixed_rotation
    if opts.fixed_rotation == nil then
        fixed_rotation = true
    else
        fixed_rotation = opts.fixed_rotation
    end

    -- get body offsets if present
    if opts.body_offset then
        self.body_offset.x = opts.body_offset.x or nil
        self.body_offset.y = opts.body_offset.y or nil
        if self.body_offset.x then x = x + self.body_offset.x end
        if self.body_offset.y then y = y + self.body_offset.y end
    end

    -- create body
    self.body = love.physics.newBody(self.world, x, y, body_type)
    self.body:setFixedRotation(fixed_rotation)

    -- create shape
    if self.type == 'Circle' then
        self.radius = opts.radius
        self.shape = love.physics.newCircleShape(self.radius)
    elseif self.type == 'Rectangle' then
        self.width, self.height = opts.width, opts.height
        self.shape = love.physics.newRectangleShape(self.width, self.height)
    end

    -- create fixture
    local fixture_density = opts.fixture_density or 1
    self.fixture = love.physics.newFixture(self.body, self.shape, fixture_density)

    if opts.restitution then
        self.fixture:setRestitution(opts.restitution)
    end

    -- set collider as user data on fixture
    -- this is useful because we are only given the fixture on collision callbacks
    self.fixture:setUserData(self)

    -- update fixture categories and mask
    self:setCollisionClass(self.collision_class)
end

function Collider:destroy()
    self.body:destroy()

    self.world = nil
    self.type = nil
    self.body = nil
    self.shape = nil
    self.fixture = nil
    self.body_offset = nil
end

-- this translates the body position to regular x, y coordinates that love2d uses
-- so while pixel may be at 0, 0, the body might be at -4, -4
function Collider:getPosition()
    local x, y = self.body:getPosition()

    if self.body_offset.x then x = x - self.body_offset.x end
    if self.body_offset.y then y = y - self.body_offset.y end

    return x, y
end

-- likewise, given x,y coordinates love2d understands
-- lets update the body so it is where we'd expect it to be
function Collider:setPosition(x, y)
    local new_x, new_y = x, y

    if self.body_offset.x then new_x = x - self.body_offset.x end
    if self.body_offset.y then new_y = y - self.body_offset.y end

    self.body:setPosition(new_x, new_y)
end

function Collider:setCollisionClass(collision_class)
    self.collision_class = collision_class

    -- assign collision categories + masks
    local collision_props = collisions[self.collision_class]
    local categories = collision_props[1]
    local masks = collision_props[2]
    self.fixture:setCategory(unpack(categories))
    self.fixture:setMask(unpack(masks))
end

function Collider:checkCollision(fixture_a, fixture_b)
    local colliders = { is_colliding = false, other_collider = nil }

    if fixture_a == self.fixture or fixture_b == self.fixture then
        colliders.is_colliding = true
        local other_fixture = fixture_a ~= self.fixture and fixture_a or fixture_b
        colliders.other_collider = other_fixture:getUserData()
    end

    return colliders
end

return Collider