local GreedyMesher = {}

local V3 = Vector3.new

function Find(T, X, Z, Y)
	local XD = T[X]
	if XD then
		local ZD = XD[Z]
		if ZD then
			return ZD[Y]
		end
	end
	return
end

function MeshRow(T, SX, EX, Z, Y, BL)
	local Result = {}
	for X = SX, EX do
		local Voxel = Find(T, X, Z, Y)
		if (not Voxel) or BL[Voxel] then return end
		table.insert(Result, Voxel)		
	end
	return Result
end

function MeshLayer(T, SX, SZ, EX, EZ, Y, BL)
	local Result = {}
	for Z = SZ, EZ do
		local Row = MeshRow(T, SX, EX, Z, Y, BL)
		if Row then
			table.insert(Result, Row)
		else return end
	end
	return Result
end

local function GreedyChunk(T, SX, SY, SZ, EX, EY, EZ, BL)
	local CX, CY, CZ = SX, SY, SZ

	for X = SX + 1, EX do
		local Voxel = Find(T, X, SZ, SY)
		if Voxel and not BL[Voxel] then
			BL[Voxel] = true
			CX = X
		else
			break
		end
	end

	local ZAdj = Find(T, SX, SZ + 1, SY)
	if ZAdj and not BL[ZAdj] then
		for Z = SZ + 1, EZ do
			local Row = MeshRow(T, SX, CX, Z, SY, BL)
			if Row then
				CZ = Z
				for _, V in ipairs(Row) do
					BL[V] = true
				end
			else
				break
			end
		end
	end

	local YAdj = Find(T, SX, SZ, SY + 1)
	if YAdj and not BL[YAdj] then
		for Y = SY + 1, EY do
			local Layer = MeshLayer(T, SX, SZ, CX, CZ, Y, BL)
			if Layer then
				CY = Y
				for _, VG in ipairs(Layer) do
					for _, V in ipairs(VG) do
						BL[V] = true
					end
				end
			else
				break
			end
		end
	end

	return V3(SX, SY, SZ), V3(CX, CY, CZ)
end

function GreedyMesher.GreedyMesh(T, SV3, EV3)
	local BL = {}
	local Result = {}
	local SX, SY, SZ = SV3.X, SV3.Y, SV3.Z
	local EX, EY, EZ = EV3.X, EV3.Y, EV3.Z
	for X = SX, EX do
		for Z = SZ, EZ do
			for Y = SY, EY do
				local Voxel = Find(T, X, Z, Y)
				if Voxel and not BL[Voxel] then
					BL[Voxel] = true
					table.insert(Result, {GreedyChunk(T, X, Y, Z, EX, EY, EZ, BL)})
				end
			end
		end
	end
	return Result
end

return GreedyMesher