local GameObject = require 'engine.GameObject'
local Ground = GameObject:extend()

function Ground:new(area, x, y, opts)
    Ground.super.new(self, area, x, y, opts)

    self.width = opts.width or 100
    self.height = opts.height or 1

    self.collider = self.area.world:newRectangleCollider(
        self.x,
        self.y,
        self.width,
        self.height,
        {
            body_xOffset = (self.width / 2),
            body_type = 'static'
        }
    )

    self.collider:setCollisionClass('Ground')
    self.collider:setObject(self)
end

function Ground:update(dt)
    Ground.super.update(self, dt)
end

function Ground:draw()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Ground
