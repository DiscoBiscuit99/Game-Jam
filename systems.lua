local ecs 	 = require("lib.ecs")
local Input  = require("lib.input")
local gamera = require("lib.camera")


local WIDTH  = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

return {
	renderer = function()
		local system = ecs.system.new({ "position" })

		local cam = gamera.new(0,0,2000,2000)
		cam:setScale(2.0)

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
		end

		function system:draw(entity)
			local position = entity:get("position")

			cam:draw(function(l,t,w,h)
				-- draw camera stuff here
			
				if entity:get("shape") then
					shape = entity:get("shape")	
				end
				if entity:get("sprite") then
					drawn = entity:get("sprite")
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
		local system = ecs.system.new({ "player", "attack_box" })

		local input = Input()
		input:bind('j', 'attack')

		function system:update(dt, entity)
			if input:pressed("attack") then
				local actualX, actualY, cols, len = world:check(item, goalX, goalY)
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

