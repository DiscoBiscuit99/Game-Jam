local ecs = require("lib.ecs")

local Input = require("lib.input")

return {
	renderer = function()
		local system = ecs.system.new({ "position" })

		function system:draw(entity)
			local position = entity:get("position")
			if entity:get("shape") then
				shape = entity:get("shape")	
			end
			if entity:get("sprite") then
				drawn = entity:get("sprite")
			end
			love.graphics.draw(drawn.sprite, position.x, position.y)
		end

		return system
	end,

	movement = function(world)
		local system = ecs.system.new({ "position", "collision_box" })

		function system:update(dt, entity)
			local position = entity:get("position")

			local input = Input()

			input:bind('d', 'right')
			input:bind('a', 'left')
			input:bind('s', 'down')
			input:bind('w', 'up')

			local goal_x = position.x
			local goal_y = position.y

			if entity:get("player") then
				if input:down('right') then
					goal_x = position.x + 100*dt
				elseif input:down('left') then
					goal_x = position.x - 100*dt
				end

				if input:down('down') then
					goal_y = position.y + 100*dt
				elseif input:down('up') then
					goal_y = position.y - 100*dt
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

