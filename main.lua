-- Copyright © 2017 Quaker NTj <quakerntj@hotmail.com>

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
    local UnitTargets = { "1", "2", "3", "4", "5", "6", "All" }

    dialogInit()
        addTextView("順序小的先發動, 相同的就按兵員順序")newRow()
        addTextView("選擇是否為敵方, 若是己方則選擇治療目標")newRow()
        addTextView("敵方不支援指定目標, 選什麼都無效")newRow()
        addTextView("沒有打勾的兵員最後會被Auto觸發")newRow()
        -- addSpinnerIndex and addSpinner accept only global variable
        for i = 1, 6 do
            addTextView("兵員"..i.." 順序")addSpinnerIndex("unitOrder"..i, UnitOrders, UnitOrders[3])
            addCheckBox("unitIsEnemy"..i, "敵方?", true)addTextView("目標")
            addSpinnerIndex("unitTarget"..i, UnitTargets, 7)newRow()
        end
    dialogShow("Setting Actions 2")

    local orders = { unitOrder1, unitOrder2, unitOrder3, unitOrder4, unitOrder5, unitOrder6 }
    local isEnemys = { unitIsEnemy1, unitIsEnemy2, unitIsEnemy3, unitIsEnemy4, unitIsEnemy5, unitIsEnemy6 }
    local targets = { unitTarget1, unitTarget2, unitTarget3, unitTarget4, unitTarget5, unitTarget6 }

    -- clean used global variable
    for i = 1, 6 do
        _G["unitOrder"..i] = nil
        _G["unitIsEnemy"..i] = nil
        _G["unitTarget"..i] = nil
    end

    return orders, isEnemys, targets
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
    dialogShow("Setting Actions 1")

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
    
    BTL_INTERACTION = true
    local enables, actions, indices = chooseActions()
    local orders, isEnemys, targets = chooseOrders()
    scene = BattleScene()

while true do
    for unit = 1, 6 do
        if enables[unit] then
            local action = actions[unit]
            -- ignore action == 1
            if action == 2 then
                scene.units[unit]:abilityPage()
                wait(0.5)
                if scene.page:choose(indices[unit]) then
                    wait(1)
                    if (isEnemys[unit] and (targets[unit] == 7)) then
                        -- Do nothing
                    elseif (isEnemys[unit] and (not (targets[unit] == 7))) then
                        -- TODO Not support attack specified target now...
                    elseif ((not isEnemys[unit]) and (targets[unit] == 7)) then
                        scene.units[1]:submit()
                        wait(0.5)
                    elseif (not isEnemys[unit]) then
                        scene.units[targets[unit]]:submit()
                        wait(0.5)
                    end
                else
                    -- click right-bottom return
                end
            elseif action == 3 then
                scene.units[unit]:itemPage()
                wait(0.5)
                if scene.page:choose(indices[unit]) then
                    wait(1)
                    if (isEnemys[unit] and (targets[unit] == 7)) then
                        -- Do nothing
                    elseif (isEnemys[unit] and (not (targets[unit] == 7))) then
                        -- TODO Not support attack specified target now...
                    elseif ((not isEnemys[unit]) and (targets[unit] == 7)) then
                        scene.units[1]:submit()
                        wait(0.5)
                    elseif (not isEnemys[unit]) then
                        scene.units[targets[unit]]:submit()
                        wait(0.5)
                    end
                else
                    -- click right-bottom return
                end
            elseif action == 4 then
                scene.units[unit]:defence()
                wait(0.5)
            end
            wait(0.1)
        end
    end
    
    -- sort unit by orders, and submit
    for i = 1, 6 do
        local keys = {}
        keys = hasValue(orders, i)
        for j,unit in ipairs(keys) do
            if enables[unit] then
                scene.units[unit]:submit()
            end
        end
    end
    
    if (R28_0711:existsClick("04_Auto.png")) then
        wait(2)
        click(getLastMatch())  -- cancel auto
    end
    
    if BTL_INTERACTION then
        dialogInit()
            addTextView("行動, 請等到有行動力之後再按確認")newRow()
            addRadioGroup("NEXT_ACTION", 1)
                addRadioButton("Repeat", 1)
                addRadioButton("Auto", 2)
        dialogShow("Auto move pattern")
    end
end
end

