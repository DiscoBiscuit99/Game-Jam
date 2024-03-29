local ecs 	 = require("lib.ecs")
local gamera = require("lib.camera")

local Input = require("lib.input")

local components = require("components")

require("shaders")

local WIDTH  = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

return {
	renderer = function(ent_world, bump_world)
		local system = ecs.system.new({ "position" })

		local cam = gamera.new(0,0,3000,3000)
		cam:setScale(3)

		local player

		function system:load(entity)
			atmosphere_shader = love.graphics.newShader(atmosphere_shader_code)

			if entity:get("map") then
				map_ent = entity:get("map")
				map_ent.map:bump_init(bump_world)
				
				for _, object in pairs(map_ent.map.layers["spawn"].objects) do
					if object.name == "enemy_spawn" then
						enemy = ent_world:create_entity()
						enemy:add_component(components.enemy(100))
						enemy:add_component(components.position(object.x, object.y))
						enemy:add_component(components.collision_box(0, 0, 32, 32))
            			enemy:add_component(components.animation(32, 32, 1, "assets/sprites/enemy/walk_down.png", "assets/sprites/enemy/walk_right.png", "assets/sprites/enemy/walk_up.png", "assets/sprites/enemy/walk_left.png"))

					elseif object.name == "player_spawn" then
						player = ent_world:create_entity()
						player:add_component(ecs.component.new("player"))
						player:add_component(components.position(object.x, object.y))
						player:add_component(components.collision_box(13, 20, 8, 12))
						player:add_component(components.animation(32, 32, 1, "assets/sprites/front_walk.png", "assets/sprites/walk_right.png", "assets/sprites/walk_up.png", "assets/sprites/walk_left.png", "assets/sprites/idle.png"))
						player:add_component(components.sound("assets/sounds/hit.wav"))

					elseif object.name == "boss_spawn" then
						boss = ent_world:create_entity()
						boss:add_component(components.enemy(1000))
						boss:add_component(components.position(object.x, object.y))
						boss:add_component(components.sprite("assets/sprites/deamon_sprite.png"))
						boss:add_component(components.collision_box(0, 0, 64, 60))

					end
				end
			end
		end

		function system:update(dt, entity)
			local position = entity:get("position")

			if entity:get("shape") then
				shape = entity:get("shape")	
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

			love.graphics.setShader(atmosphere_shader)
			atmosphere_shader:send("screen", {WIDTH, HEIGHT})

			local position = entity:get("position")

			cam:draw(function(l,t,w,h)
				-- Draw camera stuff here.
				
				local sx, sy = cam:getScale()

				if entity:get("map") then
					entity:get("map").map:draw(-l, -t, sx, sy)
					love.graphics.setColor(1, 0, 0)
					--entity:get("map").map:bump_draw(bump_world)
				end
			
				if entity:get("sprite") then
					drawn = entity:get("sprite")
					love.graphics.draw(drawn.sprite, position.x, position.y)
				end

				if entity:get("animation") then
					local animation = entity:get("animation")
					drawn = animation
			
					local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.animations[animation.current_anim].quads) + 1
					love.graphics.draw(animation.sprites[animation.current_anim], animation.animations[animation.current_anim].quads[spriteNum], position.x, position.y)
				end


				if entity:get("collision_box") then
					local collision_box = entity:get("collision_box")
					--love.graphics.rectangle("line",  collision_box.x, collision_box.y, collision_box.width, collision_box.height)
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
		input:bind('k', 'dash')

		function system:update(dt, entity)
			local position = entity:get("position")

			if entity:get("player") and entity:get("animation") then
				local animation = entity:get("animation")

				local collision_box = entity:get("collision_box")

				local goal_x = collision_box.x
				local goal_y = collision_box.y
				
				animation.current_anim = 5

				if input:down('right') then
					goal_x = collision_box.x + 150 * dt
					animation.current_anim = 2
				elseif input:down('left') then
					goal_x = collision_box.x - 150 * dt
					animation.current_anim = 4
				end

				if input:down('down') then
					goal_y = collision_box.y + 150 * dt
					animation.current_anim = 1
				elseif input:down('up') then
					goal_y = collision_box.y - 150 * dt
					animation.current_anim = 3
				end

				if input:pressed('dash') then
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

		local input = Input()
		input:bind('j', 'attack')
		input:bind('d', 'right')
		input:bind('a', 'left')
		input:bind('s', 'down')
		input:bind('w', 'up')

		function system:update(dt, entity)

			local position = entity:get("position")

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
					if item.components ~= nil and item:get("enemy") then
						return "cross"
					else
						return nil
					end
				end

				local items, len = world:queryRect(position.x + (20 * dir_x), position.y + (20 * dir_y), 32, 32, filter)
				for i=1, len, 1 do
					local other = items[i]
					local enemy = other:get("enemy")
					local pos = other:get("position")
					local sound = entity:get("sound")

					enemy.health = enemy.health - 50
					enemy.knockback_x = pos.x + 100 * dir_x
					enemy.knockback_y = pos.y + 100 * dir_y
					enemy.stun_timer = 1

					sound.sound:play()	

					sound.sound:play()	

					if enemy.health <= 0 then
						if other:get("sound") then
							other:get("sound").sound:stop()	
							other:get("sound").sound = love.audio.newSource("assets/sounds/word_around_the_office-trimmed.wav", "static")
							other:get("sound").sound:play()
						end
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
	end,

	enemy = function(world)
		local system = ecs.system.new({ "position", "collision_box" })

		local px = 0
		local py = 0

		local range = 200

		function system:update(dt, entity)
			local position = entity:get("position")
			local collision_box = entity:get("collision_box")

			if entity:get("player") then
				px = position.x
				py = position.y
			end

			if entity:get("enemy") then
				local enemy = entity:get("enemy")
				
				if enemy.knockback_x > 0 and enemy.knockback_y > 0 or enemy.knockback_x < 0 and enemy.knockback_y < 0 then
					local tx = enemy.knockback_x - position.x
					local ty = enemy.knockback_y - position.y

					local len = math.sqrt(math.pow(tx, 2) + math.pow(ty, 2))
					
					enemy.stun_timer = enemy.stun_timer - dt 

					if len > 1 and enemy.stun_timer > 0 then
						tx = tx / math.abs(len)
						ty = ty / math.abs(len)
	
						local goal_x = position.x + tx * dt * 300
						local goal_y = position.y + ty * dt * 300
						local dx, dy = world:move(entity, goal_x, goal_y)
						position.x = dx
						position.y = dy
					else
						enemy.knockback_x = 0
						enemy.knockback_y = 0
						enemy.stun_timer = 0
					end

				else
					local tx = px - position.x
					local ty = py - position.y
	
					local len = math.sqrt(math.pow(tx, 2) + math.pow(ty, 2))

					if len <= range then
						tx = tx / math.abs(len)
						ty = ty / math.abs(len)
	
						local goal_x = position.x + tx * dt * 100
						local goal_y = position.y + ty * dt * 100
						
						local dx, dy = world:move(entity, goal_x, goal_y)
						position.x = dx
						position.y = dy
					end
				end

			end
		end

		return system
	end,

	sound = function()
		local system = ecs.system.new({ "sound" })

		local position
		local e_vector

		function system:load(entity)
			
		end

		function system:update(dt, entity)
			if entity:get("position") then
				position = entity:get("position")
			end

			if entity:get("player") then
				player_pos = entity:get("position")
			end

			if entity:get("enemy") then
				enemy_pos = entity:get("position")
			end

			if player_pos and enemy_pos then
				dx = player_pos.x - enemy_pos.x
				dy = player_pos.y - enemy_pos.y

				local vector = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
				print("vector: " .. vector)

				ex = dx / math.abs(vector)
				ey = dy / math.abs(vector)

				if entity:get("sound").background then
					love.audio.setDistanceModel("inverse")
					sound = entity:get("sound").sound
					sound:setVolume(1/vector*6)
					print("sound: " .. sound:getVolume())
					sound:play()
				end
			end
		end

		return system

	end
}

