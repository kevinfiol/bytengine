local vars = require 'vars'
local Area = require 'engine.Area'
local Object = require 'lib.classic'
local Timer = require 'lib.timer'

local Stage = Object:extend()

function Stage:new()
    self.area = Area(Stage)
    self.main_canvas = love.graphics.newCanvas(vars.gw, vars.gh)
    self.timer = Timer()

    -- create physics world for this room
    self.area:addPhysicsWorld()

    -- add objects
    self.hello = self.area:addGameObject('Hello',
        vars.gw / 2,
        vars.gh /2,
        { size = 32 }
    )
end

function Stage:update(dt)
    if self.area then self.area:update(dt) end
    if self.timer then self.timer:update(dt) end
end

function Stage:draw()
    if self.area then
        love.graphics.setCanvas(self.main_canvas)
        love.graphics.clear()
            camera:attach(0, 0, vars.gw, vars.gh)
            self.area:draw()
            camera:detach()
        love.graphics.setCanvas()

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setBlendMode('alpha', 'premultiplied')
        love.graphics.draw(self.main_canvas, 0, 0, 0, vars.sx, vars.sy)
        love.graphics.setBlendMode('alpha')
    end
end

function Stage:destroy()
    self.timer:destroy()
    self.timer = nil

    self.main_canvas:release()
    self.main_canvas = nil

    self.area:destroy()
    self.area = nil
end

return Stage