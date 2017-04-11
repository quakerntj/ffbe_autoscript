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
	return z
end

function TrustManager:Looper()
    if not DEBUG then
        STEP = 1
    end
    CLEAR = 0                -- Stage clear times
    ON_AUTO = false
    ERROR_COUNT = 0
    TIMER = Timer()			-- Timer of loop
    TIMER2 = Timer()		-- Timer of step
    watchDog = WatchDog(3, z:dogBarking)

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

    if (FRIEND) then
        FRIEND_NAME = "02_Pick_up_friend.png";
    else
        FRIEND_NAME = "02_No_friend.png";
    end

    switch = {
        [  1 ] = function()
            if (existsClick(QUEST_NAME)) then
                TIMER2:set()
                R34_1311:highlight(0.1)
                if (R34_1311:existsClick("06_Next.png")) then
                    wait(0.8)
                    R34_1111:highlight(0.1)
                    if (R34_1111:existsClick(FRIEND_NAME)) then
                        STEP = 2
                    else
                    	-- Run out of friend
                    	R34_1111:existsClick("02_No_friend.png")
                    end
                else
                    R23_1111:highlight(0.1)
					if (BUY and BUY_LOOP > 0 and R23_1111:existsClick("Use_Gem.png")) then
						R24_1211:highlight(0.1)
                        R24_1211:existsClick("Buy_Yes.png")
                        wait(5)
                        R34_1311:highlight(0.1)
                        R34_1311:existsClick("06_Next.png")
                        wait(3)
                        R14_0111:highlight(0.1)
                        R14_0111:existsClick(FRIEND_NAME)
                        STEP = 2

                        print("使用寶石回復體力")
                        BUY_LOOP = BUY_LOOP - 1
                    else
                    	R34_1211:highlight(0.1)
						if (R34_1211:existsClick("Stamina_Back.png")) then
                        	toast('體力不足，等待中...')
                        setScanInterval(10)
                        wait(30)
                        setScanInterval(SCAN_INTERVAL)
                        end
                    end
                end
            else
                toast('找不到關卡')
                if existsClick("06_Next.png") then
                    wait(0.8)
        	    	R34_1111:existsClick(FRIEND_NAME)
				    STEP = 2
				elseif
	                existsClick("LeftTop_Return.png") then
                	STEP = 1
				end
            end
        end,
        [ 2 ] = function()
            R34_1311:highlight(0.1)
            if (R34_1311:existsClick("03_Go.png")) then
                STEP = 3
            end
        end,
        [ 3 ] = function()
            R34_1311:highlight(0.1)
            R28_0711:highlight(0.1)
            if (ON_AUTO) then
                if (R34_1311:existsClick("06_Next1.png")) then
                    ON_AUTO = false
                    STEP = 4
                    setScanInterval(SCAN_INTERVAL)
                end
            elseif (R28_0711:existsClick("04_Auto.png")) then
                ON_AUTO = true
                setScanInterval(10)
            end
        end,
        [ 4 ] = function()
            ResultExp:highlight(0.1)
            if (ResultExp:existsClick("07_Next_2.png")) then
                wait(0.5)
                click(getLastMatch())
                STEP = 5
            end
        end,
        [ 5 ] = function()
            -- Result Next is bigger than other next...
            wait(1)
            if (click(ResultItemNextLocation)) then
                if (FRIEND) then
                    existsClick("08_No_Friend1.png", 5)
                end
                STEP = 1
                CLEAR = CLEAR + 1
            end
        end
    }

    TIMER:set()
    repeat
        switch[STEP]()
        watchDog:awake()
        if DEBUG then
            toast("step"..STEP)
        end
        if (R13_0111:exists("Communication_Error.png")) then
            R13_0111:existsClick("OK.png")
        end
        FINISH = false
        if (CLEAR == CLEAR_LIMIT) then    -- Step repeat check
            FINISH = true
            print("Quest clear:"..CLEAR.."/"..CLEAR_LIMIT.."("..TIMER:check()..")")
        elseif (ERROR_COUNT == 5) then
            FINISH = true
            print("程式錯誤，腳本跳出")
            toast("程式錯誤，腳本跳出")
        else
            FINISH = false
            if (STEP == 1) then
                toast("Quest clear:"..CLEAR.."/"..CLEAR_LIMIT.."("..TIMER2:check()..")")
            end
        end
    until FINISH
end

function TrustManager:dogBarking(watchdog)
	self.watchdog.touch()
end