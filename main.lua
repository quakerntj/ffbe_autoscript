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

if Location == nil then
    require("ankulua.lua")
end

WORK_DIR = scriptPath()
package.path = package.path .. ";" .. WORK_DIR .. '?.lua'

-- ========== Initial Settings ================
Settings:setCompareDimension(true, 1440)--執行圖形比對時螢度的解析度。根據compareByWidth的值的值設定成寬度或高度
Settings:setScriptDimension(true, 1440)--用於參考App解析度腳本內座標位置
Settings:set("MinSimilarity", 0.85)

setDragDropTiming(200, 220)	--downMs: 開始移動前壓住不動幾毫秒	upMs: 最後放開前停住幾毫秒
setDragDropStepCount(35)	--stepCount: 從啟始點到目的地分幾步移動完
setDragDropStepInterval(10)	--intervalMs: 每次移動間停留幾毫秒

screen = getAppUsableScreenSize()
X = screen:getX()
if (screen:getY() / 2560) > 0.93 then
    Y = 2560 --screen:getY() will not get right full screen size.
else
    Y = screen:getY()
end
DEBUG = true

require("ankulua_wrapper")
require("tools")
require("screen_config")
require("battle_scene")
require("designed_battle")
require("watchdog")
require("trust")
require("explore")



-- ========== Dialogs ================

dialogInit()
FUNC=1
addRadioGroup("FUNC", 1)
    addRadioButton("刷土廟", 1)
    addRadioButton("自動點擊REPEAT", 2)
    addRadioButton("自動移動", 3)
    addRadioButton("測試1", 4)
    addRadioButton("測試2", 5)
    newRow()
BRIGHTNESS = false IMMERSIVE = true
addCheckBox("BRIGHTNESS", "螢幕亮度最低", true)newRow()
addCheckBox("IMMERSIVE", "Immersive", true)newRow()
addCheckBox("DEBUG", "Debug mode", true)newRow()
addCheckBox("PRO", "專業版請打勾", false)newRow()
dialogShow("選擇自動化功能")

setImmersiveMode(IMMERSIVE)

if FUNC == 1 then
    trust = TrustManager()
    trust:looper()
    scriptExit("Trust finish")
elseif FUNC == 2 then
    REPEAT_COUNT = 4
    dialogInit()
    addTextView("Repeat次數：")addEditNumber("REPEAT_COUNT", 4)
    dialogShow("Auto Click Repeat")

    if BRIGHTNESS then
        proSetBrightness(0)
    end

    repeat
        if (R18_0711:existsClick("Repeat.png")) then
            REPEAT_COUNT = REPEAT_COUNT - 1
        end
        FINISH = REPEAT_COUNT == 0
    until FINISH
    scriptExit("Repeat finish")
elseif FUNC == 3 then
    explorer = Explorer()
    explorer:run()
    scriptExit("Repeat finish")
elseif FUNC == 4 then
    db = DesignedBattle(2)
    db:loop()
    scriptExit("Repeat finish")
elseif FUNC == 5 then
-- TODO find out the trust percentage.  OCR didn't work for Android N...
--    for i, rect in ipairs(TrustPercentageRects) do
--        rect.region:highlight(1)
--    end
--    for i, rect in ipairs(TrustPercentageRects) do
--        local number, b = numberOCRNoFindException(rect.region,"trust")
--        if b then print(number) end
--    end
end

