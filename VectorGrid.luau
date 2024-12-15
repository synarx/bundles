local VectorGrid = {}
VectorGrid.__index = VectorGrid

function Snap(Vector, Size)
	return Vector3.new(math.round(Vector.X / Size.X), math.round(Vector.Y / Size.Y), math.round(Vector.Z / Size.Z)) * Size
end

function VectorGrid.new(CellSize)
	if not CellSize then error("CellSize not specified!", 2) end
	if typeof(CellSize) == "number" then CellSize = Vector3.one * CellSize end
	if typeof(CellSize) ~= "Vector3" then error("CellSize is not a valid number or Vector3!", 2) end

	local self = setmetatable({}, VectorGrid)
	self.Size = CellSize
	self.Grid = {}
	return self
end

function VectorGrid:Set(Vector, Value)
	local Cell = Snap(Vector, self.Size)
	if not self.Grid[Cell.X] then
		self.Grid[Cell.X] = {}
	end
	if not self.Grid[Cell.X][Cell.Y] then
		self.Grid[Cell.X][Cell.Y] = {}
	end
	self.Grid[Cell.X][Cell.Y][Cell.Z] = Value
end

function VectorGrid:Get(Vector)
	local Cell = Snap(Vector, self.Size)
	if self.Grid[Cell.X] then
		if self.Grid[Cell.X][Cell.Y] then
			return self.Grid[Cell.X][Cell.Y][Cell.Z]
		end
	end
end

function VectorGrid:GetSurrounding(Vector)
	local Cell = Snap(Vector, self.Size)
	local Result = {}
	for _, Face in Enum.NormalId:GetEnumItems() do
		local Direction = Vector3.FromNormalId(Face)
		local Position = Vector + (Direction * self.Size)
		local SurroundingValue = self:Get(Position)
		if SurroundingValue then
			table.insert(Result, {
				Face = Face,
				Direction = Direction,
				Position = Position,
				Value = SurroundingValue,
			})
		end
	end
	return Result
end

function VectorGrid:GetDescendants() 
	local Descendants = {}
	for X, XData in self.Grid do
		for Y, YData in XData do
			for Z, Value in YData do
				Descendants[Vector3.new(X, Y, Z)] = Value
			end
		end
	end
	return Descendants
end

return VectorGrid