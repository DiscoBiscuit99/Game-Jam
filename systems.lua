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

			if entity:get("player") then
				love.graphics.draw(drawn.sprite, position.x, position.y)
			end
		end

		return system
	end,

	movement = function()
		local system = ecs.system.new({ "position" })

		function system:load(entity)
		end

		function system:update(dt, entity)
			local position = entity:get("position")			

			local input = Input()

			input:bind('d', 'right')
			input:bind('a', 'left')
			input:bind('s', 'down')
			input:bind('w', 'up')

			if entity:get("player") then
				if input:down('right') then
					position.x = position.x + 100*dt
				elseif input:down('left') then
					position.x = position.x - 100*dt
				end

				if input:down('down') then
					position.y = position.y + 100*dt
				elseif input:down('up') then
					position.y = position.y - 100*dt
				end
			end
		end

		return system
	end
}

