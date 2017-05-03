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

Farmer = {}
Farmer.__index = Farmer

setmetatable(Farmer, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Farmer.new()
	local self = setmetatable({}, Farmer)
	self.errorCount = 0
	self.clearLimit = 999
	self.highlightTime = 0.7
	self.watchdog = WatchDog(15, self, self['dogBarking'])
	self.debug = false
	self.useAbility = false
	self.battleRound = 0
	self.friend = true
	self.giveup = false
	self.giveupCount = 0
	self.giveupCountLimit = 3
	self.autoPressed = false
	self.paused = false

	self.initlaState = "ChooseLevel"
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

function Farmer:init()
	local QuestList = { "1", "2", "3", "4", "5" }
	local DBScriptList = { "quest1.dbs", "quest2.dbs", "quest3.dbs", "quest4.dbs", "quest5.dbs" }
	local BuyLoop = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20" }
	QUEST = 1
	dialogInit()
	CLEAR_LIMIT = 999
	addTextView("執行次數：")addEditNumber("CLEAR_LIMIT", 999)newRow()
	--addTextView("體力不足時等待 (分)：")addEditNumber("WAIT_TIME", 3)newRow()
	addTextView("選擇關卡：")addSpinnerIndex("QUEST", QuestList, 5)newRow()
	SCAN_INTERVAL = 2
if DEBUG then
	addTextView("掃描頻率：")addEditNumber("SCAN_INTERVAL", SCAN_INTERVAL)newRow()
end
	BUY = false
	addCheckBox("BUY", "使用寶石回復體力 ", false)addSpinnerIndex("BUY_LOOP", BuyLoop, 5)addTextView(" 回")newRow()
	BATTLE_ABILITY = false
	BATTLE_DBS = false
	addCheckBox("BATTLE_ABILITY", "使用技能", false)addSpinner("BATTLE_DBS", DBScriptList, DBScriptList[1])newRow()
	STATE = "ChooseLevel"
	addTextView("Begin STATE")addSpinner("STATE", self.States, 2)newRow()
	if DEBUG then
		HIGHLIGHT_TIME = 0.7
		addTextView("Highlight time")addEditNumber("HIGHLIGHT_TIME", 0.7)newRow()
	end
	dialogShow("Quest Farmer ".." - "..X.." × "..Y)
	proSetScanInterval(SCAN_INTERVAL)
	self.quest = QUEST
	self.clearLimit = CLEAR_LIMIT
	self.initlaState = STATE

	self.useAbility = BATTLE_ABILITY
	if self.useAbility then
		self.db = DesignedBattle()
		local f = io.open(WORK_DIR .. BATTLE_DBS, "r")
		self.dbScript = f:read("*all")
		f:close()
		self.db:decode(self.dbScript)
--		self.data = self.db:obtain(20)  -- a dialog to set ability when first time obtain.
	end

	if BRIGHTNESS then
		proSetBrightness(0)
	end

	if DEBUG then
		self.highlightTime = HIGHLIGHT_TIME
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

function isGameOver(inBattle)
	-- Handle Game Over Dialog
	if not inBattle then return false end
	local r,g,b = getColor(inBattle)  -- getColor has good performance.
	if (r + g + b) < 300 then -- normal should be 600+
		if R38_1111:exists("RaiseAllDialog.png") then
			R25_0211:click("NotToRaiseAll.png")
			R38_1211:exists("GiveUpDialog.png")
			R25_1211:click("YesToGiveUp.png")
			return true
		end
	end
	return false
end

function Farmer:looper()
	local watchdog = self.watchdog

	--local ResultNext = Region(600, 2200, 240, 100)
	local ResultItemNextLocation = Location(720, 2250)

	local friendChoice1 = "PickupFriend.png"
	local friendChoice2 = "NoFriend.png"

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
			if (R34_1311:existsClick("Next.png")) then
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
			 self.friend = true
				return "Go"
			elseif (R34_1111:existsClick(friendChoice2)) then
			 self.friend = false
				return "Go"
			end
			return "ChooseFriend"
		end,
		["Go"] = function()
			if DEBUG then R34_1311:highlight(self.highlightTime) end
			if (R34_1311:existsClick("Go.png")) then
				return "IsInBattle"
			end
			return "Go"
		end,

		["IsInBattle"] = function()
			-- Make sure we are in battle.
			if DEBUG then BattleIndicator:highlight(self.highlightTime) end
			if BattleIndicator:exists("Battle.png") then
				self.autoPressed = false
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

		["Battle"] = function(watchdog, farmer)
			if DEBUG then BattleIndicator:highlight(self.highlightTime) end
			if self.paused then
				local battleReturn = R48_3611:exists("BattleReturn.png")
				if battleReturn then
 		   			click(battleReturn)
					self.paused = false
	 		   		watchdog:enable(true)
 		   			toast("resume")
	   			else
			   		wait(15)
					proVibrate(1)
					toast("Still paused.  Go to menu to continue.")
					return "Battle"
				end
			end

			local inBattle = BattleIndicator:exists("Battle.png")

			-- handle GameOver
			if isGameOver(inBattle) then
				farmer.battleRound = 0
				self.autoPressed = false
				self.giveup = true
				self.giveupCount = self.giveupCount + 1
				print("GameOver " .. self.giveupCount .. " times.")
				if self.giveupCount == self.giveupCountLimit then
				    scriptExit("GameOver too many times")
				end
				return "ResultGil"
			end

			if inBattle then
				if farmer.useAbility then
					if DesignedBattle.hasRepeatButton() then
                        farmer.db:runScript(farmer.battleRound)

						farmer.battleRound = farmer.battleRound + 1
					end
				else -- not use ability
					if not self.autoPressed then
						if R28_0711:existsClick("Auto.png") then
							self.autoMatch = R28_0711:getLastMatch()
							if DEBUG then R28_0711:highlight(self.highlightTime) end
							self.autoPressed = true
						else
							-- weird ...
							toast("Can't find Auto button. Maybe pressed.")
						end
					else  -- auto is pressed
						if self.autoMatch then
							r,g,b = getColor(self.autoMatch)
							if (r+g+b) < 150 then
								self.autoPressed = false
							end
						end
					end
				end
			else  -- not in battle
				local battleReturn = R48_3611:exists("BattleReturn.png")
				if battleReturn then
					if self.paused then
	 		   			click(battleReturn)
						self.paused = false
		 		   		watchdog:enable(true)
	 		   			toast("resume")
 		   			else
	 		   			toast("Paused.  Continue if keep stay in this menu page.")
						self.paused = true
						proVibrate(1)
		 		   		watchdog:enable(false)
		 		   		wait(5)
 		   			end
				else
					-- Battle finished
					farmer.battleRound = 0
					self.autoPressed = false
					self.giveup = false
					return "ResultGil"
				end
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
			if R34_1311:existsClick("Next1.png") then
				if self.giveup then
					self.giveup = false
					return "ChooseLevel"
				end
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
				if (self.friend) then
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
	self.state = self.initlaState
	watchdog:touch() --prevent dialog took too long

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

function Farmer.dogBarking(self, watchdog)
	local friendChoice1 = "PickupFriend.png"
	local friendChoice2 = "NoFriend.png"

	if DEBUG then toast("Watchdog barking") end
	if (R13_0111:exists("Communication_Error.png")) then
		R33_1111:existsClick("OK.png")
	elseif CloseAndGoTo:exists("GoTo.png") then
		-- If you finish 3 battle after daily timer reset, a dialog will popup.
		CloseAndGoTo:existsClick("Close.png")
		self.state = "ChooseStage"
	elseif R33_1111:existsClick("OK.png") then
		print("try click an OK")
	elseif R34_1311:exists("Go.png") then
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
	elseif R34_1311:existsClick("Next1.png") then -- if has next, click it.
		print("try click a next")
	elseif R34_1311:existsClick("Next.png") then -- if has next, click it.
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
			scriptExit("Farmer finished")
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
