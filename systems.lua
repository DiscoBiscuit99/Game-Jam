local ecs 	 = require("lib.ecs")
local gamera = require("lib.camera")

local Input = require("lib.input")

local components = require("components")

local WIDTH  = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

return {
	renderer = function(ent_world, bump_world)
		local system = ecs.system.new({ "position" })

		local cam = gamera.new(0,0,2000,2000)
		cam:setScale(2)

		local player

		function system:load(entity)
			local input = Input()

			input:bind('d', 'right')
			input:bind('a', 'left')
			input:bind('s', 'down')
			input:bind('w', 'up')
			input:bind('k', 'dash')

			if entity:get("map") then
				map_ent = entity:get("map")
				map_ent.map:bump_init(bump_world)
				
				for _, object in pairs(map_ent.map.layers["spawn"].objects) do
					if object.name == "player_spawn" then
						player = ent_world:create_entity()
						player:add_component(components.player())
						player:add_component(components.position(object.x, object.y))
						player:add_component(components.collision_box(32, 32))
					end
				end
			end
			
			map_ent.map:addCustomLayer("sprite layer", 2)
			
			sprite_layer = map_ent.map.layers["sprite layer"]

			sprite_layer.sprites = {}

			position = entity:get("position")
			if entity:get("player") then
				print("asss")
				sprite_layer.sprites = {
					player = {
						image = love.graphics.newImage("assets/sprites/player_sprite.png"),
						x = position.x,
						y = position.y
					}
				}
			end

			function sprite_layer:update(dt)
				for _, sprite in pairs(self.sprites) do
					if entity:get("player") then
						if input:down('right') then
							sprite.x = sprite.x + 200*dt
						elseif input:down('left') then
							sprite.x = sprite.x - 200*dt
						end

						if input:down('down') then
							sprite.y = sprite.y + 200*dt
						elseif input:down('up') then
							sprite.y = sprite.y - 200*dt
						end
					end
				end
			end

			function sprite_layer:draw()
				for _, sprite in pairs(self.sprites) do
					love.graphics.draw(sprite.image, sprite.x, sprite.y)
				end
			end
		end

		function system:update(dt, entity)
			local position = entity:get("position")

			if entity:get("shape") then
				shape = entity:get("shape")	
			end

			if entity:get("sprite") then
				drawn = entity:get("sprite")
			end
			
			if entity:get("player") then
				cam:setPosition(position.x, position.y)
			end
			
			if entity:get("animation") then
				local animation = entity:get("animation")
				animation.currentTime = animation.currentTime + dt
				if animation.currentTime >= animation.duration then
					animation.currentTime = animation.currentTime - animation.duration
				end
			end

			if entity:get("map") then
				entity:get("map").map:update(dt)
			end
		end

		function system:draw(entity)
			love.graphics.setDefaultFilter("nearest", "nearest")

			local position = entity:get("position")

			cam:draw(function(l,t,w,h)
				-- Draw camera stuff here.

				if entity:get("map") then
					entity:get("map").map:draw()
				end
			
				if entity:get("shape") then
					shape = entity:get("shape")	
				end

				if entity:get("animation") then
					local animation = entity:get("animation")
					drawn = animation
					local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.animations[2].quads) + 1
					love.graphics.draw(animation.sprites[2], animation.animations[2].quads[spriteNum], position.x, position.y)
				elseif entity:get("sprite") then
					drawn = entity:get("sprite")
					love.graphics.draw(drawn.sprite, position.x, position.y)
				end
			end)
		end

		return system
	end,

	movement = function(world)
		local system = ecs.system.new({ "position", "collision_box" })

		local input = Input()

		input:bind('d', 'right')
		input:bind('a', 'left')
		input:bind('s', 'down')
		input:bind('w', 'up')
		input:bind("k", "dash")


		function system:update(dt, entity)
			local position = entity:get("position")

			local goal_x = position.x
			local goal_y = position.y


			if entity:get("player") then
				if input:down('right') then
					goal_x = position.x + 200 * dt
				elseif input:down('left') then
					goal_x = position.x - 200 * dt
				end

				if input:down('down') then
					goal_y = position.y + 200 * dt
				elseif input:down('up') then
					goal_y = position.y - 200 * dt
				end

				if input:pressed("dash") then
					if input:down('right') then
						goal_x = position.x + 5000 * dt
					elseif input:down('left') then
						goal_x = position.x - 5000 * dt
					end
	
					if input:down('down') then
						goal_y = position.y + 5000 * dt
					elseif input:down('up') then
						goal_y = position.y - 5000 * dt
					end
				end

				local dx, dy = world:move(entity, goal_x, goal_y)
				position.x = dx
				position.y = dy 
			end
		end

		return system
	end,

	collision = function(world)
		local system = ecs.system.new({ "collision_box", "position" })

		function system:load(entity)
			local collision_box = entity:get("collision_box")
			local position = entity:get("position")

			world:add(entity, position.x, position.y, collision_box.width, collision_box.height)
		end

		return system
	end

}

