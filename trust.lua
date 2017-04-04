-- 
-- Created by IntelliJ IDEA. 
-- User: vic 
-- Date: 2016/10/31 
-- Time: 下午 01:38 
-- To change this template use File | Settings | File Templates. 
-- 
 
-- ========== Settings ================ 
Settings:setCompareDimension(true, 1440)--執行圖形比對時螢度的解析度。根據compareByWidth的值的值設定成寬度或高度 
Settings:setScriptDimension(true, 1440)--用於參考App解析度腳本內座標位置 
Settings:set("MinSimilarity", 0.65) 
setImmersiveMode(true)
setBrightness(10)
screen = getAppUsableScreenSize() 
X = screen:getX() 
Y = 2560 -- screen:getY()
X12 = X / 2
X14 = X / 4
X34 = X * 3 / 4
X13 = X / 3
X23 = X * 2 / 3
Y13 = Y / 3
Y23 = Y * 2 / 3
Y14 = Y / 4
Y34 = Y * 3 / 4


all = Region(	0,   	0,   	X,	  	Y 	) 
-- 1/2 
upper = Region(	0,   	0,   	X,	  	Y/2 	) 
center= Region( 0,		Y/4,   	X,		3*Y/4	) 
lower = Region( 0,		Y/2,   	X,		Y 		) 
left  = Region( 0,		0,		X/2,	Y 		) 
right = Region( X/2,	0,  	X,		Y 		) 
-- 1/3
middle = Region( 0, Y/3, X, 2*Y/3 )
lowerMiddle = Region(X13, Y23, X23, Y)
-- 1/4 
upperLeft  = Region(	0,		0,  	X/2,	Y/2 ) 
upperRight = Region(	X/2,	0,  	X,  	Y/2 ) 
lowerLeft  = Region(	0,   	Y/2,  	X/2,  	Y 	) 
lowerRight = Region(	X/2,   	Y/2,  	X,		Y	) 
upperUpper = Region(	0,     	0,  	X,  	Y/4 ) 
upperLower = Region(	0,   	Y/4, 	X,  	Y/2 ) 
lowerUpper = Region(	0,   	Y/2,  	X,  	3*Y/4 ) 
lowerLower = Region(	0, 		3*Y/4,	X,		Y 	) 
leftLeft   = Region(	0,		0,  	X/4,    Y 	) 
leftRight  = Region(	X/4,    0,  	X/2,    Y 	) 
rightLeft  = Region(	X/2,    0,  	3*X/4,	Y 	) 
rightRight = Region(	3*X/4,	0,  	X,		Y 	) 
-- 1/8 
upperUpperLeft  = Region(	0,		0, 		X/2, 	Y/4 	) 
upperUpperRight = Region(	X/2,	0, 		X, 		Y/4 	) 
upperLowerLeft  = Region(   0,   	Y/4, 	X/2, 	Y/2 	) 
upperLowerRight = Region(	X/2,   	Y/4, 	X, 		Y/2 	) 
lowerUpperLeft  = Region(   0,   	Y/2, 	X/2,	3*Y/4 	) 
lowerUpperRight = Region(	X/2,   	Y/2, 	X, 		3*Y/4 	) 
lowerLowerLeft  = Region(   0, 		3*Y/4,	X/2, 	Y 	) 
lowerLowerRight = Region( 	X/2, 	3*Y/4,	X, 		Y 	)
lowerLowerMiddle = Region(X13, Y34, X23, Y)   
-- ==========  main program =========== 
STEP = 1
CLEAR = 0				-- Stage clear times 
CLEAR_LIMIT = 999				-- Step now 
ON_AUTO = false
ERROR_COUNT = 0 
switch = { 
    [  1 ] = function()
        if (existsClick("01_The_Temple_of_Earth.png")) then 
            existsClick("06_Next.png")
            --if(upperLowerRight:existsClick("02_Pick_up_friend.png")) then 
            --    ERROR_COUNT = 0 
            --    STEP = 2 
            --else
            if(upperLower:existsClick("02_No_friend.png")) then
                STEP = 2
            else 
                if (existsClick("08_No.png")) then 
                    toast('體力不足，等待中...') 
                    wait(30) 
                end 
            end 
        else 
            toast('找不到 "土之神殿。入口 " ')
            existsClick("06_Next.png")
            existsClick("09_Screensho.png")
            STEP = 2
        end
        setScanInterval(1)
    end, 
    [ 2 ] = function() 
        if(existsClick("03_Go.png")) then 
            STEP = 3 
        end 
    end, 
    [ 3 ] = function()
        if(ON_AUTO) then 
            if(lowerLowerMiddle:existsClick("06_Next1.png")) then 
                ON_AUTO = false 
                STEP = 4
                setScanInterval(2)
            end 
        elseif(lowerLowerLeft:existsClick("04_Auto1.png")) then
            ON_AUTO = true
            setScanInterval(10)
        end
    end, 
    [ 4 ] = function()
        if(upperRight:existsClick("07_Next_2.png")) then 
            wait(1)
        elseif(lowerLowerMiddle:exists("06_Next.png")) then
            STEP = 5
        end 
    end, 
    [ 5 ] = function() 
        if(lowerLowerMiddle:existsClick("06_Next.png")) then 
            lowerLowerMiddle:existsClick("06_Next.png") 
            existsClick("08_No_Friend.png", 5 ) 
            STEP = 1 
            CLEAR = CLEAR + 1
            setScanInterval(5)
        elseif(exists("01_The_Temple_of_Earth.png"))
            STEP = 1
            setScanInterval(5)
        end
    end
} 
repeat 
    switch[STEP]() 
    --if(middle:exists("Communication_Error.png")) then 
    --    middle:existsClick("OK.png")
    --end
    FINISH = false 
    if(CLEAR == CLEAR_LIMIT) then	-- Step repeat check 
        FINISH = true 
        print("Quest clear:"..CLEAR.."/"..CLEAR_LIMIT) 
    elseif(ERROR_COUNT == 5) then 
        FINISH = true 
        print("程式錯誤，腳本跳出") 
        toast("程式錯誤，腳本跳出") 
    else 
        FINISH = false 
        if(STEP == 1)then 
            toast("Quest clear:"..CLEAR.."/"..CLEAR_LIMIT) 
        end 
    end 
until FINISH
