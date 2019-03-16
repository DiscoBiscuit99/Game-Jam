local ecs = require("lib.ecs")

local components = require("components")
local systems	 = require("systems")

local camera = require("lib.camera")

local Input = require("lib.input")

local WIDTH  = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

local bump = require("lib.bump")

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

	love.graphics.setDefaultFilter("nearest", "nearest")

	world = ecs.world.new()

	bumpWorld = bump.newWorld(32)

	box = world:create_entity()

	box:add_component(components.position(100, 100))
	box:add_component(components.sprite("assets/sprites/test_sprite.png"))
	box:add_component(components.collision_box(32, 32))

	player = world:create_entity()

	player:add_component(ecs.component.new("player"))
	player:add_component(components.position(100, 120))
  
	player:add_component(components.animation(32, 32, 1, "assets/sprites/front_walk.png", "assets/sprites/walk_right.png"))
	player:add_component(components.collision_box(32, 32))

	world:add_system(systems.renderer())
	world:add_system(systems.movement(bumpWorld))
	world:add_system(systems.collision(bumpWorld))
end

function love.update(dt)
	world:update(dt)

	key_bindings()
end

function love.draw()
	world:draw()
end

