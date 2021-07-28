local GameObject = require 'engine.GameObject'
local baton = require 'lib.baton'

local Ball = GameObject:extend()

function Ball:new(area, x, y, opts)
    Ball.super.new(self, area, x, y, opts)

    self.radius = opts.radius or 4

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.radius, {
        restitution = 0 -- let the ball bounce
    })

    self.collider:setCollisionClass('Ball')
    self.collider:setObject(self)

    -- flags
    self.isJumpPressed = false
    self.isJumping = false
    self.jumpTimer = 0

    -- movement
    self.v = 0
    self.gravity = 500
    self.max_v = 1000
    self.rotation = -math.pi / 2
    self.rotation_v = 1.66 * math.pi

    -- controls
    self.input = baton.new({
        controls = {
            left = { 'key:left' },
            right = { 'key:right' },
            jump = { 'key:z' }
        }
    })

    -- register collisions
    -- self.collider:on('enter', 'Ground', function()
    --     print('hello')
    -- end)
end

function Ball:update(dt)
    Ball.super.update(self, dt)

    -- inputs
    self.input:update()

    self:jump(dt)
    self:move(dt)

    -- self.v = math.min(self.v - self.gravity * dt, self.max_v)
    -- self.collider.body:setLinearVelocity(
    --     self.v * math.cos(self.rotation),
    --     self.v * math.sin(self.rotation)
    -- )
end

function Ball:jump(dt)
    self.isJumpPressed = false

    if self.input:down('jump') then
        self.isJumpPressed = true
    end

    if self.isJumping and not self.isJumpPressed then
        self.isJumping = false
    end

    if self.collider:isTouching('Ground') and not self.isJumping then
        self.jumpTimer = 0
    end

    if self.jumpTimer >= 0 and self.isJumpPressed then
        self.isJumping = true
        self.jumpTimer = self.jumpTimer + dt
    else
        self.jumpTimer = -1
    end

    if self.jumpTimer > 0 and self.jumpTimer < 0.25 then
        local xVelocity, _ = self.collider.body:getLinearVelocity()
        self.collider.body:setLinearVelocity(xVelocity, -300)
    end
end

function Ball:move(dt)
    if self.input:down('left') then
        self.collider.body:applyForce(-100, 0)
    end

    if self.input:down('right') then
        self.collider.body:applyForce(100, 0)
    end
end

function Ball:draw()
    love.graphics.circle('line', self.x, self.y, self.radius)
end

return Ball
