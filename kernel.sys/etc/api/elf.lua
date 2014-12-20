--[[shell.setDir('/kernel.sys/')
shell.run]]
require('api/crc32.lua')
--print(require('api/huff', true))
require('api/libcompress.lua', false, true)
--LibCompress = dofile('/kernel.sys/etc/api/libcompress.lua')
 
function precompile(sCode)
	--local f = assert(loadstring(sCode))
	local f = loadstring(sCode)
	if not f then
		error('Incomplete/invalid code', 2)
	end
	return string.dump(f)
end

version = '1.0'
function postcompile(sBytes, type, baseargs)
	if type == nil then type = 'ELF' end
	if not baseargs or baseargs == '' then baseargs = ' ' end
	if type:upper() == 'ELF' or type:upper() == 'RLF' then
		return type:upper() .. '|' .. version .. '|' .. baseargs .. '|' .. crc32.hash(sBytes) .. '|' .. sBytes
	elseif type:upper() == 'CLF' then
		--local sComp, sLen = huff.encode(sBytes)
		local sComp = LibCompress:Compress(sBytes)
		--return type:upper() .. '|' .. version .. '|' .. baseargs .. '|' .. crc32.hash(sComp .. ';' .. sLen) .. '|' .. sComp .. ';' .. sLen
		print(#sBytes, ';', #sComp)
		return type:upper() .. '|' .. version .. '|' .. baseargs .. '|' .. crc32.hash(sComp) .. '|' .. sComp
	--elseif type:upper() == 'XLF' then --self-executable
	else
		error('Unknown ELF type', 2)
	end
end

function compile(code, type, baseargs)
	if type:upper() == 'RLF' then
		return postcompile(code, type, baseargs)
	end
	local result, data = pcall(precompile, code)
	if not result then
		error(data:sub(8,-1), 2)
	end
	return postcompile(data, type, baseargs)
end

function verify(sBytes)
	local tArgs = {}
	for item in string.gmatch(sBytes, '[^|]+') do
		tArgs[#tArgs+1] = item
	end
	local type = tArgs[1]
	local v = tArgs[2]
	local baseargs = tArgs[3]
	local hash = tonumber(tArgs[4])
	local sBytes = tArgs[5]
	if #tArgs > 5 then
		for i=6,#tArgs do
			sBytes = sBytes .. '|' .. tArgs[i]
		end
	end
	print(#sBytes)
	local newHash = tonumber(crc32.hash(sBytes))
	
	if v ~= version then error('ELF was compiled with an incompatible version', 3) end
	if hash ~= newHash then error('ELF CRC mismatch', 3) end
	return true
end

function runf(sBytes)
	local tArgs = {}
	for item in string.gmatch(sBytes, '[^|]+') do
		tArgs[#tArgs+1] = item
	end
	local type = tArgs[1]
	local baseargs = tArgs[3]
	local sBytes = tArgs[5]
	if #tArgs > 5 then
		for i=6,#tArgs do
			sBytes = sBytes .. '|' .. tArgs[i]
		end
	end
	
	if type:upper() == 'ELF' or type:upper() == 'RLF' then
		return loadstring(sBytes), baseargs
	elseif type:upper() == 'CLF' then
		--[[local sLen = string.match(sBytes, '.*;([0-9]+)')
		print('sLen: ',sLen)
		sBytes = string.match(sBytes, '(.*);[0-9]+')]]
		local fef = LibCompress:Decompress(sBytes)
		--print(fef)
		--print('Success!')
		return loadstring(fef), baseargs
	--elseif type:upper() == 'XLF' then --self-executable
	else
		error('Unknown ELF type', 2)
	end
	return nil, nil
	--return loadstring(table.concat(sBytes))
end

function run(sBytes, ...)
	verify(sBytes)
	local tArgs = {...}
	local func, baseargs = runf(sBytes)
	--print('Success!')
	if tArgs == {} or table.concat(tArgs) == '' then
		for arg in string.gmatch(baseargs, '[^ \t\r\n\f]+') do
			tArgs[#tArgs+1] = arg
		end
	end
	return pcall(func,unpack(tArgs))
end
 
--loadfile(args[1])(select(2,unpack(args)))

local code = [[
tArgs = {...}
print('----------')
print(textutils.serialize(tArgs))
print("Hello World!")
print('kek')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
write('')
]]
print('Compiling..')
local bCode = compile(code, 'CLF')
--print(#bCode)
print('Running code...')
run(bCode)