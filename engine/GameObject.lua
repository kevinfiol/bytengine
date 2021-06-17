local Object = require 'lib.classic'
local Timer = require 'lib.timer'
local utils = require 'engine.utils'

local GameObject = Object:extend()

function GameObject:new(area, x, y, opts)
    local opts = opts or {}
    if opts then
        for k, v in pairs(opts) do self[k] = v end
    end

    self.area = area
    self.x, self.y = x, y
    self.id = utils.UUID()
    self.dead = false
    self.timer = Timer()
end

function GameObject:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.collider then self.x, self.y = self.collider.body:getPosition() end
end

function GameObject:draw()
    -- no op
end

function GameObject:destroy()
    self.dead = true
    self.area = nil

    self.timer:destroy()
    self.timer = nil

    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function GameObject:kill()
    self.dead = true
end

return GameObject