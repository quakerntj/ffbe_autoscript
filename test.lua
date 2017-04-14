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
