--[[
    u# Unit 1 - 6
    a# action 1 - 4  atk, abi, itm, def
    i# index of action
    t# target unit 1 - 6 of allie.  For enemy, no need to set the target.
    l[#|a|r] launch a unit #, or launch by auto, or launch by repeat
    d# delay ms since first launch.  No float.
    w# wait for #ms, not like 

    s start need sround a battle round by start-end.  Will detect battle start.
    e end need sround a battle round by start-end
    q quit -- quit will call ankulua's scriptExit

    decode("su5a2i5 u4a2i5t24 u3a2i8i9i9'WBlackMagic+Lighten+Lighten' l2 d100 q l1 lr lae")
--]]
 

function isupper(c)
    return c ~= nil and c > 64 and c < 91
end

function islower(c)
    return c ~= nil and c > 96 and c < 123
end

function isalpha(c)
    return isupper(c) or islower(c)
end

function isnumber(c)
    return c ~= nil and c > 47 and c < 58
end
function isalnum(c)
    return isalpha(c) or isalnum(c)
end

function issinglequote(c)
    return c == 39 -- 39 is the single quote "'".
end

function isdoublequote(c)
    return c == 34 -- 34 is the double quote '"'.
end

function iseol(c)
    return c == 10 or c == 13 -- 34 is the double quote '"'.
end

function iswhitespace(c)
    return c == 32 or c == 11 or iseol(c)
end


DefaultInterpreter = {
    ["u"] = function(num)
        if not num then return true end -- expect a number
        print("unit" .. num)
        return false
    end,
    ["a"] = function(num)
        if not num then return true end -- expect a number
        print("action" .. num)
        return false
    end,
    ["i"] = function(num)
        if not num then return true end -- expect a number
        print("index" .. num)
        return false
    end,
    ["t"] = function(num)
        if not num then return true end -- expect a number
        print("target" .. num)
        return false
    end,
    ["l"] = function(arg)
        if not arg then return true end -- expect a argument
        print("launch" .. arg)
        return false
    end,
    ["d"] = function(num)
        if not num then return true end -- expect a number
        print("delay" .. num)
        return false
    end,
    ["w"] = function(num)
        if not num then return true end -- expect a number
        print("wait" .. num)
        return false
    end,
    ["s"] = function()
        print("start")
        return false
    end,
    ["e"] = function()
        print("end")
        return false
    end,
    ["q"] = function()
        print("quit")
        return false
    end,
}

function decode(interpreter, str)
    if not str then print("The code is not a string") return end
    if not typeOf(str) == 'string' then print("The code is not a string") return end
    local syntaxError = false
    local len = str:len()
    local byteStr = {str:byte(1, len)}
    local i = 1

    local strindex = 1
    local current = false
    function getNext()
        current = byteStr[strindex]  -- if overflow, return nil...
        strindex =  strindex + 1
        return current
    end

    function parser()
        local buffer = {}
        local bufferIndex = 1
        if current == nil then
            return nil, nil
        end

        if isalpha(current) then
            -- one alpha one code.
            buffer[1] = current
            getNext()
            return 'code', string.char(unpack(buffer))
        end
        if isnumber(current) then
            repeat
                buffer[bufferIndex] = current
                bufferIndex = bufferIndex + 1
            until (not isnumber(getNext()))
            return 'number', string.char(unpack(buffer))
        end
        if issinglequote(current) then
            repeat
                -- skip all text inside the quote.
                getNext()
            until issinglequote(current) or iseol(current)
            getNext()  -- skip quote itself
            return 'quote', nil
        end
        if isdoublequote(current) then
            repeat
                -- skip all text inside the quote.
                getNext()
            until isdoublequote(current) or iseol(current)
            getNext()  -- skip quote itself
            return 'quote', nil
        end
        if iswhitespace(current) then
            -- force skip all white space, including then eol.
            repeat until (not iswhitespace(getNext()))
            return 'white', nil
        end
        -- ignored
        local tmp = current
        getNext() -- skip this
        return 'others', tmp
    end 

    getNext()
    local currentCode = nil
    repeat
        id, buffer = parser()
        if id == nil then
            return nil
        end
        if id == 'code' or id == 'number' then
            if currentCode then
                interpreter[currentCode](buffer)
                expectNext = false
                currentCode = nil
            else
                if id == 'code' then
                    expectNext = interpreter[buffer]()
                    if expectNext then
                        currentCode = buffer
                    end
                else
                    print("syntax error at " .. strindex - 1)
                end
            end
        end
    until (id == nil)
end
