M = {}

function M.Manager(super)
	local obj = {}
	obj.__index = obj
	setmetatable(obj, super)

	function obj.new(...)
		if obj._instance then
			return obj._instance
		end

		local instance = setmetatable({}, obj)
		if instance.ctor then
			instance:ctor(...)
		end

		obj._instance = instance
		return obj._instance
	end

	return obj
end

return M
