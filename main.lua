local ecs = require("lib.ecs")

function love.load()
	world = ecs.world.new()
end

function love.update(dt)
	world:update(dt)
end

function love.draw()
	world:draw()
end

