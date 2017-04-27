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

Explorer = {}
Explorer.__index = Explorer

setmetatable(Explorer, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Explorer.new()
	local self = setmetatable({}, Explorer)
	self:init()
	return self
end

function Explorer:init()
	dialogInit()
		MOVE_PATTERN = 1
		TIMEOUT_LIMIT = 5
		addTextView("請設定為滑動移動而不是螢幕搖桿")newRow()
		addTextView("每隔120秒無戰鬥會振動, 每振動")addEditNumber("TIMEOUT_LIMIT", 5)
		addTextView("次會中止script")newRow()
		addTextView("移動方向:")newRow()
		addRadioGroup("MOVE_PATTERN", 1)
			addRadioButton("\\ 左上右下", 1)
			addRadioButton("| 上下", 2)
			addRadioButton("/ 左下右上", 3)
			addRadioButton("- 左右", 4)
			addRadioButton("O 繞圈", 5)
			addRadioButton("R 隨機", 6) newRow()

		BATTLE_ABILITY = true
		addCheckBox("BATTLE_ABILITY", "戰鬥一開始使用技能一次", true) newRow()
		addTextView("使用技能後, 若沒有一回合殺, 下一回合的行動為") newRow()
		addRadioGroup("BATTLE_AUTO_OR_REPEAT", 1)
			addRadioButton("Auto", 1)
			addRadioButton("Repeat", 2)
    dialogShow("Auto Exploration")

	self.movePattern = MOVE_PATTERN
	self.timeOutLimit = TIMEOUT_LIMIT
	--proSetScanInterval(2)
	
	
	self.useAbility = BATTLE_ABILITY
	self.autoOrRepeat = BATTLE_AUTO_OR_REPEAT
	if self.useAbility then
		self.db = DesignedBattle()
		self.data = self.db:obtain(1)  -- a dialog to set ability when first time obtain.
	end

	if BRIGHTNESS then
		proSetBrightness(0)
	end
end

function Explorer:run()
	math.randomseed(os.time())
	local LastBattle = Timer()
	local timeout = 0
	local battleCount = 0
	local isTouchDown = false
	local isAutoActivate = false
	repeat
		-- TODO If enter door
		if (BattleIndicator:exists("Battle.png")) then
			toast("In Battle")
			if not self.useAbility and DesignedBattle.hasRepeatButton() then
				isAutoActivate = DesignedBattle.clickAuto()
			end

			local battleRound = 0
			repeat
				if DEBUG then BattleIndicator:highlight(0.2) end
				if BattleIndicator:exists("Battle.png") then
					if self.useAbility and DesignedBattle.hasRepeatButton() then
						battleRound = battleRound + 1
						if battleRound > 1 then
							if self.autoOrRepeat == 1 then
								DesignedBattle.triggerAuto()
							else
								DesignedBattle.triggerRepeat()
							end
						else					
							self.db:run(self.data)
						end
					end
				else
					if DEBUG then R23_0111:highlight(0.2) end
					repeat until R23_0111:exists("ResultGil.png")
					repeat
						wait(0.5)
						click(R23_0111:getLastMatch())
					until not R23_0111:exists("ResultGil.png")
					LastBattle:set()
					
					battleCount = battleCount + 1
					local msg = "Battle count: "..battleCount
					toast(msg)
					setStopMessage(msg)
					break
				end
			until false
		end
		if LastBattle:check() > 120 then
			-- Notify user should move to next area, and reset timer for next 120s
			vibratePattern()
			LastBattle:set()
			timeout = timeout + 1
			print("Timeout"..timeout)
			if timeout >= self.timeOutLimit then
				break
			end
		end

		self:move(self.movePattern)
		FINISH = false
	until FINISH
	vibratePattern()
	scriptExit("Auto exploration finish")
end

function Explorer:move(pattern)
	math.randomseed(os.time())
	local inverse = math.random(1,20) % 2

	local directions = {}
	local dirsCount = 0
	if pattern == 1 then -- \
		directions = {5, 7, 3, 7, 4, 7, 7, 7, 3, 7, 3, 5}
	elseif pattern == 2 then -- |
		directions = {5, 8, 2, 8, 2, 8, 8, 8, 2, 8, 2, 5}
	elseif pattern == 3 then -- /
		directions = {5, 9, 1, 9, 1, 9, 9, 9, 1, 9, 1, 5}
	elseif pattern == 4 then -- -
		directions = {5, 4, 6, 4, 6, 4, 4, 4, 6, 4, 6, 5}
	elseif pattern == 5 then -- O
		local startDir = math.random(1, 4) + inverse * 5
		directions = {5, startDir, 4, 1, 2, 3, 6, 9, 8, 7, startDir, 5}
	elseif pattern == 6 then -- Random
		directions = {
			5,
			math.random(1, 4),
			math.random(1, 4),
			math.random(6, 9),
			math.random(1, 4),
			math.random(6, 9),
			math.random(6, 9),
			math.random(1, 4),
			math.random(6, 9),
			math.random(1, 4),
			math.random(6, 9),
			5
		}
	end
	
	if inverse == 1 then
		invDirs = {}
		for i,v in ipairs(directions) do
		  invDirs[13 - i] = 10 - v
		end
		directions = invDirs
	end
	
	local touchList = {}
	local touchIdx = 1
    touchList[touchIdx] = {action = "touchDown", target = DTABLE[directions[1]]}
    touchIdx = touchIdx + 1
    touchList[touchIdx] = {action = "wait", target = 0.2}
    touchIdx = touchIdx + 1
	for i = 2, 11 do
		touchList[touchIdx] = {action = "touchMove", target = DTABLE[directions[i]]}
	    touchIdx = touchIdx + 1
		touchList[touchIdx] = {action = "wait", target = 0.4}
	    touchIdx = touchIdx + 1
	end
    touchList[touchIdx] = {action = "touchUp", target = DTABLE[directions[12]]}
    manualTouch(touchList)
end

