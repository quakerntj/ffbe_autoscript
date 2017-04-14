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
	return self
end

function TrustManager:Looper()
	if not DEBUG then STEP = 2 end
	ON_AUTO = false
	watchDog = WatchDog(15, self, self['dogBarking'])

	--local ResultNext = Region(600, 2200, 240, 100)
	local ResultItemNextLocation = Location(720, 2250)

	if (QUEST == 1) then
		QUEST_NAME= "01_The_Temple_of_Earth_Entry.png"
	elseif (QUEST == 2) then
		QUEST_NAME= "01_The_Temple_of_Earth_End.png"
	else
		QUEST_NAME= "01_The_Temple_of_Earth_Entry.png"
	end

	local friendChoice1 = ""
	local friendChoice2 = ""
	if (FRIEND) then
		friendChoice1 = "02_Pick_up_friend.png"
		friendChoice2 = "02_No_friend.png"
	else
		friendChoice2 = "02_Pick_up_friend.png"
		friendChoice1 = "02_No_friend.png"
	end

	switch = {
		["ChooseStage"] = function()
			if existsClick("TheTempleofEarthMapIcon.png") then
				return "ChooseLevel"
			end
			return "ChooseStage"
		end,
		
		["ChooseLevel"] = function()
			if (existsClick(QUEST_NAME)) then
				return "Challenge"
			end
			return "ChooseLevel"
		end,
		["Challenge"] = function()
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
				setScanInterval(10)
				wait(30)
				setScanInterval(SCAN_INTERVAL)
			end
			return "Challenge"
		end,
		["ChooseFriend"] = function()
			if (R34_1111:existsClick(friendChoice1)) then
				return "Go"
			elseif (R34_1111:existsClick(friendChoice2)) then
				return "Go"
			end
			return "ChooseFriend"
		end,
		["Go"] = function()
			if (R34_1311:existsClick("03_Go.png")) then
				return "IsInBattle"
			end
			return "Go"
		end,

		["IsInBattle"] = function()
			-- Make sure we are in battle.
			if BattleIndicator:exists("Battle.png") then
				ON_AUTO = false
				return "Battle"
			end
			return "IsInBattle"
		end,
		
		["Battle"] = function(watchdog)
			local inBattle = (BattleIndicator:exists("Battle.png") ~= nil)
			if (inBattle and (watchdog ~= nil)) then
				watchdog:touch()
			end

			if (ON_AUTO and (not inBattle)) then
				ON_AUTO = false
				setScanInterval(SCAN_INTERVAL)
				return "ResultGil"
			elseif (R28_0711:existsClick("04_Auto.png")) then
				ON_AUTO = true
				setScanInterval(10)
			end
			return "Battle"
		end,

		["ResultGil"] = function()
			-- click "GIL" icon for speed up and skip rank up
			ResultIndicator:existsClick("BattleFinishResult.png")
			if R34_1311:existsClick("06_Next1.png") then
				return "ResultExp"
			end
			return "ResultGil"
		end,
		
		["ResultExp"] = function()
			-- may have level up and trust up at the same time. click twice.
			if (ResultExp:existsClick("07_Next_2.png")) then
				wait(0.5)
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
			R34_1311:highlight(0.3)
			if R34_1311:existsClick("Result_Next.png", 4) then
			--if (click(ResultItemNextLocation)) then
				if (FRIEND) then
					-- Not to add new friend
					existsClick("08_No_Friend1.png", 5)
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
	
	self.loopCount = 0
	self.state = self.States[STEP]
	while self.loopCount < CLEAR_LIMIT do
		if DEBUG then toast(self.state) end
		-- run state machine
		newState = switch[self.state](watchDog)
		if newState ~= self.state then
			self.state = newState
			watchDog:touch()
		end
		watchDog:awake()
		
		if (self.state == "Clear") then
			self.state = "ChooseLevel"
			self.loopCount = self.loopCount + 1
			toast("Quest clear:"..self.loopCount.."/"..CLEAR_LIMIT.."("..questTimer:check().."s)")
			questTimer:set()
			self.errorCount = 0
		end
	end
	print("Quest clear:"..self.loopCount.."/"..CLEAR_LIMIT.."("..self.totalTimer:check().."s)")
end

function TrustManager.dogBarking(self, watchdog)
	friendChoice1 = "02_Pick_up_friend.png"
	friendChoice2 = "02_No_friend.png"

	if DEBUG then toast("Watchdog barking") end
	if (R13_0111:exists("Communication_Error.png")) then
		R33_1111:existsClick("OK.png")
	elseif R33_1111:existsClick("OK.png") then
	elseif BattleIndicator:exists("Battle.png") then
		self.state = "Battle"
	elseif ResultIndicator:exists("BattleFinishResult.png") then
		self.state = "ResultGil"
	elseif ResultExp:exists("07_Next_2.png") then
		self.state = "ResultExp"
	elseif exists(QUEST_NAME) then
		self.state = "ChooseLevel"
	elseif R34_1311:existsClick("06_Next1.png") then -- if has next, click it.
		print("try click a next")
	elseif R34_1311:existsClick("06_Next.png") then -- if has next, click it.
		print("try click a next")
	elseif R34_1311:existsClick("Result_Next.png") then -- if has next, click it.
		print("try click a next")
	elseif (R34_1111:exists(friendChoice1)) or (R34_1111:exists(friendChoice2)) then
		return "ChooseFriend"
	elseif R34_0011:exists("LeftTop_Return.png") then
		-- keep return until ChooseStage.  Put this check at final.
		self.state = "ChooseStage"
	else
		self.errorCount = self.errorCount + 1
		if self.errorCount > 3 then
			print("Error can't be handled. Stop Script.")
			print("Quest clear:"..self.loopCount.."/"..CLEAR_LIMIT.."("..self.totalTimer:check().."s)")
			scriptExit("Trust Manger finished")
			vibrate(2)
		else
			print("Error count: " ..self.errorCount)
			toast("Error count: " ..self.errorCount)
			DEBUG = true
			vibrate(2)
			-- not to touch dog when error
			return
		end
	end

	watchdog:touch()
end
