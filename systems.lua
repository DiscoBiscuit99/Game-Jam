local ecs 	 = require("lib.ecs")
local Input  = require("lib.input")
local gamera = require("lib.camera")


return {
	renderer = function()
		local system = ecs.system.new({ "position" })

		local cam = gamera.new(0,0,2000,2000)
		cam:setScale(2.0)

		function system:update(dt, entity)
			local position = entity:get("position")
			
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
					local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.animations[2].quads) + 1
					love.graphics.draw(animation.sprites[2], animation.animations[2].quads[spriteNum], position.x, position.y)
				else
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

