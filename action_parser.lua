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

--[[
    u# Unit 1 - 6
    a# action 1 - 4  atk, abi, itm, def
    i# index of action
    t# target unit 1 - 6 of allie.  For enemy, no need to set the target.
    l[#|a|r] launch a unit #, or launch by auto, or launch by repeat
    d# delay ms since first launch.  No float.
    w# wait for #ms, not like 

    s start need sround a battle round by start-end.
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
    return c == 10 or c == 13
end

function iswhitespace(c)
    return c == 32 or c == 11 or iseol(c)
end

function decode(syntax, str, _holder)
    if not str then print("The code is not a string") return end
    if not typeOf(str) == 'string' then print("The code is not a string") return end
    local syntaxError = false
    local len = str:len()
    local byteStr = {str:byte(1, len)}
    local i = 1

    local strindex = 1
    local current = false
    local lineCount = 1
    local charCount = 1
    function getNext()
        current = byteStr[strindex]  -- if overflow, return nil...
        charCount = charCount + 1
        if iseol(current) then
            lineCount = lineCount + 1
            charCount = 0
        end
        strindex =  strindex + 1
        return current
    end

    function parser()
        local buffer = {}
        local bufferIndex = 1
        if current == nil then
            return {'EOF', 'EOF'}
        end

        if isalpha(current) then
            -- one alpha one code.
            buffer[1] = current
            getNext()
            return {'code', string.char(unpack(buffer)), lineCount}
        end
        if isnumber(current) then
            repeat
                buffer[bufferIndex] = current
                bufferIndex = bufferIndex + 1
            until (not isnumber(getNext()))
            return {'number', string.char(unpack(buffer)), lineCount}
        end
        if issinglequote(current) then
            repeat
                -- skip all text inside the quote.
                getNext()
            until issinglequote(current) or iseol(current)
            getNext()  -- skip quote itself
            return {'quote'}
        end
        if isdoublequote(current) then
            repeat
                -- skip all text inside the quote.
                getNext()
            until isdoublequote(current) or iseol(current)
            getNext()  -- skip quote itself
            return {'quote'}
        end
        if iswhitespace(current) then
            -- force skip all white space, including then eol.
            repeat until (not iswhitespace(getNext()))
            return {'white'}
        end
        -- ignored
        local tmp = current
        getNext() -- skip this
        return {'others', tmp, 0}
    end

    function reportError(msg)
        print("syntax error:" .. lineCount .. ":" .. charCount)
        if msg then
            print("    " .. msg)
        end
    end

    getNext()
    local holder = {}  -- holder is used to keep data.
    if _holder ~= nil then
        holder = _holder
    end

    holder.init = false
--[[
    Each codeBuffer element has both id and data(code/number), data will not be
    nil.
    
    Syntax start at BOF (Begining of File), and end at EOF (End of File).
--]]
    
    local codeBuffer = {}
    local hasError = false
    local consumption = 0
    local msg = ""
    local hadEOF = false
    local lastCodeBufferSize = 0  -- prevent endless loop
    
    table.insert(codeBuffer, {'BOF', 'BOF'})
    repeat
--[[
    Collect a pair of command and call correspond syntax
    Expect the syntax will return consumed codeBuffer size.
    If consumed size is zero and has no error, suppose the command need more in
    the Buffer.
--]]
        local code = {}
        if not hadEOF then
            code = parser()
            local id = code[1]
            if id == 'EOF' then
                hadEOF = true
                table.insert(codeBuffer, code)
            elseif id == 'code' or id == 'number' then
                table.insert(codeBuffer, code)
            end
        end

        -- consume all commands in the buffer once parser()
        repeat

        if codeBuffer ~= nil and table.getn(codeBuffer) > 0 then
            if codeBuffer[1][1] == 'number' then
                hasError = true
                msg = "Meaning less number"
                break
            end

            consumption, hasError, msg =
                syntax[codeBuffer[1][2]](holder, codeBuffer)

            if hasError then
                break -- break consumption loop
            else
                if consumption > 0 then
                    for i = 1, consumption do
                        table.remove(codeBuffer, 1)
                    end
                end
            end
        else
            consumption = 0
        end

        until (consumption == 0)

        if hasError then
            reportError(msg)
            break  -- break the parser loop
        end

        if hadEOF then
            -- Avoid endless loop while EOF
            if lastCodeBufferSize > 0 and
                lastCodeBufferSize == table.getn(codeBuffer) then
                reportError("Endless command")
                print("Dump codeBuffer:")
                for k,v in ipairs(codeBuffer) do
                    print("k="..k.." v[1]="..v[1].." v[2]="..v[2])
                end
                wait(0.2)
            end
        end
        lastCodeBufferSize = table.getn(codeBuffer)
    until (lastCodeBufferSize == 0 and hadEOF)

    return holder.script
end

