local ecs = require("lib.ecs")

local camera = require("lib.camera")

local Input = require("lib.input")

return {
	renderer = function()
		local system = ecs.system.new({ "position" })

		local camera = camera.new()

		function system:draw(entity)
			local position = entity:get("position")
			if entity:get("shape") then
				shape = entity:get("shape")	
			end
			if entity:get("sprite") then
				love.graphics.setDefaultFilter("nearest", "nearest")
				drawn = entity:get("sprite")
			end

			if entity:get("player") then
				camera:set(position.x, position.y)
				love.graphics.draw(drawn.sprite, position.x, position.y)
				camera:unset()
			end
		end

		return system
	end,

	movement = function()
		local system = ecs.system.new({ "position" })

		local input = Input()

		input:bind('d', 'right')
		input:bind('a', 'left')
		input:bind('s', 'down')
		input:bind('w', 'up')

		function system:update(dt, entity)
			local position = entity:get("position")			

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

