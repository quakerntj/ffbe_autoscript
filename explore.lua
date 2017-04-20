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
        addRadioGroup("MOVE_PATTERN", 1)
            addRadioButton("\\", 1)
            addRadioButton("|", 2)
            addRadioButton("/", 3) newRow()

            addRadioButton("-", 4)
            addRadioButton("O", 5)
            addRadioButton("Rnd", 6) newRow()

        BATTLE_ABILITY = true
        addCheckBox("BATTLE_ABILITY", "戰鬥一開始使用技能一次", true) newRow()
        addTextView("沒有一回合殺, 下一回合的行動為") newRow()
        addRadioGroup("BATTLE_AUTO_OR_REPEAT", 1)
            addRadioButton("Auto", 1)
            addRadioButton("Repeat", 2)
    dialogShow("Auto move pattern")

    self.movePattern = MOVE_PATTERN
    self.timeOutLimit = TIMEOUT_LIMIT
	--setScanInterval(2)
	
	
    self.useAbility = BATTLE_ABILITY
    self.autoOrRepeat = BATTLE_AUTO_OR_REPEAT
	if self.useAbility then
    	self.db = DesignedBattle()
	    self.data = self.db:obtain(1)  -- a dialog to set ability when first time obtain.
    end

    if BRIGHTNESS then
        setBrightness(0)
    end
end

function Explorer:run()
	local LastBattle = Timer()
	local timeout = 0
	local battleCount = 0
	local isTouchDown = false
	local isAutoActivate = false
	repeat
	    -- TODO If enter door
		if (BattleIndicator:exists("Battle.png")) then
			toast("In Battle")
			if isTouchDown then
                touchUp(DTABLE[5], 0.2)
                isTouchDown = false
            end
            if not self.useAbility and self.db:hasRepeatButton() then
                isAutoActivate = self.db:clickAuto()
	        end

            local battleRound = 0
			repeat
	            if DEBUG then BattleIndicator:highlight(0.2) end
				if BattleIndicator:exists("Battle.png") then
			        if self.useAbility and self.db:hasRepeatButton() then
        			    battleRound = battleRound + 1
        			    if battleRound > 1 then
        			        if self.autoOrRepeat == 1 then
                                self.db:triggerAuto()
                            else
                                self.db:triggerRepeat()
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
        			toast("Battle count: "..battleCount)
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

		local r, g, b = getColor(DTABLE[5])
        if not isTouchDown or (r+g+b) < 600 then
            touchDown(DTABLE[5], 0.2)
            isTouchDown = true
        end
		self:move(self.movePattern)
		FINISH = false
	until FINISH
	vibratePattern()
	scriptExit("Auto move finish")
end



function Explorer:move(pattern)
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

