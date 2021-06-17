local Object = require 'lib.classic'
local utils = require 'engine.utils'

--[[
    Collider Object
--]]
local Collider = Object:extend()

function Collider:new(world, collider_type, ...)
    local MAIN_KEY = 'main'
    self.id = utils.UUID()
    self.world = world
    self.type = collider_type
    self.object = nil

    self.shapes = {}
    self.fixtures = {}

    local args = {...}
    local shape, fixture, settings

    if self.type == 'Circle' then
        local x, y, radius = args[1], args[2], args[3]
        settings = args[4]
        local body_type = (settings and settings.body_type) or 'dynamic'

        self.body = love.physics.newBody(self.world.box2d_world, x, y, body_type)
        shape = love.physics.newCircleShape(radius)
        self.shapes[MAIN_KEY] = shape
    end

    local fixture_density = (settings and settings.fixture_density) or 1
    fixture = love.physics.newFixture(self.body, shape, fixture_density)
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

--[[
    World Object
--]]
local World = Object:extend()

function World:new(xGravity, yGravity, bodiesCanSleep)
    self.box2d_world = love.physics.newWorld(xGravity, yGravity, bodiesCanSleep)
    self.id = utils.UUID()
    self.colliders = {}
end

function World:update(dt)
    self.box2d_world:update(dt)
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
    self.box2d_world:destroy() -- internal love method
    self.box2d_world = nil
end

function World:newCircleCollider(x, y, radius, settings)
    local collider = Collider(self, 'Circle', x, y, radius, settings)
    table.insert(self.colliders, collider)
    return collider
end

local worlds = {}

local newWorld = function(xGravity, yGravity, bodiesCanSleep)
    if bodiesCanSleep == nil then bodiesCanSleep = true end
    local world = World(xGravity, yGravity, bodiesCanSleep)
    table.insert(worlds, world)
    return world
end

local Physics = {
    worlds = worlds,
    newWorld = newWorld
}

return Physics