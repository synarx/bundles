local Signal = require(script.Parent.Signal)

local Value = {}
Value.__index = Value

function Value.new(Initial)
	local self = setmetatable({}, Value)
	self.Changed = Signal.new()
	self.Value = Initial
	self._IsStoring = false

	return self
end

function Value:StoreValue(NewValue)
	if NewValue ~= nil then
		self:Set(NewValue)
	end
	self._IsStoring = true
end

function Value:ReleaseValue(Fallback)
	self._IsStoring = false
	if self._StoredValue == nil and Fallback ~= nil then
		self:Set(Fallback)
		return
	end
	if self._StoredValue ~= nil then
		self:Set(self._StoredValue)
		self._StoredValue = nil
	end
end

function Value:Set(NewValue)
	if self._IsStoring then
		self._StoredValue = NewValue
		return
	end

	self.Value = NewValue
	self.Changed:Fire(NewValue)

	--print(NewValue, debug.traceback("\n", 2))
end

return Value