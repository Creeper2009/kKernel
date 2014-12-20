--kernel.require('bit')

--Largest integral number in Lua: 9223372036854775807 (0x7FFFFFFFFFFFFFFF) (63 bits, 64 excluding sign)
--Largest integral number able to be handled: 9223372036854775806
--obj.tbl: Highest to lowest (bitwise)

_G['bigint'] = {}

local function hex(data, base)
	if not base then base = 2 end
	return string.format('%x', tonumber(data, base)..'')
end

local function tobase(number, base)
	local digits = {}
	for i=0,9 do digits[i] = string.char(string.byte('0')+i) end
	for i=10,36 do digits[i] = string.char(string.byte('A')+i-10) end
	local s = ""
	repeat
		local remainder = number % base
		s = digits[remainder]..s
		number = (number-remainder)/base
	until number==0
	return s
end

bigint.addnumlwr = function(obj, num, base) --if numbers are being inputted from smallest to highest
	table.insert(obj.tbl, 1, tobase(tonumber(num, base), 36))
end

bigint.addnum = function(obj, num, base)
	table.insert(obj.tbl, tobase(tonumber(num, base), 36))
end

bigint.tostr = function(obj, base)
	base = 2 --only binary supported currently
	local s = ''
	for i=1,#obj.tbl do
		s = s .. tobase(tonumber(obj.tbl[i], 36), base)
	end
	return s
end

bigint.tonum = function(obj, base) --technically shouldn't work
	if not base then base = 10 end
	local num = 0
	for i=1,#obj.tbl do
		num = bit.bor(bit.lshift(num, 63), tonumber(obj.tbl[i], 36))
	end
	return num
end

bigint.export = function(obj)
	local s = ''
	for i=1,#obj.tbl do
		if s ~= '' then s = s .. ';' end
		s = s .. obj.tbl[i]
	end
	return s
end

local function newObj(tbl)
	local f = {
		addnum = bigint.addnum;
		addnumlwr = bigint.addnumlwr;
		tostr = bigint.tostr;
		tonum = bigint.tonum;
		export = bigint.export;
	}
	f.tbl = tbl
	return f
end

bigint.import = function(str)
	local tbl = {}
	for v in str:gmatch('[^;]+') do
		print(v)
		table.insert(tbl, v)
	end	
	print('kek')
	print(textutils.serialize(tbl))
	return newObj(tbl)
end

bigint.split = function(str, base)
	local split = 0
	if base == 2 then
		split = 62 --64*
	elseif base == 8 then
		split = 20 --21*
	elseif base == 16 then
		split = 14 --16* (0x7FFFFFFFFFFFFFFF)
	else
		error('Not a supported base')
	end
	
	local obj = newObj({})
	for i=#str,1,-split do
		local l = math.max(1, i-split)
		--[[print(#str)
		print(l)
		print(i)
		print(str:sub(l, i))
		print(tonumber(str:sub(l, i), base))]]
		obj:addnumlwr(str:sub(l, i), base)
	end
	return obj
end

bigint.new = function()
	return newObj({})
end

bigint.parse = function(num)
	return newObj({tobase(tonumber(num, base), 36)})
end

--[[print('Test: 1100000000000000000000000000110000000000000000000000000011')
--local f = bigint.import('1Y2P0IJ32E8E7;1Y2P0IJ32E8E7;' .. tobase(1, 36))
local f = bigint.split('110000000000000000000000000000000000000000000000011000000000000000000000000000000000000000000011', 2)
print('tostr: ', f:tostr())
print('export: ', f:export())
print('compression ratio: ', f:export():len()/f:tostr():len())
print('decompressed: ', f:tostr())]]