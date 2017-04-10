-- Edit by Quaker NTj
WORK_DIR = scriptPath()
package.path = package.path .. ";" .. WORK_DIR .. '?.lua'

-- ========== Initial Settings ================
Settings:setCompareDimension(true, 1440)--執行圖形比對時螢度的解析度。根據compareByWidth的值的值設定成寬度或高度
Settings:setScriptDimension(true, 1440)--用於參考App解析度腳本內座標位置
Settings:set("MinSimilarity", 0.85)

setDragDropTiming(200, 200)			--downMs: 開始移動前壓住不動幾毫秒	upMs: 最後放開前停住幾毫秒
setDragDropStepCount(3)				--stepCount: 從啟始點到目的地分幾步移動完
setDragDropStepInterval(100)	--intervalMs: 每次移動間停留幾毫秒

screen = getAppUsableScreenSize()
X = screen:getX()
Y = 2560 --screen:getY() will not get right full screen size.
DEBUG = true

require("screen_config")
require("trust")

ScrollRegion = Region(1410, 1592, 1430, 2296)


BIL = {  -- Battle item location
    Location(360, 1700),  -- Unit 1
    Location(360, 1960),  -- Unit 2
    Location(360, 2200),  -- Unit 3
    Location(1080, 1700), -- Unit 4
    Location(1080, 1960), -- Unit 5
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

    directions = {}
    dirsCount = 0
    if pattern == 1 then -- \
        directions = {7, 7, 7, 3, 7, 7, 3, 7, 7, 7}
    elseif pattern == 2 then -- |
        directions = {8, 8, 8, 2, 8, 8, 2, 8, 8, 8}
    elseif pattern == 3 then -- /
        directions = {9, 9, 9, 1, 9, 9, 1, 9, 9, 9}
    elseif pattern == 4 then -- -
        directions = {4, 6, 4, 6, 4, 6, 4, 6, 4, 6}
    elseif pattern == 5 then -- O
        directions = {4, 7, 8, 9, 6, 3, 2, 1, 4, 6}
    end
    
    if inverse == 1 then
        invDirs = {}
        for i,v in ipairs(directions) do
          invDirs[11 - i] = 10 - v
        end
        directions = invDirs
    end
    
    for i, v in ipairs(directions) do
        touchMove(DTABLE[v], 1)
    end
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
    
    trust()
    scriptExit("Trust finish")
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
        addTextView("請設定為滑動移動而不是螢幕搖桿")newRow()
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
	isTouchDown = false
	repeat
	    -- TODO If enter door
		if (BattleIndicator:exists("Battle.png")) then
			toast("In Battle")
			if isTouchDown then
                touchUp(DTABLE[5], 0.2)
                isTouchDown = false
            end
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
        	print("Timeout"..timeout)
        	if timeout >= TIMEOUT_LIMIT then
        	    break
        	end
		end
        if not isTouchDown then
            touchDown(DTABLE[5], 0.2)
            isTouchDown = true
        end
		move(MOVE_PATTERN)
		FINISH = false
	until FINISH
	vibrate(2)
	wait(1)
	vibrate(2)
	
	scriptExit("Auto move finish")
end

