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
	self.attackRect = Rect(self.rect.x, self.rect.y, true, 70, 60)
	
	local swipeStep = 400
	self.swipeRight = self.center + Point(swipeStep, 0)
	self.swipeUp	= self.center + Point(0, -swipeStep)
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

function BattleUnit:isReadyToAttack()
	return self.attackRect.region:exists("NormalAttack.png")
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

	local upCenterX = (rects[1].x + rects[2].x) / 2
	local upCenterY = rects[5]:getCenter().y

	self.dragUpCenter = Point(upCenterX, upCenterY)
	self.lineUpStep = Point(upCenterX, upCenterY - lineHeight)
	self.pageUpStep = Point(upCenterX, upCenterY - lineHeight * 1.5)

	local downCenterX = (rects[1].x + rects[2].x) / 2
	local downCenterY = rects[1]:getCenter().y

	self.dragDownCenter = Point(downCenterX, downCenterY)
	self.lineDownStep = Point(downCenterX, downCenterY + lineHeight)
	self.pageDownStep = Point(downCenterX, downCenterY + lineHeight * 1.5)

	self.ScrollRegion = Rect(1410, 1592, true, 20, 704)
	return self
end

-- Item index is in left-right-nextline order.  And idx count from 1
function BattlePage:choose(destIdx, srcIdx)
	--[[
		For example
			item 2 will no need line up
			item 9 will need line up just 2 row.
			item 16 will need line up 1 page and 2 row
	--]]
	local lines, pages, itemIdx = self:linesCalculator(destIdx, srcIdx)

	if pages > 0 then
		self:pageUp(pages)
	elseif pages < 0 then
		self:pageDown(-pages)
	end
	if lines > 0 then
		self:lineUp(lines)
	elseif lines < 0 then
		self:lineDown(-lines)
	end

	click(self.rects[itemIdx]:getCenter().location)
end

function BattlePage:linesCalculatorInner(idx)
	local lines = 0
	local itemIdx = idx
	if idx ~= nil and idx > 6 then
		lines = math.ceil(idx / 2) - 3   -- 9: 2, 16: 5
		itemIdx = (idx - 1) % 2 + 4 + 1  -- 9: 5, 16: 6
	end
	return lines, itemIdx
end

function BattlePage:linesCalculator(dest, src)
	local dlines, ditemIdx = self:linesCalculatorInner(dest)
	local slines, sitemIdx = self:linesCalculatorInner(src)

	local lineDiff = dlines - slines
	local pages = math.floor(lineDiff / 3)	-- 9: 0, 16: 1
	local lines = lineDiff - pages * 3		-- 9: 2, 16: 2
	return lines, pages, ditemIdx
end

function BattlePage:lineUp(lines)
	if lines == 0 then return end
	for i = 1,lines do
		dragDrop(self.dragUpCenter.location, self.lineUpStep.location);
		wait(0.1)
	end
end

function BattlePage:pageUp(pages)
	if pages == 0 then return end
	for i = 1, pages do
		dragDrop(self.dragUpCenter.location, self.pageUpStep.location);
		wait(0.1)
		dragDrop(self.dragUpCenter.location, self.pageUpStep.location);
		wait(0.1)
	end
end

function BattlePage:lineDown(lines)
	if lines == 0 then return end
	for i = 1,lines do
		dragDrop(self.dragDownCenter.location, self.lineDownStep.location);
		wait(0.1)
	end
end

function BattlePage:pageDown(pages)
	if pages == 0 then return end
	for i = 1, pages do
		dragDrop(self.dragDownCenter.location, self.pageDownStep.location);
		wait(0.1)
		dragDrop(self.dragDownCenter.location, self.pageDownStep.location);
		wait(0.1)
	end
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

function BattleScene:submit(...)
	local s = table.getn(arg)
	local touchList = {}
	for i = 1, s do
		if arg[i] > 6 then
			table.insert(touchList, {action = "wait", target = (arg[i] / 1000)})
		else
			local unit = self.units[arg[i]]
			local center = unit.center.location
			table.insert(touchList, {action = "touchDown", target = center})
			table.insert(touchList, {action = "wait", target = 0.0001})
			table.insert(touchList, {action = "touchUp", target = center})

			if arg[i+1] ~= nil then
				-- if has next action, do wait.  If next action is wait, skip wait.
				if arg[i+1] < 6 then
					-- Next is not wait, use default wait for a frame (60FPS).
					--table.insert(touchList, {action = "wait", target = 0.0166})
				end
			end
		end
	end
	manualTouch(touchList)
end

function BattleScene:chooseByImage(pattern)
	while not self.page.exitsChoose(pattern) do
		if not self.page:nextPage() then
			return false
		end
	end
	return true
end


