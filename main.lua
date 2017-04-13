-- Edit by Quaker NTj
WORK_DIR = scriptPath()
package.path = package.path .. ";" .. WORK_DIR .. '?.lua'

-- ========== Initial Settings ================
Settings:setCompareDimension(true, 1440)--執行圖形比對時螢度的解析度。根據compareByWidth的值的值設定成寬度或高度
Settings:setScriptDimension(true, 1440)--用於參考App解析度腳本內座標位置
Settings:set("MinSimilarity", 0.85)

setDragDropTiming(350, 350)	--downMs: 開始移動前壓住不動幾毫秒	upMs: 最後放開前停住幾毫秒
setDragDropStepCount(25)	--stepCount: 從啟始點到目的地分幾步移動完
setDragDropStepInterval(16)	--intervalMs: 每次移動間停留幾毫秒

screen = getAppUsableScreenSize()
X = screen:getX()
Y = 2560 --screen:getY() will not get right full screen size.
DEBUG = true

require("screen_config")
require("battle_scene")
require("trust")

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

function chooseOrders()
    local UnitOrders = { "1", "2", "3", "4", "5", "6" }
    local UnitOffsets = { "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1" }
    
    dialogInit()
        addTextView("順序小的先發動, 相同的就按兵員順序")newRow()
        addTextView("可調整距離上一個兵員發動的時間間隔")newRow()
        addTextView("沒有打勾的兵員最後會被Auto觸發")newRow()
        -- addSpinnerIndex and addSpinner accept only global variable
        for i = 1, 6 do
            addTextView("兵員"..i.." 順序")addSpinnerIndex("unitOrder"..i, UnitOrders, UnitOrders[3])
            addTextView("間隔")addSpinnerIndex("unitOffset"..i, UnitOffsets, 1)newRow()
        end
    dialogShow("Setting Actions")

    local orders = { unitOrder1, unitOrder2, unitOrder3, unitOrder4, unitOrder5, unitOrder6 }
    local offsets = { unitOffset1, unitOffset2, unitOffset3, unitOffset4, unitOffset5, unitOffset6 }

    -- clean used global variable
    for i = 1, 6 do
        _G["unitOrder"..i] = nil
        _G["unitOffset"..i] = nil
    end

    return orders, offsets
end

function chooseActions()
    local UnitActions = { "攻擊", "能力", "道具", "防禦" }
    dialogInit()
        addTextView("輸入技能與道具的'欄位'自左向右, 然後換行, 由1開始, 1是極限技")newRow()
        addTextView("目前道具只能用在自己身上")newRow()
        for i = 1, 6 do
            addCheckBox("unitEnable"..i, "兵員"..i, true)
            addTextView("行動")addSpinnerIndex("unitAction"..i, UnitActions, 1)
            addTextView("欄位")addEditNumber("unitIndex"..i, 1)newRow()
        end
    dialogShow("Setting Actions")

    -- fill tables.
    local enables = { unitEnable1, unitEnable2, unitEnable3, unitEnable4, unitEnable5, unitEnable6 }
    local actions = { unitAction1, unitAction2, unitAction3, unitAction4, unitAction5, unitAction6 }
    local indices = { unitIndex1, unitIndex2, unitIndex3, unitIndex4, unitIndex5, unitIndex6 }

    for i = 1, 6 do
        _G["unitEnable"..i] = nil
        _G["unitAction"..i] = nil
        _G["unitIndex"..i] = nil
    end
    return enables, actions, indices
end

-- ========== Dialogs ================

dialogInit()
FUNC=1
addRadioGroup("FUNC", 1)
    addRadioButton("刷土廟", 1)
    addRadioButton("自動點擊REPEAT", 2)
    addRadioButton("自動移動", 3)
    if DEBUG then
        addRadioButton("測試", 4)
    end
    newRow()
BRIGHTNESS = false IMMERSIVE = true
addCheckBox("BRIGHTNESS", "螢幕亮度最低", true)newRow()
addCheckBox("IMMERSIVE", "Immersive", true)newRow()
addCheckBox("DEBUG", "Debug mode", true)newRow()
dialogShow("選擇自動化功能")

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
    
    if BRIGHTNESS then
        setBrightness(0)
    end
    trust = TrustManager()
    trust:Looper()
    scriptExit("Trust finish")
elseif FUNC == 2 then
    REPEAT_COUNT = 4
    dialogInit()
    addTextView("Repeat次數：")addEditNumber("REPEAT_COUNT", 4)
    dialogShow("Auto Click Repeat")

    if BRIGHTNESS then
        setBrightness(0)
    end

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

    if BRIGHTNESS then
        setBrightness(0)
    end

	local BattleIndicator = Region(0, 1350, 40, 250)
	local ResultIndicator = Region(380, 900, 220, 130)
	local LastBattle = Timer()
	setScanInterval(1)
	local timeout = 0
	local battleCount = 0
	local isTouchDown = false
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
--elseif FUNC == 4 then
--    scene = BattleScene()
--    scene.page:pageUp(1)
elseif FUNC == 4 then
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
    
    local enables, actions, indices = chooseActions()
    local orders, offsets = chooseOrders()
    scene = BattleScene()

    for unit = 1, 6 do
        if enables[unit] then
            local action = actions[unit]
            -- ignore action == 1
            if action == 2 then
                scene.units[unit]:abilityPage()
                wait(0.2)
                if not scene.page:choose(indices[unit]) then
                    -- click right-bottom return
                end
                wait(0.3)
            elseif action == 3 then
                scene.units[unit]:abilityPage()
                wait(0.2)
                if not scene.page:choose(indices[unit]) then
                    -- click right-bottom return
                end
                wait(0.3)
            elseif action == 4 then
                scene.units[unit]:defence()
                wait(0.2)
                --scene.units[3]:submit()
                wait(0.3)
            end
        end
    end
    
    -- sort unit by orders
    for i = 1, 6 do
        local keys = {}
        keys = hasValue(orders, i)
        for j,unit in ipairs(keys) do
            scene.units[unit]:submit()
        end
    end
    
end

