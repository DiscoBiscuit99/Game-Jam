local ecs = require("lib.ecs")
local sti = require("lib.sti")

local components = require("components")
local systems	 = require("systems")

local camera = require("lib.camera")

local bump = require("lib.bump")

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
	bump_world = bump.newWorld(32)
	
	map = sti("assets/maps/mapboy.lua", { "bump" })
	map:bump_init(bump_world)

	box = world:create_entity()

	box:add_component(components.position(100, 100))
	box:add_component(components.sprite("assets/sprites/test_sprite.png"))
	box:add_component(components.collision_box(32, 32))

	player = world:create_entity()

	player:add_component(ecs.component.new("player"))
	player:add_component(components.position(WIDTH/2, HEIGHT/2))
  
	player:add_component(components.sprite("assets/sprites/player_sprite.png"))
	player:add_component(components.collision_box(32, 32))

	world:add_system(systems.renderer())
	world:add_system(systems.movement(bump_world))
	world:add_system(systems.collision(bump_world))
end

function love.update(dt)
	world:update(dt)
	map:update(dt)

	key_bindings()
end

function love.draw()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	world:draw()
	map:draw()
end

