local vars = require 'vars'
local utils = require 'engine.utils'
local RoomManager = require 'engine.RoomManager'
local Camera = require 'lib.camera'
local baton = require 'lib.baton'

local input
local rooms
camera = Camera() -- global camera

local resize = function(s)
    love.window.setMode(s * vars.gw, s * vars.gh)
    vars.sx, vars.sy = s, s
end

function love.load()
    rooms = RoomManager()

    -- scale window
    resize(2)

    -- adjust filter mode and line style for pixelated look
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

    -- first room
    rooms:goToRoom('Stage')
end

function love.update(dt)
    if rooms.current_room then rooms.current_room:update(dt) end
    camera:update(dt)
end

function love.draw()
    if rooms.current_room then rooms.current_room:draw() end
end