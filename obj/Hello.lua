local GameObject = require 'engine.GameObject'
local Hello = GameObject:extend()

function Hello:new(area, x, y, opts)
    Hello.super.new(self, area, x, y, opts)

    self.size = opts.size or 16
    self.font = love.graphics.newFont('assets/fonts/m5x7.ttf', 16)
    self.font:setFilter('nearest', 'nearest')
end

function Hello:update(dt)
    Hello.super.update(self, dt)
end

function Hello:draw()
    local text = 'Hello.'
    local width = self.font:getWidth(text)
    local height = self.font:getHeight(text)

    love.graphics.setFont(self.font)
    love.graphics.print(text, self.x - (width / 2), self.y - (height / 2))
end

return Hello
