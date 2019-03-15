local ecs = require("lib.ecs")

local components = require("components")
local systems	 = require("systems")

local Input = require("lib.input")

local WIDTH  = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

-- General keybindings
local input = Input()
function key_bindings()
	input:bind('escape', 'quit')
	input:bind('q', 'quit')

	if input:pressed('quit') then
		love.event.quit()
	end
end

-- Main functions
function love.load()
	world = ecs.world.new()

	player = world:create_entity()

	player:add_component(ecs.component.new("player"))
	player:add_component(components.position(WIDTH/2, HEIGHT/2))
	player:add_component(components.sprite("assets/sprites/test_sprite.png"))

	world:add_system(systems.renderer())
	world:add_system(systems.movement())
end

function love.update(dt)
	world:update(dt)

	key_bindings()
end

function love.draw()
	world:draw()
end

