require("ankulua")
require("tools")
require("action_parser")
--a = Point(1, 0)
--print(a)
--print(type(a))
--b = Point(0, 1)
--print(b)
--print(type(b))
--c = ((a-3) / 3) - ((b+1) * 4) + (b * 2) + 1
--print("C"..-c)


--function foo(...)
--    local args = table.pack(...)
--    print(args[1])
--    print(args[2])
--    print(args[3])
--end

--function bar(...)
--    foo(...)
--end

--bar(1, -c)
--bar(1, "3", 5)

local num = "5"
local waitChooseTarget = 0.3
local round = [[print("start")]]
round = round .. [[
function rounddd(num, units)
    if not DesignedBattle.hasReturn() then
        scriptExit("Error when select target unit "..num)
    end
    print(units[]] .. tonumber(num) ..[[])
    wait(]]..waitChooseTarget..[[)
end
]]

print(round)
DesignedBattle = {["hasReturn"] = function() end}
function wait(h) end
loadstring(round)()
print("lol")
local units = {4, 1, 5, 3, 2}
rounddd(num, units)
loadstring(round)()
rounddd(num, units)

