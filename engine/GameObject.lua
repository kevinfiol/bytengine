local Object = require 'lib.classic'
local Timer = require 'lib.timer'
local lume = require 'lib.lume'

local GameObject = Object:extend()

function GameObject:new(class, area, x, y, opts)
    local opts = opts or {}
    if opts then
        for k, v in pairs(opts) do self[k] = v end
    end

    self.class = class
    self.area = area
    self.x, self.y = x, y
    self.dead = false
    self.timer = Timer()
    self.moving_props = {}
end

function GameObject:update(dt)
    if self.moving_props.active then
        local distance = math.abs(lume.distance(self.x, self.y, self.moving_props.x, self.moving_props.y))

        if distance <= self.moving_props.stop_distance then
            self.moving_props.active = false
            if self.moving_props.onStop then
                self.moving_props.onStop()
            end
        end
    end

    if self.timer then self.timer:update(dt) end
    if self.collider then self.x, self.y = self.collider:getPosition() end
end

function GameObject:draw()
    -- no op
end

function GameObject:destroy()
    self.dead = true
    self.area = nil

    self.timer:destroy()
    self.timer = nil

    self.moving_props = nil

    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function GameObject:kill()
    self.dead = true
end

-- clean this up
function GameObject:moveTo(x, y, speed, stop_distance, onStop)
    local initial_distance = lume.distance(x, y, self.x, self.x)
    local angle = math.atan2(y - self.y, x - self.x)
    self.collider:setCollisionClass('Ghost')

    self.moving_props = {
        active = true,
        x = x,
        y = y,
        direction = { x = math.cos(angle), y = math.sin(angle) },
        speed = speed,
        stop_distance = stop_distance,
        onStop = onStop
    }

    if self.collider then
        local x_vel = self.moving_props.direction.x * speed
        local y_vel = self.moving_props.direction.y * speed
        self.collider.body:setType('kinematic')
        self.collider.body:setLinearVelocity(x_vel, y_vel)
    end
end

return GameObject