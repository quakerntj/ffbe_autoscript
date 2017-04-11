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
region:highlight(0.4)
	local center = region:getCenter()
	print(center:getX().." "..center:getY())
	self.location = Location(center:getX(), center:getY() - 127) -- TODO Bug, center getY didn't divde to 2
	
	local swipeStep = 400
	self.swipeRight = Location(center:getX() + swipeStep, center:getY() - 127)
	self.swipeUp = Location(center:getX(), center:getY() - swipeStep - 127)
	self.swipeDown = Location(center:getX(), center:getY() + swipeStep - 127)
	self.swipeLeft = Location(center:getX() - swipeStep, center:getY() - 127)
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
	self.lineHeight = locations[3]:getY() - locations[1]:getY()
	self.centerX = region:getCenter():getX()
	self.centerY = region:getCenter():getY()
	self.center = Location(self.centerX, self.centerY)
	self.pageUpStep = Location(self.centerX, self.centerY - self.lineHeight * 3)
    self.ScrollRegion = Region(1410, 1592, 20, 704)
	return self
end

function BattlePage:nextPage()
	if self.ScrollRegion:exists("Battle_Page_Scroll_End.png") then
		return false
	end
	
	DragDrop(self.center, self.pageUpStep);
	return true
end

function BattlePage:choose(idx)
    click(self.locations[idx])
end

function BattlePage:existsChoose(pattern)
    self.region:existsClick(pattern)
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
        Location(360, 1960),  -- Item 3  -- Region(718, 1584, 1391-718, 1812-1584) Y gap 243
        Location(360, 2200),  -- Item 5
        Location(1080, 1700), -- Item 2
        Location(1080, 1960), -- Item 4
        Location(1080, 2200), -- Item 6
    }
   
    self.page = BattlePage(BattleItemRegion, BattleItemLocations)
    
    return self
end

-- Item index is in left-right-nextline order
function BattleScene:chooseItemByIndex(unit, idx)
    --self.units[unit]:item()
    itemIdx = idx;
    pageIdx = math.floor(idx / 9)
    local i = 0
    local res = false
    while i < pageIdx do
        i = i + 1
        if not self.page:nextPage() then
            return false
        end
        itemIdx = itemIdx - 9
    end
    i = nil
    self.page:choose(itemIdx)
    return true
end

function BattleScene:chooseItemByImage(pattern)
    self.units[unit]:item()
    while not self.page.exitsChoose(pattern) do
        if not self.page:nextPage() then
            return false
        end
    end
    return true
end
