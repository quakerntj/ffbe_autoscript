-- Edit by Quaker NTj

-- ========== Initial Settings ================
Settings:setCompareDimension(true, 1440)--執行圖形比對時螢度的解析度。根據compareByWidth的值的值設定成寬度或高度
Settings:setScriptDimension(true, 1440)--用於參考App解析度腳本內座標位置
Settings:set("MinSimilarity", 0.85)

setDragDropTiming(400, 800)			--downMs: 開始移動前壓不住不動幾毫秒	upMs: 最後放開前停住幾毫秒
setDragDropStepCount(3)				--stepCount: 從啟始點到目的地分幾步移動完
setDragDropStepInterval(100)	--intervalMs: 每次移動間停留幾毫秒

screen = getAppUsableScreenSize()
X = screen:getX()
Y = 2560 --screen:getY() will not get right full screen size.
DEBUG = true

X12 = X / 2
X14 = X / 4
X34 = X * 3 / 4
X13 = X / 3
X23 = X * 2 / 3

X15 = X / 5
X25 = X * 2 / 5
X35 = X * 3 / 5
X45 = X * 4 / 5

Y12 = Y / 2
Y14 = Y / 4
Y34 = Y * 3 / 4
Y13 = Y / 3
Y23 = Y * 2 / 3

Y18 = Y / 8.0
Y38 = Y * 3 / 8
Y58 = Y * 5 / 8
Y78 = Y * 7 / 8

--[[
    Naming Rule
    Single offset, length
    For Example
        X13 = X / 3
        Y24 = Y12 = Y / 2

    Region
        R[Split X][Split Y]_[Piece X Offset][Piece X Length][Piece Y Offset][Piece Y Length]
    For example
        R42_1111 = Region(X14, Y12, X14, Y12)
        R42_021 = Region(X14, Y12, X24, Y12)  -- X has 2 piece
--]]
        
    
R12_0011 = Region(0, 0, X, Y12)
R12_0111 = Region(0, Y12, X, Y12)
R21_0011 = Region(0, 0, X12, Y)
R21_1011 = Region(X12, 0, X12, Y)
R14_0112 = Region(0, Y12, X14, Y12)
R13_0111 = Region(0, Y13, X, Y13)
R33_1121 = Region(X13, Y23, X13, Y13)
R14_0111 = Region(0, Y14, X, Y12)
R23_1111 = Region(X12, Y13, X12, Y13)
R34_1311 = Region(X13, Y34, X13, Y14)
R28_0711 = Region(0, Y78, X12, Y18)
R24_1211 = Region(X12, Y12, X12, Y14)
R34_1211 = Region(X13, Y12, X13, Y14)
R58_2611 = Region(X25, Y34, X15, Y18)
R18_0711 = Region(0, Y78, X, Y18)

ScrollRegion = Region(1410, 1592, 1430, 2296)

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

BIL = {  -- Battle item location
    Location(360, 1700),  -- Unit 1
    Location(360, 1950),  -- Unit 2
    Location(360, 2200),  -- Unit 3
    Location(1080, 1700), -- Unit 4
    Location(1080, 1950), -- Unit 5
    Location(1080, 2200), -- Friend
}

ResultExp = Region(560, 1000, 1150, 1400)
--ResultNext = Region(600, 2200, 840, 2300)
ResultItemNextLocation = Location(720, 2250)

BattleLocationInit = false
BattleLocationItems = {}

function AttackAllClick(order)
    for i,unit in ipairs(order) do
        click(BIL[unit])
    end
end

-- 
--[[
    DXN = 10 -- X NAGTIVE
    DXC = 720 -- X CENTER
    DXP = 1430 -- X POSITIVE

    DYN = 150 -- Y NAGATIVE
    DYC = 1170 -- Y CENTER
    DYP = 2400 -- Y POSITIVE
    
    DTABLE = {}
    DTABLE[4] = Location(DXN, DYC)
    DTABLE[7] = Location(DXN / 2, DYP / 2)
    DTABLE[8] = Location(DXC, DYP)
    DTABLE[9] = Location(DXP / 2, DYP / 2)
    DTABLE[6] = Location(DXP, DYC)
    DTABLE[3] = Location(DXP / 2, DYN / 2)
    DTABLE[2] = Location(DXC, DYN)
    DTABLE[1] = Location(DXN / 2, DYN / 2)

    DTABLE[5] = Location(DXC, DYC)
    
    directions = {}
    dirsCount = 0
    if pattern == 1 then -- \
        directions = {7, 4, 7, 8, 7, 7, 7, 8, 7, 4}
    elseif pattern == 2 then -- |
        directions = {8, 8, 7, 8, 9, 8, 8, 8, 7, 9}
    elseif pattern == 3 then -- /
        directions = {9, 9, 8, 9, 6, 9, 9, 9, 8, 6}
    elseif pattern == 4 then -- -
        directions = {4, 4, 1, 4, 4, 4, 7, 4, 1, 4}
    elseif pattern == 5 then -- O
        directions = {4, 7, 8, 9, 6, 3, 2, 1, 6, 4}
    end
--]]

