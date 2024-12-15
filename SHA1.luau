local band = bit32.band
local bor = bit32.bor
local bxor = bit32.bxor
local lrotate = bit32.lrotate

local sbyte = string.byte
local schar = string.char
local sformat = string.format
local srep = string.rep

function bytes_to_uint32(a, b, c, d)
	return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

function uint32_to_bytes(a)
	local a4 = a % 256
	a = (a - a4) / 256
	local a3 = a % 256
	a = (a - a3) / 256
	local a2 = a % 256
	local a1 = (a - a2) / 256
	return a1, a2, a3, a4
end


function uint32_ternary(a, b, c)
	return bxor(c, band(a, bxor(b, c)))
end

function uint32_majority(a, b, c)
	return bor(band(a, bor(b, c)), band(b, c))
end

function sha1(str)
	local first_append = schar(0x80)
	local non_zero_message_bytes = #str + 1 + 8
	local second_append = srep(schar(0), -non_zero_message_bytes % 64)
	local third_append = schar(0, 0, 0, 0, uint32_to_bytes(#str * 8))
	str = str .. first_append .. second_append .. third_append
	local h0 = 0x67452301
	local h1 = 0xEFCDAB89
	local h2 = 0x98BADCFE
	local h3 = 0x10325476
	local h4 = 0xC3D2E1F0
	local w = {}
	for chunk_start = 1, #str, 64 do
		local uint32_start = chunk_start
		for i = 0, 15 do
			w[i] = bytes_to_uint32(sbyte(str, uint32_start, uint32_start + 3))
			uint32_start = uint32_start + 4
		end
		for i = 16, 79 do
			w[i] = lrotate(bxor(w[i - 3], w[i - 8], w[i - 14], w[i - 16]), 1)
		end
		local a = h0
		local b = h1
		local c = h2
		local d = h3
		local e = h4
		for i = 0, 79 do
			local f
			local k

			if i <= 19 then
				f = uint32_ternary(b, c, d)
				k = 0x5A827999
			elseif i <= 39 then
				f = bxor(b, c, d)
				k = 0x6ED9EBA1
			elseif i <= 59 then
				f = uint32_majority(b, c, d)
				k = 0x8F1BBCDC
			else
				f = bxor(b, c, d)
				k = 0xCA62C1D6
			end
			local temp = (lrotate(a, 5) + f + e + k + w[i]) % 4294967296
			e = d
			d = c
			c = lrotate(b, 30)
			b = a
			a = temp
		end
		h0 = (h0 + a) % 4294967296
		h1 = (h1 + b) % 4294967296
		h2 = (h2 + c) % 4294967296
		h3 = (h3 + d) % 4294967296
		h4 = (h4 + e) % 4294967296
	end
	return sformat("%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4)
end

return sha1