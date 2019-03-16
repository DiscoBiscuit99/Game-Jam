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
            
					local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.animations[animation.current_anim].quads) + 1
					love.graphics.draw(animation.sprites[animation.current_anim], animation.animations[animation.current_anim].quads[spriteNum], position.x, position.y)
				else
					love.graphics.draw(drawn.sprite, position.x, position.y)
				end

				--if entity:get("collision_box") then
				--	local collision_box = entity:get("collision_box")
				--	love.graphics.rectangle("line",  collision_box.x, collision_box.y, collision_box.width, collision_box.height)
				--end
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
			local collision_box = entity:get("collision_box")

			local goal_x = collision_box.x
			local goal_y = collision_box.y


			if entity:get("player") and entity:get("animation") then
				local animation = entity:get("animation")
				
				animation.current_anim = 5

				if input:down('right') then
					goal_x = collision_box.x + 200 * dt
					animation.current_anim = 2
				elseif input:down('left') then
					goal_x = collision_box.x - 200 * dt
					animation.current_anim = 4
				end

				if input:down('down') then
					goal_y = collision_box.y + 200 * dt
					animation.current_anim = 1
				elseif input:down('up') then
					goal_y = collision_box.y - 200 * dt
					animation.current_anim = 3
				end

				if input:pressed("dash") then
					if input:down('right') then
						goal_x = collision_box.x + 5000 * dt
					elseif input:down('left') then
						goal_x = collision_box.x - 5000 * dt
					end
	
					if input:down('down') then
						goal_y = collision_box.y + 5000 * dt
					elseif input:down('up') then
						goal_y = collision_box.y - 5000 * dt
					end
				end

				local dx, dy = world:move(entity, goal_x, goal_y)
				position.x = collision_box.x - collision_box.x_offset
				position.y = collision_box.y - collision_box.y_offset
			end
		end

		return system
	end,

	attack = function(world)
		local system = ecs.system.new({ "player", "attack_box", "position" })

		local position = entity:get("position")

		local input = Input()
		input:bind('j', 'attack')
		input:bind('d', 'right')
		input:bind('a', 'left')
		input:bind('s', 'down')
		input:bind('w', 'up')

		function system:update(dt, entity)
			if input:pressed("attack") then
				
				local dir_x = 0
				local dir_y = 0

				if input:down('right') then
					dir_x = 1
				elseif input:down('left') then
					dir_x = -1
				end

				if input:down('down') then
					dir_y = 1
				elseif input:down('up') then
					dir_y = -1
				end

				local filter = function(item)
					if item:get("enemy") then
						return "cross"
					end
					return nil
				end

				local items, len = world:queryRect(position.x + (10 * dir_x), position.y + (10 * dir_y), 32, 32, filter)

				for i=1, len, 1 do
					local other = items[i]
					local enemy = other:get("enemy") 
					
					enemy.health = enemy.health - 50

					if enemy.health <= 0 then
						world:remove(other)
						other:destroy()
					end
				end

			end
		end

		return system
	end,

	collision = function(world)
		local system = ecs.system.new({ "collision_box", "position" })

		function system:load(entity)
			local collision_box = entity:get("collision_box")
			local position = entity:get("position")

			collision_box.x = position.x + collision_box.x_offset
			collision_box.y = position.y + collision_box.y_offset
			world:add(entity, collision_box.x, collision_box.y, collision_box.width, collision_box.height)
		end

		function system:update(dt, entity)
			local collision_box = entity:get("collision_box")
			local position = entity:get("position")
			local x,y = world:getRect(entity)
			collision_box.x = x
			collision_box.y = y
		end

		return system
	end

}