function move(pattern)
    math.randomseed(os.time())
    if pattern == 6 then
        pattern = math.random(1,5)
    end
    inverse = math.random(0,1)

    DXN = 380 -- X NAGTIVE
    DXC = 800 -- X CENTER
    DXP = 1210 -- X POSITIVE

    DYN = 770 -- Y NAGATIVE
    DYC = 1170 -- Y CENTER
    DYP = 1570 -- Y POSITIVE
    
    DTABLE = {}
    DTABLE[4] = Location(DXN, DYC)
    DTABLE[7] = Location(DXN, DYP)
    DTABLE[8] = Location(DXC, DYP)
    DTABLE[9] = Location(DXP, DYP)
    DTABLE[6] = Location(DXP, DYC)
    DTABLE[3] = Location(DXP, DYN)
    DTABLE[2] = Location(DXC, DYN)
    DTABLE[1] = Location(DXN, DYN)

    DTABLE[5] = Location(DXC, DYC)
    
    directions = {}
    dirsCount = 0
    if pattern == 1 then -- \
        directions = {4, 4, 7, 8, 9, 6, 3, 2, 1, 4}
    elseif pattern == 2 then -- |
        directions = {8, 8, 8, 6, 4, 2, 8, 8, 4, 6}
    elseif pattern == 3 then -- /
        directions = {4, 4, 1, 2, 3, 6, 9, 8, 7, 4}
    elseif pattern == 4 then -- -
        directions = {4, 4, 4, 8, 2, 8, 2, 8, 4, 4}
    elseif pattern == 5 then -- O
        directions = {4, 7, 8, 9, 6, 3, 2, 1, 6, 4}
    end
    
    if inverse == 1 then
        invDirs = {}
        for i,v in ipairs(directions) do
          invDirs[11 - i] = 10 - v
        end
        directions = invDirs
    end
    touchDown(DTABLE[5])
    for i, v in ipairs(directions) do
        touchMove(DTABLE[v])
    end
    touchUp(DTABLE[5])
end

-- ========== Dialogs ================

dialogInit()
FUNC=1
addRadioGroup("FUNC", 1)
    addRadioButton("刷土廟", 1)
    addRadioButton("自動點擊REPEAT", 2)
    addRadioButton("自動移動", 3)
    newRow()
BRIGHTNESS = false IMMERSIVE = true
addCheckBox("BRIGHTNESS", "螢幕亮度最低", true)newRow()
addCheckBox("IMMERSIVE", "Immersive", true)newRow()
addCheckBox("DEBUG", "Debug mode", true)newRow()
dialogShow("選擇自動化功能")

if BRIGHTNESS then
    setBrightness(0)
end
setImmersiveMode(IMMERSIVE)

if FUNC == 1 then
    dialogInit()
    CLEAR_LIMIT = 999                -- Step now
    addTextView("執行次數：")addEditNumber("CLEAR_LIMIT", 999)newRow()
    --addTextView("體力不足時等待 (分)：")addEditNumber("WAIT_TIME", 3)newRow()
    addTextView("選擇關卡：")newRow()
    addRadioGroup("QUEST", 1)addRadioButton("入口", 1)addRadioButton("最深處", 2)newRow()
    SCAN_INTERVAL = 2
    addTextView("掃描頻率：")addEditNumber("SCAN_INTERVAL", SCAN_INTERVAL)newRow()
    FRIEND = false
    addCheckBox("FRIEND", "選擇朋友", false)newRow()
    BUY = false
    addCheckBox("BUY", "使用寶石回復體力 ", false)addEditNumber("BUY_LOOP", 2)addTextView(" 回")newRow()
    if DEBUG then
        STEP = 1
        addTextView("Begin STEP")addEditNumber("STEP", 1)newRow()
    end
    dialogShow("Trust Master Maker".." - "..X.." × "..Y)
    setScanInterval(SCAN_INTERVAL)
elseif FUNC == 2 then
    REPEAT_COUNT = 4
    dialogInit()
    addTextView("Repeat次數：")addEditNumber("REPEAT_COUNT", 4)
    dialogShow("Auto Click Repeat")
    repeat
        if (R18_0711:existsClick("Repeat.png")) then
            REPEAT_COUNT = REPEAT_COUNT - 1
        end
        FINISH = REPEAT_COUNT == 0
    until FINISH
    scriptExit("Repeat finish")
