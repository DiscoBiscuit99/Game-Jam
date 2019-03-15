local ecs = require("lib.ecs")

return {
	position = function(x, y)
		local err_msg = "x;y must be numbers."
		assert(type(x) == "number" and type(y) == "number")
		local component = ecs.component.new("position")
		
		component.x = x
		component.y = y

		return component
	end,

	sprite = function(sprite)
		local err_msg = "Sprite path must be a string."
		assert(type(sprite) == "string", err_msg)
		local component = ecs.component.new("sprite")

		component.sprite = love.graphics.newImage(sprite)

		return component
	end,

	collision_box = function(width, height)
		local component = ecs.component.new("collision_box")

		component.width = width
		component.height = height

		return component
	end

}
