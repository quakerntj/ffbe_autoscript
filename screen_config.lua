--[[
    Naming Rule
    Single offset, length
    For Example
        X13 = X / 3
        Y24 = Y12 = Y / 2

    Region
        R[Split X][Split Y]_[Piece X Offset][Piece X Length][Piece Y Offset][Piece Y Length]
    For example
        R42_1111 = Region(X14, Y12, X14, Y12)
        R42_021 = Region(X14, Y12, X24, Y12)  -- X has 2 piece
--]]

-- Define all possible.

X12 = X / 2
X14 = X / 4
X34 = X * 3 / 4
X13 = X / 3
X23 = X * 2 / 3

X15 = X / 5
X25 = X * 2 / 5
X35 = X * 3 / 5
X45 = X * 4 / 5

Y12 = Y / 2
Y14 = Y / 4
Y34 = Y * 3 / 4
Y13 = Y / 3
Y23 = Y * 2 / 3

Y18 = Y / 8.0
Y38 = Y * 3 / 8
Y58 = Y * 5 / 8
Y78 = Y * 7 / 8

X24 = X12
X48 = X12
Y24 = Y12
Y48 = Y12
X28 = X14
Y28 = Y14
X68 = X34
Y68 = Y34

-- Only used region will be defined here.

R12_0011 = Region(0, 0, X, Y12)
R12_0111 = Region(0, Y12, X, Y12)
R21_0011 = Region(0, 0, X12, Y)
R21_1011 = Region(X12, 0, X12, Y)
R14_0112 = Region(0, Y12, X14, Y12)
R13_0111 = Region(0, Y13, X, Y13)
R33_1121 = Region(X13, Y23, X13, Y13)
R14_0111 = Region(0, Y14, X, Y12)
R23_1111 = Region(X12, Y13, X12, Y13)
R34_0011 = Regoin(0, 0, X13, Y14)
R34_1111 = Region(X13, Y14, X13, Y14)
R34_1211 = Region(X13, Y12, X13, Y14)
R34_1311 = Region(X13, Y34, X13, Y14)
R28_0711 = Region(0, Y78, X12, Y18)
R24_1211 = Region(X12, Y12, X12, Y14)
R58_2611 = Region(X25, Y34, X15, Y18)
R18_0711 = Region(0, Y78, X, Y18)

-- Direction for moving

DXN = 380 -- X NAGTIVE
DXC = 800 -- X CENTER
DXP = 1210 -- X POSITIVE

DYN = 770 -- Y NAGATIVE
DYC = 1170 -- Y CENTER
DYP = 1570 -- Y POSITIVE

DTABLE = {}
DTABLE[4] = Location(DXN, DYC)
DTABLE[7] = Location(DXN, DYP)
DTABLE[8] = Location(DXC, DYP)
DTABLE[9] = Location(DXP, DYP)
DTABLE[6] = Location(DXP, DYC)
DTABLE[3] = Location(DXP, DYN)
DTABLE[2] = Location(DXC, DYN)
DTABLE[1] = Location(DXN, DYN)

DTABLE[5] = Location(DXC, DYC)