elseif FUNC == 3 then

    dialogInit()
        MOVE_PATTERN = 1
        TIMEOUT_LIMIT = 5
        addTextView("第一場戰鬥請記得手動按Auto")newRow()
        addTextView("每隔120秒無戰鬥會振動, 每振動")addEditNumber("TIMEOUT_LIMIT", 5)
        addTextView("次會中止script")newRow()
        addRadioGroup("MOVE_PATTERN", 1)
            addRadioButton("\\", 1)
            addRadioButton("|", 2)
            addRadioButton("/", 3) newRow()

            addRadioButton("-", 4)
            addRadioButton("O", 5)
            addRadioButton("Rnd", 6) newRow()
    dialogShow("Auto move pattern")

	BattleIndicator = Region(0, 1350, 40, 1600)
	ResultIndicator = Region(380, 900, 600, 1030)
	LastBattle = Timer()
	setScanInterval(1)
	timeout = 0
	battleCount = 0
	repeat
		if (BattleIndicator:exists("Battle.png")) then
			toast("In Battle")
			repeat
				if (not BattleIndicator:exists("Battle.png")) then
    				ResultIndicator:existsClick("BattleFinishResult.png")
					LastBattle:set()
				    break
				end
			until false
			battleCount = battleCount + 1
			toast("Battle count: "..battleCount)
		end
		if LastBattle:check() > 120 then
		    -- Notify user should move to next area, and reset timer for next 120s
        	vibrate(2)
            LastBattle:set()
        	timeout = timeout + 1
        	print(timeout)
        	if timeout >= TIMEOUT_LIMIT then
        	    break
        	end
		end
		move(MOVE_PATTERN)
		
		FINISH = false
	until FINISH
	vibrate(2)
	wait(1)
	vibrate(2)
	
	scriptExit("Repeat walk finish")
end

-- ==========  main program ===========
if not DEBUG then
    STEP = 1
end
CLEAR = 0                -- Stage clear times
ON_AUTO = false
ERROR_COUNT = 0
TIMER = Timer()			-- Timer of loop
TIMER2 = Timer()		-- Timer of step

if (QUEST == 1) then
    QUEST_NAME= "01_The_Temple_of_Earth_Entry.png"
elseif (QUEST == 2) then
    QUEST_NAME=  "01_The_Temple_of_Earth_End.png"
else
    QUEST_NAME= "01_The_Temple_of_Earth_Entry.png"
end

if (FRIEND) then
    FRIEND_NAME = "02_Pick_up_friend.png";
else
    FRIEND_NAME = "02_No_friend.png";
end

switch = {
    [  1 ] = function()
        if (existsClick(QUEST_NAME)) then
            TIMER2:set()
            if (R34_1311:existsClick("06_Next.png")) then
                if (R14_0111:existsClick(FRIEND_NAME)) then
                    STEP = 2
                end
            else
                if (BUY and BUY_LOOP > 0 and R23_1111:existsClick("Use_Gem.png")) then
                    R24_1211:existsClick("Buy_Yes.png")
                    wait(5)
                    R34_1311:existsClick("06_Next.png")
                    wait(3)
                    R14_0111:existsClick(FRIEND_NAME)
                    STEP = 2

                    print("使用寶石回復體力")
                    BUY_LOOP = BUY_LOOP - 1
                elseif (R34_1211:existsClick("Stamina_Back.png")) then
                    toast('體力不足，等待中...')
                    setScanInterval(10)
                    wait(30)
                    setScanInterval(SCAN_INTERVAL)
                end
            end
        else
            toast('找不到關卡')
            existsClick("06_Next.png")
            existsClick("09_Return.png")
            STEP = 1
        end
    end,
    [ 2 ] = function()
        if (R34_1311:existsClick("03_Go.png")) then
            STEP = 3
        end
    end,
    [ 3 ] = function()
        if (ON_AUTO) then
            if (R34_1311:existsClick("06_Next1.png")) then
                ON_AUTO = false
                STEP = 4
                setScanInterval(SCAN_INTERVAL)
            end
        elseif (R28_0711:existsClick("04_Auto.png")) then
            ON_AUTO = true
            setScanInterval(10)
        end
    end,
    [ 4 ] = function()
        if (ResultExp:existsClick("07_Next_2.png")) then
            wait(0.5)
            click(getLastMatch())
            STEP = 5
        end
    end,
    [ 5 ] = function()
        -- Result Next is bigger than other next...
        wait(1)
        if (click(ResultItemNextLocation)) then
            if (FRIEND) then
                existsClick("08_No_Friend1.png", 5)
            end
            STEP = 1
            CLEAR = CLEAR + 1
        end
    end
}

TIMER:set()
repeat
    switch[STEP]()
    if DEBUG then
        toast("step"..STEP)
    end
    if (R13_0111:exists("Communication_Error.png")) then
        R13_0111:existsClick("OK.png")
    end
    FINISH = false
    if (CLEAR == CLEAR_LIMIT) then    -- Step repeat check
        FINISH = true
        print("Quest clear:"..CLEAR.."/"..CLEAR_LIMIT.."("..TIMER:check()..")")
    elseif (ERROR_COUNT == 5) then
        FINISH = true
        print("程式錯誤，腳本跳出")
        toast("程式錯誤，腳本跳出")
    else
        FINISH = false
        if (STEP == 1) then
            toast("Quest clear:"..CLEAR.."/"..CLEAR_LIMIT.."("..TIMER2:check()..")")
        end
    end
until FINISH
