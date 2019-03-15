local WIDTH  = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

return {
	new = function()
		local camera = {}
		camera.x = 0
		camera.y = 0
		camera.scale = 1

		function camera:setScale(scale)
			self.scale = scale
		end

		function camera:set(x, y)
			self.x = x
			self.y = y

			love.graphics.push()
			love.graphics.translate(-self.x + WIDTH/2, -self.y + HEIGHT/2)
		end

		function camera:unset()
			love.graphics.pop()
		end
		
		return camera
	end
}
