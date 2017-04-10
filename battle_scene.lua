-- Edit by Quaker NTj


ScrollRegion = Region(1410, 1592, 20, 704)

BIL = {  -- Battle item location
    Location(360, 1700),  -- Unit 1
    Location(360, 1960),  -- Unit 2
    Location(360, 2200),  -- Unit 3
    Location(1080, 1700), -- Unit 4
    Location(1080, 1960), -- Unit 5
    Location(1080, 2200), -- Friend
}

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

function BattleUnit.new(scene, location)
	local self = setmetatable({}, BattleUnit)
	self.scene = scene
	self.location = location
	self.swipeRight = Location(location.getX() + 250, location.getY())
	self.swipeUp = Location(location.getX(), location.getY() - 250)
	self.swipeDown = Location(location.getX(), location.getY() + 250)
	self.swipeLeft = Location(location.getX() - 250, location.getY())
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
	return self;
}

function BattleUnit:reset() {
	self.pageStatus = 0
	self.actionStatus = 0
}

function BattleUnit:submit() {
	-- Check pageStatus is in unit page
--	if not self.pageStatus == 0 then
--		self.scene:return()
--	end
	click(self.location)
}

function BattleUnit:abilityPage() {
	dragDrop(self.location, self.swipeRight)
--	self.pageStatus = 1
--	self.actionStatus = 1
}

function BattleUnit:attact() {
	dragDrop(self.location, self.swipeUp)
--	self.pageStatus = 1
--	self.actionStatus = 0
}

function BattleUnit:item() {
	dragDrop(self.location, self.swipeLeft)
--	self.pageStatus = 1
--	self.actionStatus = 1
}

function BattleUnit:defence() {
	dragDrop(self.location, self.swipeDown)
--	self.pageStatus = 1
--	self.actionStatus = 1
}

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
	self.lineHeight = locations[3].getY() - locations[1].getY()
	self.centerX = region.getX() + region.getW() / 2
	self.centerY = region.getY() + region.getH() / 2
	self.center = Location(self.centerX, self.centerY)
	self.pageUpStep = Location(self.centerX, self.centerY - self.lineHeight * 3)
	return self
end

function BattlePage:nextPage()
	if ScrollRegion:exists("Battle_Page_Scroll_End.png") then
		return false
	end
	
	DragDrop(self.center, self.pageUpStep);
end	

BattleScene = {}
BattleScene.__index = BattleScene

setmetatable(BattleScene, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function BattleScene.new(scene, location)
	local self = setmetatable({}, BattleScene)
	
end

-- Item index is in left-right-nextline order
function BattleScene:chooseItemByIndex(idx) {
	page = idx / 9
	result self.page:gotoPage(page)
	result = self.page.click(idx)
}

function BattleScene:chooseItemByImage(pattern) {
--	repeat existsClick(self.page:region, pattern) then
--		self.page:nextPage()
}
