--[[
Types of packages:
PKG: Base package
PXG: Self-extracting
XKG: Self-executable (Runs the programs inside of it without extracting)
P64: PKG + Base64 encoding
UKG: Uncompressed (raw) package
PKF: Individual file, ready to be packed
AKG: Alternate compression method !EXPERIMENTAL!

Archive structure:
TYPE|VERSION|CRC32|FILESYSTEM

NOTE: FILESYSTEM can differ depending on the type of package. CRC is of the payload, not the uncompressed data.

NOTE: Files support partial compression.
Individual file structure:
PATH|VERSION|CRC32|UNCOMPRESSED SIZE|COMPRESSED DATA|,,,|UNCOMPRESSED DATA|;;;|
Weird splitters are to ensure no collisions.

NOTE: function pkg.pack()
tFiles is a table that is ordered as such:
['relative path'] = 'data'
]]

require('api/crc32.lua')
require('api/libcompress.lua')

version = '1.0'

function packFile(path, data, percentage)
	if not percentage or type(percentage) ~= 'number' or percentage < 0 or percentage > 100 then local percentage = 100 end --this is the compression percentage of each file
	percentage = math.floor(percentage) --ensure integer
	
	local s = path .. '|' .. version .. '|' .. crc32.hash(data) .. '|' .. #data .. '|' --final product
	local cutoff = math.floor(#data * percentage / 100) --where the data will be split between compressed and uncompressed
	
	if percentage > 0 then
		s = s .. LibCompress:Compress(data:sub(1, percentage == 100 and #data or cutoff))
	end
	s = s .. '|,,,|'
	
	if percentage < 100 then
		s = s .. data:sub(cutoff + 1)
	end
	s = s .. '|;;;|'
	
	return s
end

local oldType = type
function pack(type, tFiles, percentage)
	if not percentage or oldType(percentage) ~= 'number' or percentage < 0 or percentage > 100 then local percentage = 100 end --this is the compression percentage of each file
	percentage = math.floor(percentage) --ensure integer
	
	local s = type .. '|' .. version .. '|' --final product
	
	local temp = ''
	for path,data in pairs(tFiles) do
		temp = temp .. packFile(path, data, percentage)
	end
	
	return s .. crc32.hash(temp) .. '|' .. temp
end

local oldUnpack = unpack
function unpack()
	
end

function unpackFile()
	
end