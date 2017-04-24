-- Copyright © 2017 Quaker NTj <quakerntj@hotmail.com>
-- <https://github.com/quakerntj/ffbe_autoscript>

--[[
    This script is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

WatchDog = {}
WatchDog.__index = WatchDog

setmetatable(WatchDog, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function WatchDog.new(timeout, obj, bark)
	local self = setmetatable({}, WatchDog)
	self.timeout = timeout
	self.timer = Timer()
	self.timer:set()
	self.obj = obj
	self.en = true
	self.bark = bark -- callback function
	return self
end

function WatchDog:touch()
	self.timer:set()
end

function WatchDog:enable(b)
    self.en = b
    self:touch()
end

function WatchDog:awake()
	if self.en and (self.timer:check() > self.timeout) then
		self.bark(self.obj, self)  -- User should touch the dog themself.
	end
end


