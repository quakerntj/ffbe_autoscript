-- Edit by Quaker NTj

WatchDog = {}
WatchDog.__index = WatchDog

setmetatable(WatchDog, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function WatchDog.new(timeout, obj, bark)
	local self = setmetatable({}, WatchDog)
	self.timeout = timeout
	self.timer = Timer()
	self.timer:set()
	self.obj = obj
	self.bark = bark -- callback function
	return self
end

function WatchDog:touch()
	self.timer:set()
	self.lastTouch = self.timer:check()
end

function WatchDog:awake()
	if (self.timer:check() > self.timeout) then
		self.bark(self.obj, self)  -- User should touch the dog themself.
	end
end

TrustManager = {}
TrustManager.__index = TrustManager

setmetatable(TrustManager, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function TrustManager.new()
	local self = setmetatable({}, TrustManager)
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
	if not DEBUG then STEP = 1 end
	ON_AUTO = false
	watchDog = WatchDog(10, self, self['dogBarking'])

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
				-- Run out of friend or forgot to set filter.
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
			local inBattle = (not (BattleIndicator:exists("Battle.png") == nil))
			if (inBattle and (not (watchdog == nil))) then
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
				click(getLastMatch())
				return "ResultItem"
			end
			return "ResultExp"
		end,
		["ResultItem"] = function()
			-- Result Next is bigger than other next...
			wait(1)
			local l = Location(X12, Y12)
			click(l) -- speed up showing items
			wait(0.5)
			if (click(ResultItemNextLocation)) then
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
		if not (newState == self.state) then
			self.state = newState
			watchDog:touch()
		end
		watchDog:awake()
		
		if (self.state == "Clear") then
			self.state = "ChooseLevel"
			self.loopCount = self.loopCount + 1
			toast("Quest clear:"..self.loopCount.."/"..CLEAR_LIMIT.."("..questTimer:check().."s)")
			questTimer:set()
		end
	end
	print("Quest clear:"..self.loopCount.."/"..CLEAR_LIMIT.."("..self.totalTimer:check().."s)")
end

function TrustManager.dogBarking(self, watchdog)
	if DEBUG then toast("Watchdog barking") end
	if (R13_0111:exists("Communication_Error.png")) then
		R13_0111:existsClick("OK.png")
	elseif BattleIndicator:exists("Battle.png") then
		self.state = "Battle"
	elseif ResultIndicator:exists("BattleFinishResult.png") then
		self.state = "ResultGil"
	elseif ResultExp:exists("07_Next_2.png") then
		self.state = "ResultExp"
	elseif exists(QUEST_NAME) then
		self.state = "ChooseLevel"
	elseif R34_0011:exists("LeftTop_Return.png") then
		-- keep return until ChooseStage
		self.state = "ChooseStage"
	elseif R34_1311:existsClick("06_Next1.png") then -- if has next, click it.
	elseif R34_1311:existsClick("06_Next.png") then -- if has next, click it.
	elseif (R34_1111:exists(friendChoice1)) or (R34_1111:exists(friendChoice2)) then
		return "ChooseFriend"
	else
		print("Error can't be handled. Stop Script.")
		print("Quest clear:"..self.loopCount.."/"..CLEAR_LIMIT.."("..self.totalTimer:check().."s)")
		scriptExit("Trust Manger finished")
	end

	watchdog:touch()
end
