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

function hasValue(table, value)
    local keys = {}
    local z = 1
    for k,v in ipairs(table) do
        if v == value then
            keys[z] = k
            z = z + 1
        end
    end
    return keys
end

function vibratePattern()
	proVibrate(2)
	wait(1)
	proVibrate(2)
	wait(1)
	proVibrate(2)
end

Point = {}
Point.__index = Point
Point.mt = {
	__call = function (cls, ...)
		return cls.new(...)
	end,
}

setmetatable(Point, Point.mt)

function Point.new(x, y)
	local self = {}
	setmetatable(self, Point.mt)
    self.x = x
    self.y = y
    self.location = Location(x, y)
    return self
end

-- operator+
function Point.add(a, b)
    if (typeOf(b) == 'number') then
        return Point(a.x + b, a.y + b)
    else
        return Point(a.x + b.x, a.y + b.y)
    end
end
Point.mt.__add = Point.add

-- operator*
function Point.mul(a, b)
    return Point(a.x * b, a.y * b)
end
Point.mt.__mul = Point.mul

-- operator/
function Point.div(a, b)
    return Point(a.x / b, a.y / b)
end
Point.mt.__div = Point.div

-- operator-
function Point.sub(a, b)
    if (typeOf(b) == 'number') then
        return Point(a.x - b, a.y - b)
    else
        return Point(a.x - b.x, a.y - b.y)
    end
end
Point.mt.__sub = Point.sub

-- operator minus
function Point.unm(a)
    return Point(-a.x, -a.y)
end
Point.mt.__unm = Point.unm

-- concatenation
function Point.concat(lhs, rhs)
    if (typeOf(lhs) == 'table') then
        return "(" .. lhs.x .. "," .. lhs.y .. ")" .. rhs
    else
        return lhs .. "(" .. rhs.x .. "," .. rhs.y .. ")"
    end
end
Point.mt.__concat = Point.concat


Rect = {}
Rect.__index = Rect

setmetatable(Rect, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

-- x, y, w, h or x0, y0, x1, y1
function Rect.new(x, y, isWH, w, h)
	local self = setmetatable({}, Rect)
	if isWH then
	    self.x = x
	    self.y = y
	    self.w = w
	    self.h = h
    else
        -- w,h is not width/height.  Subtract the offset.
	    self.x = x
	    self.y = y
	    self.w = w - x
	    self.h = h - y
    end
    self.region = Region(self.x, self.y, self.w, self.h)
    return self
end

function Rect:getCenter()
    return Point(self.x + self.w / 2, self.y + self.h / 2)
end

-- axis 1 and axis 2 are both widht and height.  Will be applied on left-top and right bottom
function Rect:expand(x0, y0, x1, y1)
    self.x = self.x - x0
    self.y = self.y - y0
    self.w = self.w - x1
    self.h = self.h - y1
    self.region = Region(self.x, self.y, self.w, self.h)
end

function Rect:move(x, y)
    self.x = self.x + x0
    self.y = self.y + y0
    self.region = Region(self.x, self.y, self.w, self.h)
end

-- Only copy top level, the value still pointer to the same item.
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function iconcat(dest, offset, count, src)
    local c = 0
    local o = offset
    for k, v in ipairs(src) do
        dest[offset] = v
        o = o + 1
        c = c + 1
        if c > count then
            return
        end
    end
end
