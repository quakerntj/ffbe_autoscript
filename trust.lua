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

TrustManager = {}
TrustManager.__index = TrustManager

setmetatable(TrustManager, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function TrustManager.new()
	local self = setmetatable({}, TrustManager)
	self.errorCount = 0
	self.clearLimit = 999
	self.highlightTime = 0.7
	self.watchdog = WatchDog(15, self, self['dogBarking'])
	self.debug = false
	self.useAbility = false
	self.battleRound = 0

	self.initlaState = 2  -- States index
	self.state = "ChooseLevel"
	self.States = {
		"ChooseStage",
		"ChooseLevel",
		"Challenge",
		"ChooseFriend",
		"Go",
		"IsInBattle",
		"Battle",
		"ResultGil",
		"ResultExp",
		"ResultItem",
		"Clear"
	}
	self.switch = {}

	self:init()
	return self
end

function TrustManager:init()
    local QuestList = { "1", "2", "3", "4", "5" }
    QUEST = 1
	dialogInit()
	CLEAR_LIMIT = 999
	addTextView("執行次數：")addEditNumber("CLEAR_LIMIT", 999)newRow()
	--addTextView("體力不足時等待 (分)：")addEditNumber("WAIT_TIME", 3)newRow()
	addTextView("選擇關卡：")addSpinnerIndex("QUEST", QuestList, 6)newRow()
	SCAN_INTERVAL = 2
	addTextView("掃描頻率：")addEditNumber("SCAN_INTERVAL", SCAN_INTERVAL)newRow()
	FRIEND = false
	addCheckBox("FRIEND", "選擇朋友", false)newRow()
	BUY = false
	addCheckBox("BUY", "使用寶石回復體力 ", false)addEditNumber("BUY_LOOP", 2)addTextView(" 回")newRow()
	BATTLE_ABILITY = false
	addCheckBox("BATTLE_ABILITY", "戰鬥第一回合開始使用技能, 之後Repeat", false) newRow()
	if DEBUG then
		STATE = 2
		HIGHLIGHT_TIME = 0.7
		addTextView("Begin STATE")addEditNumber("STATE", 2)newRow()
		addTextView("Highlight time")addEditNumber("HIGHLIGHT_TIME", 0.7)newRow()
	end
	dialogShow("Trust Master Maker".." - "..X.." × "..Y)
	proSetScanInterval(SCAN_INTERVAL)
	self.quest = QUEST
	self.clearLimit = CLEAR_LIMIT
	
	self.useAbility = BATTLE_ABILITY
    if self.useAbility then
    	self.db = DesignedBattle()
	    self.data = self.db:obtain(1)  -- a dialog to set ability when first time obtain.
    end
	
	if BRIGHTNESS then
		proSetBrightness(0)
	end
	
	if DEBUG then
		self.highlightTime = HIGHLIGHT_TIME
		self.initlaState = STATE
	end
	
	self.debug = DEBUG
end

function hasQuest(isDungeon, idx)
	local icon
	if isDungeon then
		icon = "DungeonQuestIcon.png"
	else
		icon = "ExplorationQuestIcon.png"
	end

	if DEBUG then QuestIconRegion:highlight(0.3) end
	local list = regionFindAllNoFindException(QuestIconRegion, icon)

	-- Show icons according to ascending y value
	for i, v in ipairs(list) do
		return true
	end
	return false
end

function TrustManager:looper()
	if not DEBUG then self.initlaState = 2 end
	ON_AUTO = false  -- this must be global
	local watchdog = self.watchdog

	--local ResultNext = Region(600, 2200, 240, 100)
	local ResultItemNextLocation = Location(720, 2250)

	local friendChoice1 = ""
	local friendChoice2 = ""
	if (FRIEND) then
		friendChoice1 = "02_Pick_up_friend.png"
		friendChoice2 = "02_No_friend.png"
	else
		friendChoice2 = "02_Pick_up_friend.png"
		friendChoice1 = "02_No_friend.png"
	end

	self.switch = {
		["ChooseStage"] = function()
			if existsClick("TheTempleofEarthMapIcon.png") then
				return "ChooseLevel"
			end
			return "ChooseStage"
		end,
		
		["ChooseLevel"] = function()
			if hasQuest(true, self.quest) then
				click(QuestLocations[self.quest])
				return "Challenge"
			end
--			if DEBUG then R24_0113:highlight(self.highlightTime) end
--			if (R24_0113:existsClick(QUEST_NAME)) then
--				return "Challenge"
--			end
			return "ChooseLevel"
		end,
		["Challenge"] = function(watchdog)
			if DEBUG then R34_1311:highlight(self.highlightTime) end
			if (R34_1311:existsClick("06_Next.png")) then
				wait(0.8)
				return "ChooseFriend"
			elseif (BUY and BUY_LOOP > 0 and R23_1111:existsClick("Use_Gem.png")) then
				wait(1)
				R24_1211:existsClick("Buy_Yes.png")
				print("使用寶石回復體力")
				wait(5)
				BUY_LOOP = BUY_LOOP - 1
			elseif (R34_1211:existsClick("Stamina_Back.png")) then
				toast('體力不足，等待中...')
				proSetScanInterval(10)
				wait(30)
				proSetScanInterval(SCAN_INTERVAL)
				return "ChooseLevel"
			end
			return "Challenge"
		end,
		["ChooseFriend"] = function()
			if DEBUG then R34_1111:highlight(self.highlightTime) end
			if (R34_1111:existsClick(friendChoice1)) then
				return "Go"
			elseif (R34_1111:existsClick(friendChoice2)) then
				return "Go"
			end
			return "ChooseFriend"
		end,
		["Go"] = function()
			if DEBUG then R34_1311:highlight(self.highlightTime) end
			if (R34_1311:existsClick("03_Go.png")) then
				return "IsInBattle"
			end
			return "Go"
		end,

		["IsInBattle"] = function()
			-- Make sure we are in battle.
			if DEBUG then BattleIndicator:highlight(self.highlightTime) end
			if BattleIndicator:exists("Battle.png") then
				ON_AUTO = false
				return "Battle"
			end
			if DEBUG then FriendChange:highlight(self.highlightTime) end
			if FriendChange:exists("FriendChange.png") then
				if DEBUG then FriendChangeOK:highlight(self.highlightTime) end
				if FriendChangeOK:existsClick("OK.png") then
					return "ChooseFriend"
				end
			end
			return "IsInBattle"
		end,
		
		["Battle"] = function(watchdog, trust)
			if DEBUG then BattleIndicator:highlight(self.highlightTime) end
			local inBattle = (BattleIndicator:exists("Battle.png") ~= nil)
			if inBattle then
				if trust.useAbility then
				    if trust.db:hasRepeatButton() then
					ON_AUTO = true  -- means not need click auto button
    	    		trust.battleRound = trust.battleRound + 1
        		    if trust.battleRound > 1 then
                        trust.db:triggerRepeat()
                	else    			   
        	        	trust.db:run(trust.data)
  	    	  	    end
  	    	  	 end
		        elseif (not ON_AUTO and R28_0711:existsClick("04_Auto.png")) then
					if DEBUG then R28_0711:highlight(self.highlightTime) end
					ON_AUTO = true
					proSetScanInterval(10)
				end
		    elseif (ON_AUTO and (not inBattle)) then
				trust.battleRound = 0
				ON_AUTO = false
				proSetScanInterval(SCAN_INTERVAL)
				return "ResultGil"
			end
			if (inBattle and (watchdog ~= nil)) then
				watchdog:touch()
			end
			return "Battle"
		end,

		["ResultGil"] = function()
			-- click "GIL" icon for speed up and skip rank up
			if DEBUG then ResultGil:highlight(self.highlightTime) end
			ResultGil:existsClick("ResultGil.png")
			if DEBUG then R34_1311:highlight(self.highlightTime) end
			if R34_1311:existsClick("06_Next1.png") then
				return "ResultExp"
			end
			return "ResultGil"
		end,
		
		["ResultExp"] = function()
			-- may have level up and trust up at the same time. click twice.
			if DEBUG then ResultExp:highlight(self.highlightTime) end
			if (ResultExp:existsClick("ResultExp.png")) then
				wait(0.2)
				click(ResultExp:getLastMatch())
				return "ResultItem"
			end
			return "ResultExp"
		end,
		["ResultItem"] = function()
			wait(1)
			local l = Location(X12, Y12)
			click(l) -- speed up showing items
			wait(0.5)
			-- Result Next is bigger than other next...
			if DEBUG then R34_1311:highlight(self.highlightTime) end
			if R34_1311:existsClick("Result_Next.png", 4) then
			--if (click(ResultItemNextLocation)) then
				if (FRIEND) then
					-- Not to add new friend
					if DEBUG then R25_0311:highlight(self.highlightTime) end
					R25_0311:existsClick("NotApplyNewFriend.png", 5)
				end
				return "Clear"
			end
			return "ResultItem"
		end
	}

	self.totalTimer = Timer()
	local questTimer = Timer()
	self.totalTimer:set()
	questTimer:set()
	local pause = false
	
	self.loopCount = 0
	self.state = self.States[self.initlaState]

	while self.loopCount < self.clearLimit do

		if DEBUG then toast(self.state) end

		-- run state machine
		newState = self.switch[self.state](watchdog, self)
		if newState ~= self.state then
			self.state = newState
			watchdog:touch()
		end
		watchdog:awake()
		
		if (self.state == "Clear") then
			self.state = "ChooseLevel"
			self.loopCount = self.loopCount + 1
			local msg = "Quest clear:"..self.loopCount.."/"..self.clearLimit.."("..questTimer:check().."s)"
			toast(msg)
			setStopMessage(msg)
			questTimer:set()
			self.errorCount = 0
			
			-- The debug mode may be opened due to error.  Close it when the error pass.
			if not self.debug then
				DEBUG = false
			end
		end
	end
	print("Quest clear:"..self.loopCount.."/"..self.clearLimit.."("..self.totalTimer:check().."s)")
end

function TrustManager.dogBarking(self, watchdog)
	local friendChoice1 = "02_Pick_up_friend.png"
	local friendChoice2 = "02_No_friend.png"

	if DEBUG then toast("Watchdog barking") end
	if (R13_0111:exists("Communication_Error.png")) then
		R33_1111:existsClick("OK.png")
	elseif CloseAndGoTo:exists("GoTo.png") then
		-- If you finish 3 battle after daily timer reset, a dialog will popup.
		CloseAndGoTo:existsClick("Close.png")
		self.state = "ChooseStage"
	elseif R33_1111:existsClick("OK.png") then
		print("try click an OK")
	elseif R34_1311:exists("03_Go.png") then
		self.state = "Go"
	elseif BattleIndicator:exists("Battle.png") then
		self.state = "Battle"
	elseif ResultGil:exists("ResultGil.png") then
		self.state = "ResultGil"
	elseif ResultExp:exists("ResultExp.png") then
		self.state = "ResultExp"
--	elseif R24_0113:exists(QUEST_NAME) then
--		self.state = "ChooseLevel"
	elseif hasQuest(true, self.quest) then
		self.state = "ChooseLevel"
	elseif (R34_1111:exists(friendChoice1)) or (R34_1111:exists(friendChoice2)) then
		self.state = "ChooseFriend"
	elseif R34_1311:existsClick("06_Next1.png") then -- if has next, click it.
		print("try click a next")
	elseif R34_1311:existsClick("06_Next.png") then -- if has next, click it.
		print("try click a next")
	elseif R34_1311:existsClick("Result_Next.png") then -- if has next, click it.
		print("try click a next")
	elseif R34_0011:exists("LeftTop_Return.png") then
		-- keep return until ChooseStage.  Put this check at final.
		self.state = "ChooseStage"
	else
		self.errorCount = self.errorCount + 1
		if self.errorCount > 3 then
			print("Error can't be handled. Stop Script.")
			print("Quest clear:"..self.loopCount.."/"..self.clearLimit.."("..self.totalTimer:check().."s)")
			vibratePattern()
			scriptExit("Trust Manger finished")
			return
		else
			print("Error count: " ..self.errorCount)
			toast("Error count: " ..self.errorCount)
			DEBUG = true
			vibratePattern()
			-- not to touch dog when error
			return
		end
	end
end
