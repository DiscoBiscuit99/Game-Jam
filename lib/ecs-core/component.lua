return {
	new = function(id)
		assert(id, "ID must be given.")
		local component = { __id = id }
		return component
	end
}
