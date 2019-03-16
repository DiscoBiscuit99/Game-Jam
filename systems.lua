local ecs = require("lib.ecs")

local Camera = require("lib.camera")

local Input = require("lib.input")

return {
	renderer = function()
		local system = ecs.system.new({ "position" })

		local cam = Camera( 400, 300, { x = 32, y = 32, resizable = true, maintainAspectRatio = true } )

		function system:update(dt, entity)
			local position = entity:get("position")

			if entity:get("player") then
				cam:setTranslation(position.x, position.y)
			end

			cam:update()
			
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

			cam:push()

			if entity:get("shape") then
				shape = entity:get("shape")	
			end
			if entity:get("sprite") then
				drawn = entity:get("sprite")
			end
			if entity:get("animation") then
				local animation = entity:get("animation")
				drawn = animation
				local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
				love.graphics.draw(animation.sprite, animation.quads[spriteNum], position.x, position.y)
			else
				love.graphics.draw(drawn.sprite, position.x, position.y)
			end
	  
			cam:pop()

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

		--function system:update(dt, entity)
		--	local position = entity:get("position")
		--	world:move(entity, position.x, position.y)
		--end

		return system
	end

}

