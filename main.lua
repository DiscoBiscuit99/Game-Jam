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
	love.graphics.setDefaultFilter("nearest", "nearest")

	ent_world = ecs.world.new()
	bump_world = bump.newWorld(32)

	box = ent_world:create_entity()

	box:add_component(components.enemy(100))
	box:add_component(components.position(100, 100))
	box:add_component(components.sprite("assets/sprites/test_sprite.png"))
	box:add_component(components.collision_box(0, 0, 32, 32))

	map = ent_world:create_entity()

	map:add_component(components.map("assets/maps/map.lua"))
	map:add_component(components.position(0,0))

	ent_world:add_system(systems.renderer(ent_world, bump_world))
	ent_world:add_system(systems.movement(bump_world))
	ent_world:add_system(systems.collision(bump_world))
	ent_world:add_system(systems.attack(bump_world))
	ent_world:add_system(systems.enemy(bump_world))
end

function love.update(dt)
	ent_world:update(dt)
end

function love.update(dt)
	ent_world:update(dt)
	love.window.setTitle("FPS: " .. love.timer.getFPS())

	key_bindings()
end

function love.draw()
	ent_world:draw()
end

