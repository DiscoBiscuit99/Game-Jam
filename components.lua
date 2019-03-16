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

	animation = function(width, height, duration, ...)
		--local err_msg = "Sprite path must be a string."
		--assert(type(sprite) == "string", err_msg)
		local component = ecs.component.new("animation")

		local args = {...}

		component.sprites = {}
		component.animations = {}

		for i=1,#args do
			assert(type(args[i]) == "string", "Additional arguments must be a string. Type is: " .. type(args[i]))
			table.insert(component.sprites, love.graphics.newImage(args[i]))
			table.insert(component.animations, {})
			component.animations[i].quads = {}
			for y = 0, component.sprites[i]:getHeight() - height, height do
				for x = 0, component.sprites[i]:getWidth() - width, width do
					table.insert(component.animations[i].quads, love.graphics.newQuad(x, y, width, height, component.sprites[i]:getDimensions()))
				end
			end
		end

		--component.sprite = love.graphics.newImage(sprite)
		
		component.duration = duration or 1
    	component.currentTime = 0

		return component
	end,

	collision_box = function(width, height)
		local component = ecs.component.new("collision_box")

		component.width = width
		component.height = height

		return component
	end

}
