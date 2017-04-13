-- Edit by Quaker NTj

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

function BattleUnit.new(region)
	local self = setmetatable({}, BattleUnit)
	self.region = region
	--region:highlight(0.1)
	local center = region:getCenter()
	local x = center:getX()
	local y = center:getY() - 127
	self.location = Location(x, y) -- TODO Bug, center getY didn't divde to 2
	
	local swipeStep = 400
	self.swipeRight = Location(x + swipeStep, y)
	self.swipeUp = Location(x, y - swipeStep)
	self.swipeDown = Location(x, y + swipeStep)
	self.swipeLeft = Location(x - swipeStep, y)
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
	return not ((self.region:exists("Limit.png")) == nil)
end

function BattleUnit:submit()
	-- Check pageStatus is in unit page
--	if not self.pageStatus == 0 then
--		self.scene:return()
--	end
	click(self.location)
end

function BattleUnit:abilityPage()
	dragDrop(self.location, self.swipeRight)
--	self.pageStatus = 1
--	self.actionStatus = 1
end

function BattleUnit:attack()
	dragDrop(self.location, self.swipeUp)
--	self.pageStatus = 1
--	self.actionStatus = 0
end

function BattleUnit:item()
	dragDrop(self.location, self.swipeLeft)
	print(self.location:getX().." "..self.location:getY() .. "--" .. self.swipeLeft:getX().." "..self.swipeLeft:getY())
--	self.pageStatus = 1
--	self.actionStatus = 1
end

function BattleUnit:defence()
	dragDrop(self.location, self.swipeDown)
--	self.pageStatus = 1
--	self.actionStatus = 1
end

BattlePage = {}
BattlePage.__index = BattlePage

setmetatable(BattlePage, {
  __call = function (cls, ...)
	return cls.new(...)
  end,
})

function BattlePage.new(region, locations)
	local self = setmetatable({}, BattlePage)
	self.region = region
	self.locations = locations
	self.lineHeight = 243 -- TODO hardcode
	-- region has bug in getCenter() we do it ourself
	self.centerX = (locations[1]:getX() + locations[2]:getX()) / 2
	self.centerY = locations[3]:getY()
	self.center = Location(self.centerX, self.centerY)
	self.lineUpStep = Location(self.centerX, self.centerY - self.lineHeight)
	self.pageUpStep = Location(self.centerX, self.centerY - self.lineHeight * 3)
	self.ScrollRegion = Region(1410, 1592, 20, 704)
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

	return click(self.locations[itemIdx])
end

function BattlePage:lineUp(lines)
	for i = 1,lines do
		dragDrop(self.center, self.lineUpStep);
		wait(0.1)
	end
end

function BattlePage:pageUp(pages)
	for i = 1, pages do
		dragDrop(self.center, self.pageUpStep);
		wait(0.1)
	end
end

function BattlePage:nextPage()
	dragDrop(self.center, self.pageUpStep);
	if self.ScrollRegion:exists("Battle_Page_Scroll_End.png") then
		return false
	end
	return true
end

function BattlePage:existsChoose(pattern)
	return self.region:existsClick(pattern)
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
	local BattleUnitRegions = {
		-- 715x256
		Region(2, 1586, 715, 256), -- Unit 1
		Region(2, 1844, 715, 256), -- Unit 2
		Region(2, 2103, 715, 256), -- Unit 3
		Region(719, 1586, 715, 256), -- Unit 4
		Region(719, 1844, 715, 256), -- Unit 5
		Region(719, 2103, 715, 256) -- Unit 6  Friend
	}
	
	self.units = {
		BattleUnit(BattleUnitRegions[1]),
		BattleUnit(BattleUnitRegions[2]),
		BattleUnit(BattleUnitRegions[3]),
		BattleUnit(BattleUnitRegions[4]),
		BattleUnit(BattleUnitRegions[5]),
		BattleUnit(BattleUnitRegions[6])
	}
 
	BattleItemRegion = Region(18, 1585, 1393, 2302)
	BattleItemLocations = {  -- Battle item location
		Location(360, 1700),  -- Item 1
		Location(1080, 1700), -- Item 2
		Location(360, 1960),  -- Item 3  -- Region(718, 1584, 1391-718, 1812-1584) Y gap 243
		Location(1080, 1960), -- Item 4
		Location(360, 2200),  -- Item 5
		Location(1080, 2200), -- Item 6
	}
   
	self.page = BattlePage(BattleItemRegion, BattleItemLocations)
	
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
