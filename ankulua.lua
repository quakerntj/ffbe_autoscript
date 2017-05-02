Location = {}
Location.__index = Location

setmetatable(Location, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Location.new(x, y)
	local self = setmetatable({}, Location)
    self.x = x
    self.y = y
end

Region = {}
Region.__index = Region

setmetatable(Region, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Region.new(x, y)
	local self = setmetatable({}, Region)
    self.x = x
    self.y = y
end

function typeOf(obj)
    return type(obj)
end

function scriptExit() end

