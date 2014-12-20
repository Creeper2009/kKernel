_G['crc32'] = {}
--require('api/bit')
require('api/numberlua.lua', true)

local POLY = 0x04C11DB7

local function tGen()
	local function f(i)
		local crc = i
		for j=1,8 do
			local b = crc % 2
			crc = (crc - b) / 2
			if b == 1 then crc = bit.bxor(crc, POLY) end
		end
		return crc
		end
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k); t[k] = v
		return v
	end
	return t
end
local tCRC32 = tGen()

crc32.hash = function(data)
	data = tostring(data)
    local crc = (2^32) - 1
	--print(#data)
    for i = 1,#data do
		crc = bit.bxor(bit.lshift(crc, 8), tCRC32[bit.bxor(bit.rshift(crc, 24), data:byte(i)) + 1])
    end
    return crc
end

--[[local tArgs = {...}
local wew = 'f'--tArgs[1]
print(wew..': '..string.format('%x', crc32.hash(wew)))
sleep(55)]]