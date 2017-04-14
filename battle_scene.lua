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

BattleLocationInit = false
BattleLocationItems = {}

function AttackAllClick(order)
	for i,unit in ipairs(order) do
		click(BIL[unit])
	end
end

-- ======== Class Battle Unit/Scene =======
BattleUnit = {}
BattleUnit.__index = BattleUnit

setmetatable(BattleUnit, {
  __call = function (cls, ...)
	return cls.new(...)
  end,
})

function BattleUnit.new(rect)
	local self = setmetatable({}, BattleUnit)
	self.rect = rect
	self.center = rect:getCenter()
	
	local swipeStep = 400
	self.swipeRight = self.center + Point(swipeStep, 0)
	self.swipeUp    = self.center + Point(0, -swipeStep)
	self.swipeDown  = self.center + Point(0, swipeStep)
	self.swipeLeft  = self.center + Point(-swipeStep, 0)
	self.PageStatus = {
		UnitPage = 0,
		AbilityPage = 1,
		ItemPage = 2
	}
	self.ActionStatus = {
		NomalAttack = 0,
		UseAbility = 1,
		UseIteam = 2,
		Defence = 3
	}
	return self
end

function BattleUnit:reset()
	self.pageStatus = 0
	self.actionStatus = 0
end

function BattleUnit:checkExists()
	return not ((self.rect.region:exists("Limit.png")) == nil)
end

function BattleUnit:submit()
	click(self.center.location)
end

function BattleUnit:abilityPage()
	dragDrop(self.center.location, self.swipeRight.location)
end

function BattleUnit:attack()
	dragDrop(self.center.location, self.swipeUp.location)
end

function BattleUnit:item()
	dragDrop(self.center.location, self.swipeLeft.location)
end

function BattleUnit:defence()
	dragDrop(self.center.location, self.swipeDown.location)
end

BattlePage = {}
BattlePage.__index = BattlePage

setmetatable(BattlePage, {
  __call = function (cls, ...)
	return cls.new(...)
  end,
})

function BattlePage.new(rect, rects)
	local self = setmetatable({}, BattlePage)
	self.rect = rect
	self.rects = rects

	local lineHeight = rects[3].y - rects[1].y
	local centerX = (rects[1].x + rects[2].x) / 2
	local centerY = rects[5]:getCenter().y

	self.dragCenter = Point(centerX, centerY)
	self.lineUpStep = Point(centerX, centerY -lineHeight)
	self.pageUpStep = Point(centerX, centerY -lineHeight * 1.5)
	self.ScrollRegion = Rect(1410, 1592, true, 20, 704)
	return self
end

-- Item index is in left-right-nextline order.  And idx count from 1
function BattlePage:choose(idx)
	--[[
		For example
			item 2 will no need line up
			item 9 will need line up just 2 row.
			item 16 will need line up 1 page and 2 row
	--]]
	local lines = 0
	local pages = 0
	local itemIdx = idx

	if idx > 6 then
		lines = math.ceil(idx / 2) - 3   -- 9: 2, 16: 5
		pages = math.floor(lines / 3)    -- 9: 0, 16: 1
		lines = lines - pages * 3        -- 9: 2, 16: 2
		itemIdx = (idx - 1) % 2 + 4 + 1  -- 9: 5, 16: 6

		self:pageUp(pages)
		self:lineUp(lines)
	end
	click(self.rects[itemIdx]:getCenter().location)
    return true
end

function BattlePage:lineUp(lines)
    if lines == 0 then return end
	for i = 1,lines do
		dragDrop(self.dragCenter.location, self.lineUpStep.location);
		wait(0.1)
	end
end

function BattlePage:pageUp(pages)
    if pages == 0 then return end
	for i = 1, pages do
        dragDrop(self.dragCenter.location, self.pageUpStep.location);
		wait(0.1)
        dragDrop(self.dragCenter.location, self.pageUpStep.location);
		wait(0.1)
	end
end

function BattlePage:nextPage()
	dragDrop(self.dragCenter.location, self.pageUpStep.location);
	wait(0.1)
	dragDrop(self.dragCenter.location, self.pageUpStep.location);
	wait(0.1)
	if self.ScrollRegion.region:exists("Battle_Page_Scroll_End.png") then
		return false
	end
	return true
end

function BattlePage:existsChoose(pattern)
	return self.rect.region:existsClick(pattern)
end

BattleScene = {}
BattleScene.__index = BattleScene

setmetatable(BattleScene, {
  __call = function (cls, ...)
	return cls.new(...)
  end,
})

function BattleScene.new()
	local self = setmetatable({}, BattleScene)
	local BattleUnitRects = {
		-- 715x256
		Rect(2, 1586, true, 715, 256), -- Unit 1
		Rect(2, 1844, true, 715, 256), -- Unit 2
		Rect(2, 2103, true, 715, 256), -- Unit 3
		Rect(719, 1586, true, 715, 256), -- Unit 4
		Rect(719, 1844, true, 715, 256), -- Unit 5
		Rect(719, 2103, true, 715, 256) -- Unit 6  Friend
	}
	
	self.units = {
		BattleUnit(BattleUnitRects[1]),
		BattleUnit(BattleUnitRects[2]),
		BattleUnit(BattleUnitRects[3]),
		BattleUnit(BattleUnitRects[4]),
		BattleUnit(BattleUnitRects[5]),
		BattleUnit(BattleUnitRects[6])
	}
 
	BattleItemRect = Rect(18, 1585, true, 1393, 2302)
	BattleItemRects = {
	    Rect( 20, 1584, true, 675, 230),
	    Rect(718, 1584, true, 675, 230),
	    Rect( 20, 1827, true, 675, 230),
	    Rect(718, 1827, true, 675, 230),
	    Rect( 20, 2070, true, 675, 230),
	    Rect(718, 2070, true, 675, 230),
	}
   
	self.page = BattlePage(BattleItemRect, BattleItemRects)
	
	return self
end

function BattleScene:chooseByImage(pattern)
	while not self.page.exitsChoose(pattern) do
		if not self.page:nextPage() then
			return false
		end
	end
	return true
end
