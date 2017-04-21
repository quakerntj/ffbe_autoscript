require("ankulua")
require("tools")

a = Point(1, 0)
print(a)
print(type(a))
b = Point(0, 1)
print(b)
print(type(b))
c = ((a-3) / 3) - ((b+1) * 4) + (b * 2) + 1
print("C"..-c)


function foo(...)
    local args = table.pack(...)
    print(args[1])
    print(args[2])
    print(args[3])
end

function bar(...)
    foo(...)
end

bar(1, -c)
bar(1, "3", 5)

