-- Edit by Quaker NTj

WatchDog = {}
WatchDog.__index = WatchDog

setmetatable(WatchDog, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function WatchDog.new(timeout, bark)
	local self = setmetatable({}, WatchDog)
	self.timeout = timeout
	self.timer = Timer()
	self.timer:set()
	self.bark = bark -- callback function
	return self
end

function WatchDog:touch()
	self.timer:set()
end

function WatchDog:awake()
	if (self.timer:check() > self.timeout)
		bark(self)  -- User should touch the dog themself.
	else
		self:touch()
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
	local z = setmetatable({}, TrustManager)
	z.States = {
		"ChooseLevel",
		"Challenge",
		"ChooseFriend",
		"Go",
		"Battle",
		"ResultsExp",
		"ResultsItem",
		"Clear"
	}
	return z
end

function TrustManager:Looper()
    if not DEBUG then
        STEP = 1
    end
    ON_AUTO = false
    watchDog = WatchDog(30, z:dogBarking)

    local ResultExp = Region(560, 1000, 590, 400)
    --local ResultNext = Region(600, 2200, 240, 100)
    local ResultItemNextLocation = Location(720, 2250)

    if (QUEST == 1) then
        QUEST_NAME= "01_The_Temple_of_Earth_Entry.png"
    elseif (QUEST == 2) then
        QUEST_NAME=  "01_The_Temple_of_Earth_End.png"
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
    		if (existClick("TheTempleofEarthMapIcon.png") then
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
                return "Battle"
            end
            return "Go"
        end,
        ["Battle"] = function()
            if (ON_AUTO and R34_1311:existsClick("06_Next1.png")) then
                ON_AUTO = false
                setScanInterval(SCAN_INTERVAL)
                return "ResultExp"
            elseif (R28_0711:existsClick("04_Auto.png")) then
                ON_AUTO = true
                setScanInterval(10)
            end
            return "Battle"
        end,
        ["ResultExp"] = function()
            -- may have level up and trust up at the same time. click twice.
            if (ResultExp:existsClick("07_Next_2.png")) then
                wait(0.5)
                click(getLastMatch())
                return "ResultItem"s
            end
            return "ResultExp"
        end,
        ["ResultItem"] = function()
            -- Result Next is bigger than other next...
            wait(1)
            click(Location(X12, Y12) -- speed up showing items
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

    z.totalTimer = Timer()
    local questTimer = Timer()
    totalTimer:set()
    questTimer:set()
    
    z.loopCount = 0
    z.state = z.States[STEP]
    while loopCount >= CLEAR_LIMIT do
        if DEBUG then
            toast(z.state)
        end
        -- run state machine
        z.state = switch[z.state]()
        
        watchDog:awake()
        if (z.state == "Clear") then
        	questTimer:set()
            z.state = "ChooseLevel"
            z.loopCount = z.loopCount + 1
            toast("Quest clear:"..z.loopCount.."/"..CLEAR_LIMIT.."("..questTimer:check().."s)")
        end
    end
    print("Quest clear:"..z.loopCount.."/"..CLEAR_LIMIT.."("..z.totalTimer:check().."s)")
end

function TrustManager:dogBarking(watchdog)
	toast("Watchdog barking")
    if (R13_0111:exists("Communication_Error.png")) then
        R13_0111:existsClick("OK.png")
    elseif R34_0011:existsClick("LeftTop_Return.png") then
        -- keep return until ChooseStage
		z.state = "ChooseStage"
    else
    	print("Error can't be handled. Stop Script.")
	    print("Quest clear:"..z.loopCount.."/"..CLEAR_LIMIT.."("..z.totalTimer:check().."s)")
    	scriptExit("Trust Manger finished")
    end

	self.watchdog.touch()
end