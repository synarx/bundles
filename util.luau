warn("UTIL IS A DEPRECATED MODULE AND SHOULD NOT BE USED - CONSIDER USING SEPERATE MODULES INSTEAD")

local exp = math.exp
local sin = math.sin
local sqrt = math.sqrt
local cos = math.cos
local Spring = {}
function Spring.new(initial, clock)
	local target = initial or 0
	clock = clock or os.clock
	return setmetatable({
		_clock = clock;
		_time0 = clock();
		_position0 = target;
		_velocity0 = 0*target;
		_target = target;
		_damper = 1;
		_speed = 1;
	}, Spring)
end
function Spring:Impulse(velocity)
	self.Velocity = self.Velocity + velocity
end
function Spring:TimeSkip(delta)
	local now = self._clock()
	local position, velocity = self:_positionVelocity(now+delta)
	self._position0 = position
	self._velocity0 = velocity
	self._time0 = now
end
function Spring:__index(index)
	if Spring[index] then
		return Spring[index]
	elseif index == "Value" or index == "Position" or index == "p" then
		local position, _ = self:_positionVelocity(self._clock())
		return position
	elseif index == "Velocity" or index == "v" then
		local _, velocity = self:_positionVelocity(self._clock())
		return velocity
	elseif index == "Target" or index == "t" then
		return self._target
	elseif index == "Damper" or index == "d" then
		return self._damper
	elseif index == "Speed" or index == "s" then
		return self._speed
	elseif index == "Clock" then
		return self._clock
	else
		error(("%q is not a valid member of Spring"):format(tostring(index)), 2)
	end
end
function Spring:__newindex(index, value)
	local now = self._clock()

	if index == "Value" or index == "Position" or index == "p" then
		local _, velocity = self:_positionVelocity(now)
		self._position0 = value
		self._velocity0 = velocity
		self._time0 = now
	elseif index == "Velocity" or index == "v" then
		local position, _ = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = value
		self._time0 = now
	elseif index == "Target" or index == "t" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._target = value
		self._time0 = now
	elseif index == "Damper" or index == "d" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._damper = value
		self._time0 = now
	elseif index == "Speed" or index == "s" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._speed = value < 0 and 0 or value
		self._time0 = now
	elseif index == "Clock" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._clock = value
		self._time0 = value()
	end
end
function Spring:_positionVelocity(now)
	local p0 = self._position0
	local v0 = self._velocity0
	local p1 = self._target
	local d = self._damper
	local s = self._speed
	local t = s*(now - self._time0)
	local d2 = d*d
	local h, si, co
	if d2 < 1 then
		h = sqrt(1 - d2)
		local ep = exp(-d*t)/h
		co, si = ep*cos(h*t), ep*sin(h*t)
	elseif d2 == 1 then
		h = 1
		local ep = exp(-d*t)/h
		co, si = ep, ep*t
	else
		h = sqrt(d2 - 1)
		local u = exp((-d + h)*t)/(2*h)
		local v = exp((-d - h)*t)/(2*h)
		co, si = u + v, u - v
	end
	return (h*co + d*si)*p0 + (1 - (h*co + d*si))*p1 + si/s*v0, (-s*si)*p0 + (s*si)*p1 + (h*co - d*si)*v0
end
local Roact
do
	local modules_fake = {}
	local script = {Parent = modules_fake}
	local cache = {}
	modules_fake.Parent = modules_fake
	modules_fake.PropMarkers = modules_fake
	local function require(m) if not cache[m] then cache[m] = m() end return cache[m] end
	modules_fake["Change"] = (function()
--[[
	Change is used to generate special prop keys that can be used to connect to
	GetPropertyChangedSignal.

	Generally, Change is indexed by a Roblox property name:

		Roact.createElement("TextBox", {
			[Roact.Change.Text] = function(rbx)
				print("The TextBox", rbx, "changed text to", rbx.Text)
			end,
		})
]]

		local Type = require(script.Parent.Parent.Type)

		local Change = {}

		local changeMetatable = {
			__tostring = function(self)
				return ("RoactHostChangeEvent(%s)"):format(self.name)
			end,
		}

		setmetatable(Change, {
			__index = function(_self, propertyName)
				local changeListener = {
					[Type] = Type.HostChangeEvent,
					name = propertyName,
				}

				setmetatable(changeListener, changeMetatable)
				Change[propertyName] = changeListener

				return changeListener
			end,
		})

		return Change

	end)
	modules_fake["Children"] = (function()
		local Symbol = require(script.Parent.Parent.Symbol)

		local Children = Symbol.named("Children")

		return Children

	end)
	modules_fake["Event"] = (function()
--[[
	Index into `Event` to get a prop key for attaching to an event on a Roblox
	Instance.

	Example:

		Roact.createElement("TextButton", {
			Text = "Hello, world!",

			[Roact.Event.MouseButton1Click] = function(rbx)
				print("Clicked", rbx)
			end
		})
]]

		local Type = require(script.Parent.Parent.Type)

		local Event = {}

		local eventMetatable = {
			__tostring = function(self)
				return ("RoactHostEvent(%s)"):format(self.name)
			end,
		}

		setmetatable(Event, {
			__index = function(_self, eventName)
				local event = {
					[Type] = Type.HostEvent,
					name = eventName,
				}

				setmetatable(event, eventMetatable)

				Event[eventName] = event

				return event
			end,
		})

		return Event

	end)
	modules_fake["Ref"] = (function()
		local Symbol = require(script.Parent.Parent.Symbol)

		local Ref = Symbol.named("Ref")

		return Ref

	end)

	modules_fake["Component"] = (function()
		local assign = require(script.Parent.assign)
		local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)
		local Type = require(script.Parent.Type)
		local Symbol = require(script.Parent.Symbol)
		local invalidSetStateMessages = require(script.Parent.invalidSetStateMessages)
		local internalAssert = require(script.Parent.internalAssert)

		local config = require(script.Parent.GlobalConfig).get()

--[[
	Calling setState during certain lifecycle allowed methods has the potential
	to create an infinitely updating component. Rather than time out, we exit
	with an error if an unreasonable number of self-triggering updates occur
]]
		local MAX_PENDING_UPDATES = 100

		local InternalData = Symbol.named("InternalData")

		local componentMissingRenderMessage = [[
The component %q is missing the `render` method.
`render` must be defined when creating a Roact component!]]

		local tooManyUpdatesMessage = [[
The component %q has reached the setState update recursion limit.
When using `setState` in `didUpdate`, make sure that it won't repeat infinitely!]]

		local componentClassMetatable = {}

		function componentClassMetatable:__tostring()
			return self.__componentName
		end

		local Component = {}
		setmetatable(Component, componentClassMetatable)

		Component[Type] = Type.StatefulComponentClass
		Component.__index = Component
		Component.__componentName = "Component"

--[[
	A method called by consumers of Roact to create a new component class.
	Components can not be extended beyond this point, with the exception of
	PureComponent.
]]
		function Component:extend(name)
			if config.typeChecks then
				assert(Type.of(self) == Type.StatefulComponentClass, "Invalid `self` argument to `extend`.")
				assert(typeof(name) == "string", "Component class name must be a string")
			end

			local class = {}

			for key, value in pairs(self) do
				-- Roact opts to make consumers use composition over inheritance, which
				-- lines up with React.
				-- https://reactjs.org/docs/composition-vs-inheritance.html
				if key ~= "extend" then
					class[key] = value
				end
			end

			class[Type] = Type.StatefulComponentClass
			class.__index = class
			class.__componentName = name

			setmetatable(class, componentClassMetatable)

			return class
		end

		function Component:__getDerivedState(incomingProps, incomingState)
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__getDerivedState`")
			end

			local internalData = self[InternalData]
			local componentClass = internalData.componentClass

			if componentClass.getDerivedStateFromProps ~= nil then
				local derivedState = componentClass.getDerivedStateFromProps(incomingProps, incomingState)

				if derivedState ~= nil then
					if config.typeChecks then
						assert(typeof(derivedState) == "table", "getDerivedStateFromProps must return a table!")
					end

					return derivedState
				end
			end

			return nil
		end

		function Component:setState(mapState)
			if config.typeChecks then
				assert(Type.of(self) == Type.StatefulComponentInstance, "Invalid `self` argument to `extend`.")
			end

			local internalData = self[InternalData]
			local lifecyclePhase = internalData.lifecyclePhase

	--[[
		When preparing to update, rendering, or unmounting, it is not safe
		to call `setState` as it will interfere with in-flight updates. It's
		also disallowed during unmounting
	]]
			if
				lifecyclePhase == ComponentLifecyclePhase.ShouldUpdate
				or lifecyclePhase == ComponentLifecyclePhase.WillUpdate
				or lifecyclePhase == ComponentLifecyclePhase.Render
				or lifecyclePhase == ComponentLifecyclePhase.WillUnmount
			then
				local messageTemplate = invalidSetStateMessages[internalData.lifecyclePhase]

				local message = messageTemplate:format(tostring(internalData.componentClass))

				error(message, 2)
			end

			local pendingState = internalData.pendingState

			local partialState
			if typeof(mapState) == "function" then
				partialState = mapState(pendingState or self.state, self.props)

				-- Abort the state update if the given state updater function returns nil
				if partialState == nil then
					return
				end
			elseif typeof(mapState) == "table" then
				partialState = mapState
			else
				error("Invalid argument to setState, expected function or table", 2)
			end

			local newState
			if pendingState ~= nil then
				newState = assign(pendingState, partialState)
			else
				newState = assign({}, self.state, partialState)
			end

			if lifecyclePhase == ComponentLifecyclePhase.Init then
				-- If `setState` is called in `init`, we can skip triggering an update!
				local derivedState = self:__getDerivedState(self.props, newState)
				self.state = assign(newState, derivedState)
			elseif
				lifecyclePhase == ComponentLifecyclePhase.DidMount
				or lifecyclePhase == ComponentLifecyclePhase.DidUpdate
				or lifecyclePhase == ComponentLifecyclePhase.ReconcileChildren
			then
		--[[
			During certain phases of the component lifecycle, it's acceptable to
			allow `setState` but defer the update until we're done with ones in flight.
			We do this by collapsing it into any pending updates we have.
		]]
				local derivedState = self:__getDerivedState(self.props, newState)
				internalData.pendingState = assign(newState, derivedState)
			elseif lifecyclePhase == ComponentLifecyclePhase.Idle then
				-- Outside of our lifecycle, the state update is safe to make immediately
				self:__update(nil, newState)
			else
				local messageTemplate = invalidSetStateMessages.default

				local message = messageTemplate:format(tostring(internalData.componentClass))

				error(message, 2)
			end
		end

--[[
	Returns the stack trace of where the element was created that this component
	instance's properties are based on.

	Intended to be used primarily by diagnostic tools.
]]
		function Component:getElementTraceback()
			return self[InternalData].virtualNode.currentElement.source
		end

--[[
	Returns a snapshot of this component given the current props and state. Must
	be overridden by consumers of Roact and should be a pure function with
	regards to props and state.

	TODO (#199): Accept props and state as arguments.
]]
		function Component:render()
			local internalData = self[InternalData]

			local message = componentMissingRenderMessage:format(tostring(internalData.componentClass))

			error(message, 0)
		end

--[[
	Retrieves the context value corresponding to the given key. Can return nil
	if a requested context key is not present
]]
		function Component:__getContext(key)
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__getContext`")
				internalAssert(key ~= nil, "Context key cannot be nil")
			end

			local virtualNode = self[InternalData].virtualNode
			local context = virtualNode.context

			return context[key]
		end

--[[
	Adds a new context entry to this component's context table (which will be
	passed down to child components).
]]
		function Component:__addContext(key, value)
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__addContext`")
			end
			local virtualNode = self[InternalData].virtualNode

			-- Make sure we store a reference to the component's original, unmodified
			-- context the virtual node. In the reconciler, we'll restore the original
			-- context if we need to replace the node (this happens when a node gets
			-- re-rendered as a different component)
			if virtualNode.originalContext == nil then
				virtualNode.originalContext = virtualNode.context
			end

			-- Build a new context table on top of the existing one, then apply it to
			-- our virtualNode
			local existing = virtualNode.context
			virtualNode.context = assign({}, existing, { [key] = value })
		end

--[[
	Performs property validation if the static method validateProps is declared.
	validateProps should follow assert's expected arguments:
	(false, message: string) | true. The function may return a message in the
	true case; it will be ignored. If this fails, the function will throw the
	error.
]]
		function Component:__validateProps(props)
			if not config.propValidation then
				return
			end

			local validator = self[InternalData].componentClass.validateProps

			if validator == nil then
				return
			end

			if typeof(validator) ~= "function" then
				error(
					("validateProps must be a function, but it is a %s.\nCheck the definition of the component %q."):format(
					typeof(validator),
					self.__componentName
					)
				)
			end

			local success, failureReason = validator(props)

			if not success then
				failureReason = failureReason or "<Validator function did not supply a message>"
				error(
					("Property validation failed in %s: %s\n\n%s"):format(
					self.__componentName,
					tostring(failureReason),
					self:getElementTraceback() or "<enable element tracebacks>"
					),
					0
				)
			end
		end

--[[
	An internal method used by the reconciler to construct a new component
	instance and attach it to the given virtualNode.
]]
		function Component:__mount(reconciler, virtualNode)
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentClass, "Invalid use of `__mount`")
				internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #2 to be of type VirtualNode")
			end

			local currentElement = virtualNode.currentElement
			local hostParent = virtualNode.hostParent

			-- Contains all the information that we want to keep from consumers of
			-- Roact, or even other parts of the codebase like the reconciler.
			local internalData = {
				reconciler = reconciler,
				virtualNode = virtualNode,
				componentClass = self,
				lifecyclePhase = ComponentLifecyclePhase.Init,
			}

			local instance = {
				[Type] = Type.StatefulComponentInstance,
				[InternalData] = internalData,
			}

			setmetatable(instance, self)

			virtualNode.instance = instance

			local props = currentElement.props

			if self.defaultProps ~= nil then
				props = assign({}, self.defaultProps, props)
			end

			instance:__validateProps(props)

			instance.props = props

			local newContext = assign({}, virtualNode.legacyContext)
			instance._context = newContext

			instance.state = assign({}, instance:__getDerivedState(instance.props, {}))

			if instance.init ~= nil then
				instance:init(instance.props)
				assign(instance.state, instance:__getDerivedState(instance.props, instance.state))
			end

			-- It's possible for init() to redefine _context!
			virtualNode.legacyContext = instance._context

			internalData.lifecyclePhase = ComponentLifecyclePhase.Render
			local renderResult = instance:render()

			internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren
			reconciler.updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)

			if instance.didMount ~= nil then
				internalData.lifecyclePhase = ComponentLifecyclePhase.DidMount
				instance:didMount()
			end

			if internalData.pendingState ~= nil then
				-- __update will handle pendingState, so we don't pass any new element or state
				instance:__update(nil, nil)
			end

			internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
		end

--[[
	Internal method used by the reconciler to clean up any resources held by
	this component instance.
]]
		function Component:__unmount()
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__unmount`")
			end

			local internalData = self[InternalData]
			local virtualNode = internalData.virtualNode
			local reconciler = internalData.reconciler

			if self.willUnmount ~= nil then
				internalData.lifecyclePhase = ComponentLifecyclePhase.WillUnmount
				self:willUnmount()
			end

			for _, childNode in pairs(virtualNode.children) do
				reconciler.unmountVirtualNode(childNode)
			end
		end

--[[
	Internal method used by setState (to trigger updates based on state) and by
	the reconciler (to trigger updates based on props)

	Returns true if the update was completed, false if it was cancelled by shouldUpdate
]]
		function Component:__update(updatedElement, updatedState)
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__update`")
				internalAssert(
					Type.of(updatedElement) == Type.Element or updatedElement == nil,
					"Expected arg #1 to be of type Element or nil"
				)
				internalAssert(
					typeof(updatedState) == "table" or updatedState == nil,
					"Expected arg #2 to be of type table or nil"
				)
			end

			local internalData = self[InternalData]
			local componentClass = internalData.componentClass

			local newProps = self.props
			if updatedElement ~= nil then
				newProps = updatedElement.props

				if componentClass.defaultProps ~= nil then
					newProps = assign({}, componentClass.defaultProps, newProps)
				end

				self:__validateProps(newProps)
			end

			local updateCount = 0
			repeat
				local finalState
				local pendingState = nil

				-- Consume any pending state we might have
				if internalData.pendingState ~= nil then
					pendingState = internalData.pendingState
					internalData.pendingState = nil
				end

				-- Consume a standard update to state or props
				if updatedState ~= nil or newProps ~= self.props then
					if pendingState == nil then
						finalState = updatedState or self.state
					else
						finalState = assign(pendingState, updatedState)
					end

					local derivedState = self:__getDerivedState(newProps, finalState)

					if derivedState ~= nil then
						finalState = assign({}, finalState, derivedState)
					end

					updatedState = nil
				else
					finalState = pendingState
				end

				if not self:__resolveUpdate(newProps, finalState) then
					-- If the update was short-circuited, bubble the result up to the caller
					return false
				end

				updateCount = updateCount + 1

				if updateCount > MAX_PENDING_UPDATES then
					error(tooManyUpdatesMessage:format(tostring(internalData.componentClass)), 3)
				end
			until internalData.pendingState == nil

			return true
		end

--[[
	Internal method used by __update to apply new props and state

	Returns true if the update was completed, false if it was cancelled by shouldUpdate
]]
		function Component:__resolveUpdate(incomingProps, incomingState)
			if config.internalTypeChecks then
				internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__resolveUpdate`")
			end

			local internalData = self[InternalData]
			local virtualNode = internalData.virtualNode
			local reconciler = internalData.reconciler

			local oldProps = self.props
			local oldState = self.state

			if incomingProps == nil then
				incomingProps = oldProps
			end
			if incomingState == nil then
				incomingState = oldState
			end

			if self.shouldUpdate ~= nil then
				internalData.lifecyclePhase = ComponentLifecyclePhase.ShouldUpdate
				local continueWithUpdate = self:shouldUpdate(incomingProps, incomingState)

				if not continueWithUpdate then
					internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
					return false
				end
			end

			if self.willUpdate ~= nil then
				internalData.lifecyclePhase = ComponentLifecyclePhase.WillUpdate
				self:willUpdate(incomingProps, incomingState)
			end

			internalData.lifecyclePhase = ComponentLifecyclePhase.Render

			self.props = incomingProps
			self.state = incomingState

			local renderResult = virtualNode.instance:render()

			internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren
			reconciler.updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, renderResult)

			if self.didUpdate ~= nil then
				internalData.lifecyclePhase = ComponentLifecyclePhase.DidUpdate
				self:didUpdate(oldProps, oldState)
			end

			internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
			return true
		end

		return Component

	end)
	modules_fake["ComponentLifecyclePhase"] = (function()
		local Symbol = require(script.Parent.Symbol)
		local strict = require(script.Parent.strict)

		local ComponentLifecyclePhase = strict({
			-- Component methods
			Init = Symbol.named("init"),
			Render = Symbol.named("render"),
			ShouldUpdate = Symbol.named("shouldUpdate"),
			WillUpdate = Symbol.named("willUpdate"),
			DidMount = Symbol.named("didMount"),
			DidUpdate = Symbol.named("didUpdate"),
			WillUnmount = Symbol.named("willUnmount"),

			-- Phases describing reconciliation status
			ReconcileChildren = Symbol.named("reconcileChildren"),
			Idle = Symbol.named("idle"),
		}, "ComponentLifecyclePhase")

		return ComponentLifecyclePhase

	end)
	modules_fake["Config"] = (function()
--[[
	Exposes an interface to set global configuration values for Roact.

	Configuration can only occur once, and should only be done by an application
	using Roact, not a library.

	Any keys that aren't recognized will cause errors. Configuration is only
	intended for configuring Roact itself, not extensions or libraries.

	Configuration is expected to be set immediately after loading Roact. Setting
	configuration values after an application starts may produce unpredictable
	behavior.
]]

		-- Every valid configuration value should be non-nil in this table.
		local defaultConfig = {
			-- Enables asserts for internal Roact APIs. Useful for debugging Roact itself.
			["internalTypeChecks"] = false,
			-- Enables stricter type asserts for Roact's public API.
			["typeChecks"] = false,
			-- Enables storage of `debug.traceback()` values on elements for debugging.
			["elementTracing"] = false,
			-- Enables validation of component props in stateful components.
			["propValidation"] = false,
		}

		-- Build a list of valid configuration values up for debug messages.
		local defaultConfigKeys = {}
		for key in pairs(defaultConfig) do
			table.insert(defaultConfigKeys, key)
		end

		local Config = {}

		function Config.new()
			local self = {}

			self._currentConfig = setmetatable({}, {
				__index = function(_, key)
					local message = ("Invalid global configuration key %q. Valid configuration keys are: %s"):format(
					tostring(key),
					table.concat(defaultConfigKeys, ", ")
					)

					error(message, 3)
				end,
			})

			-- We manually bind these methods here so that the Config's methods can be
			-- used without passing in self, since they eventually get exposed on the
			-- root Roact object.
			self.set = function(...)
				return Config.set(self, ...)
			end

			self.get = function(...)
				return Config.get(self, ...)
			end

			self.scoped = function(...)
				return Config.scoped(self, ...)
			end

			self.set(defaultConfig)

			return self
		end

		function Config:set(configValues)
			-- Validate values without changing any configuration.
			-- We only want to apply this configuration if it's valid!
			for key, value in pairs(configValues) do
				if defaultConfig[key] == nil then
					local message = ("Invalid global configuration key %q (type %s). Valid configuration keys are: %s"):format(
					tostring(key),
					typeof(key),
					table.concat(defaultConfigKeys, ", ")
					)

					error(message, 3)
				end

				-- Right now, all configuration values must be boolean.
				if typeof(value) ~= "boolean" then
					local message = (
						"Invalid value %q (type %s) for global configuration key %q. Valid values are: true, false"
					):format(tostring(value), typeof(value), tostring(key))

					error(message, 3)
				end

				self._currentConfig[key] = value
			end
		end

		function Config:get()
			return self._currentConfig
		end

		function Config:scoped(configValues, callback)
			local previousValues = {}
			for key, value in pairs(self._currentConfig) do
				previousValues[key] = value
			end

			self.set(configValues)

			local success, result = pcall(callback)

			self.set(previousValues)

			assert(success, result)
		end

		return Config

	end)
	modules_fake["ElementKind"] = (function()
--[[
	Contains markers for annotating the type of an element.

	Use `ElementKind` as a key, and values from it as the value.

		local element = {
			[ElementKind] = ElementKind.Host,
		}
]]

		local Symbol = require(script.Parent.Symbol)
		local strict = require(script.Parent.strict)
		local Portal = require(script.Parent.Portal)

		local ElementKind = newproxy(true)

		local ElementKindInternal = {
			Portal = Symbol.named("Portal"),
			Host = Symbol.named("Host"),
			Function = Symbol.named("Function"),
			Stateful = Symbol.named("Stateful"),
			Fragment = Symbol.named("Fragment"),
		}

		function ElementKindInternal.of(value)
			if typeof(value) ~= "table" then
				return nil
			end

			return value[ElementKind]
		end

		local componentTypesToKinds = {
			["string"] = ElementKindInternal.Host,
			["function"] = ElementKindInternal.Function,
			["table"] = ElementKindInternal.Stateful,
		}

		function ElementKindInternal.fromComponent(component)
			if component == Portal then
				return ElementKind.Portal
			else
				return componentTypesToKinds[typeof(component)]
			end
		end

		getmetatable(ElementKind).__index = ElementKindInternal

		strict(ElementKindInternal, "ElementKind")

		return ElementKind

	end)
	modules_fake["ElementUtils"] = (function()
		local Type = require(script.Parent.Type)
		local Symbol = require(script.Parent.Symbol)

		local function noop()
			return nil
		end

		local ElementUtils = {}

--[[
	A signal value indicating that a child should use its parent's key, because
	it has no key of its own.

	This occurs when you return only one element from a function component or
	stateful render function.
]]
		ElementUtils.UseParentKey = Symbol.named("UseParentKey")

--[[
	Returns an iterator over the children of an element.
	`elementOrElements` may be one of:
	* a boolean
	* nil
	* a single element
	* a fragment
	* a table of elements

	If `elementOrElements` is a boolean or nil, this will return an iterator with
	zero elements.

	If `elementOrElements` is a single element, this will return an iterator with
	one element: a tuple where the first value is ElementUtils.UseParentKey, and
	the second is the value of `elementOrElements`.

	If `elementOrElements` is a fragment or a table, this will return an iterator
	over all the elements of the array.

	If `elementOrElements` is none of the above, this function will throw.
]]
		function ElementUtils.iterateElements(elementOrElements)
			local richType = Type.of(elementOrElements)

			-- Single child
			if richType == Type.Element then
				local called = false

				return function()
					if called then
						return nil
					else
						called = true
						return ElementUtils.UseParentKey, elementOrElements
					end
				end
			end

			local regularType = typeof(elementOrElements)

			if elementOrElements == nil or regularType == "boolean" then
				return noop
			end

			if regularType == "table" then
				return pairs(elementOrElements)
			end

			error("Invalid elements")
		end

--[[
	Gets the child corresponding to a given key, respecting Roact's rules for
	children. Specifically:
	* If `elements` is nil or a boolean, this will return `nil`, regardless of
		the key given.
	* If `elements` is a single element, this will return `nil`, unless the key
		is ElementUtils.UseParentKey.
	* If `elements` is a table of elements, this will return `elements[key]`.
]]
		function ElementUtils.getElementByKey(elements, hostKey)
			if elements == nil or typeof(elements) == "boolean" then
				return nil
			end

			if Type.of(elements) == Type.Element then
				if hostKey == ElementUtils.UseParentKey then
					return elements
				end

				return nil
			end

			if typeof(elements) == "table" then
				return elements[hostKey]
			end

			error("Invalid elements")
		end

		return ElementUtils

	end)
	modules_fake["GlobalConfig"] = (function()
--[[
	Exposes a single instance of a configuration as Roact's GlobalConfig.
]]

		local Config = require(script.Parent.Config)

		return Config.new()

	end)
	modules_fake["Logging"] = (function()
--[[
	Centralized place to handle logging. Lets us:
	- Unit test log output via `Logging.capture`
	- Disable verbose log messages when not debugging Roact

	This should be broken out into a separate library with the addition of
	scoping and logging configuration.
]]

		-- Determines whether log messages will go to stdout/stderr
		local outputEnabled = true

		-- A set of LogInfo objects that should have messages inserted into them.
		-- This is a set so that nested calls to Logging.capture will behave.
		local collectors = {}

		-- A set of all stack traces that have called warnOnce.
		local onceUsedLocations = {}

--[[
	Indent a potentially multi-line string with the given number of tabs, in
	addition to any indentation the string already has.
]]
		local function indent(source, indentLevel)
			local indentString = ("\t"):rep(indentLevel)

			return indentString .. source:gsub("\n", "\n" .. indentString)
		end

--[[
	Indents a list of strings and then concatenates them together with newlines
	into a single string.
]]
		local function indentLines(lines, indentLevel)
			local outputBuffer = {}

			for _, line in ipairs(lines) do
				table.insert(outputBuffer, indent(line, indentLevel))
			end

			return table.concat(outputBuffer, "\n")
		end

		local logInfoMetatable = {}

--[[
	Automatic coercion to strings for LogInfo objects to enable debugging them
	more easily.
]]
		function logInfoMetatable:__tostring()
			local outputBuffer = { "LogInfo {" }

			local errorCount = #self.errors
			local warningCount = #self.warnings
			local infosCount = #self.infos

			if errorCount + warningCount + infosCount == 0 then
				table.insert(outputBuffer, "\t(no messages)")
			end

			if errorCount > 0 then
				table.insert(outputBuffer, ("\tErrors (%d) {"):format(errorCount))
				table.insert(outputBuffer, indentLines(self.errors, 2))
				table.insert(outputBuffer, "\t}")
			end

			if warningCount > 0 then
				table.insert(outputBuffer, ("\tWarnings (%d) {"):format(warningCount))
				table.insert(outputBuffer, indentLines(self.warnings, 2))
				table.insert(outputBuffer, "\t}")
			end

			if infosCount > 0 then
				table.insert(outputBuffer, ("\tInfos (%d) {"):format(infosCount))
				table.insert(outputBuffer, indentLines(self.infos, 2))
				table.insert(outputBuffer, "\t}")
			end

			table.insert(outputBuffer, "}")

			return table.concat(outputBuffer, "\n")
		end

		local function createLogInfo()
			local logInfo = {
				errors = {},
				warnings = {},
				infos = {},
			}

			setmetatable(logInfo, logInfoMetatable)

			return logInfo
		end

		local Logging = {}

--[[
	Invokes `callback`, capturing all output that happens during its execution.

	Output will not go to stdout or stderr and will instead be put into a
	LogInfo object that is returned. If `callback` throws, the error will be
	bubbled up to the caller of `Logging.capture`.
]]
		function Logging.capture(callback)
			local collector = createLogInfo()

			local wasOutputEnabled = outputEnabled
			outputEnabled = false
			collectors[collector] = true

			local success, result = pcall(callback)

			collectors[collector] = nil
			outputEnabled = wasOutputEnabled

			assert(success, result)

			return collector
		end

--[[
	Issues a warning with an automatically attached stack trace.
]]
		function Logging.warn(messageTemplate, ...)
			local message = messageTemplate:format(...)

			for collector in pairs(collectors) do
				table.insert(collector.warnings, message)
			end

			-- debug.traceback inserts a leading newline, so we trim it here
			local trace = debug.traceback("", 2):sub(2)
			local fullMessage = ("%s\n%s"):format(message, indent(trace, 1))

			if outputEnabled then
				warn(fullMessage)
			end
		end

--[[
	Issues a warning like `Logging.warn`, but only outputs once per call site.

	This is useful for marking deprecated functions that might be called a lot;
	using `warnOnce` instead of `warn` will reduce output noise while still
	correctly marking all call sites.
]]
		function Logging.warnOnce(messageTemplate, ...)
			local trace = debug.traceback()

			if onceUsedLocations[trace] then
				return
			end

			onceUsedLocations[trace] = true
			Logging.warn(messageTemplate, ...)
		end

		return Logging

	end)
	modules_fake["None"] = (function()
		local Symbol = require(script.Parent.Symbol)

		-- Marker used to specify that the value is nothing, because nil cannot be
		-- stored in tables.
		local None = Symbol.named("None")

		return None

	end)
	modules_fake["NoopRenderer"] = (function()
--[[
	Reference renderer intended for use in tests as well as for documenting the
	minimum required interface for a Roact renderer.
]]

		local NoopRenderer = {}

		function NoopRenderer.isHostObject(target)
			-- Attempting to use NoopRenderer to target a Roblox instance is almost
			-- certainly a mistake.
			return target == nil
		end

		function NoopRenderer.mountHostNode(_reconciler, _node) end

		function NoopRenderer.unmountHostNode(_reconciler, _node) end

		function NoopRenderer.updateHostNode(_reconciler, node, _newElement)
			return node
		end

		return NoopRenderer

	end)
	modules_fake["Portal"] = (function()
		local Symbol = require(script.Parent.Symbol)

		local Portal = Symbol.named("Portal")

		return Portal

	end)
	modules_fake["PureComponent"] = (function()
--[[
	A version of Component with a `shouldUpdate` method that forces the
	resulting component to be pure.
]]

		local Component = require(script.Parent.Component)

		local PureComponent = Component:extend("PureComponent")

		-- When extend()ing a component, you don't get an extend method.
		-- This is to promote composition over inheritance.
		-- PureComponent is an exception to this rule.
		PureComponent.extend = Component.extend

		function PureComponent:shouldUpdate(newProps, newState)
			-- In a vast majority of cases, if state updated, something has updated.
			-- We don't bother checking in this case.
			if newState ~= self.state then
				return true
			end

			if newProps == self.props then
				return false
			end

			for key, value in pairs(newProps) do
				if self.props[key] ~= value then
					return true
				end
			end

			for key, value in pairs(self.props) do
				if newProps[key] ~= value then
					return true
				end
			end

			return false
		end

		return PureComponent

	end)
	modules_fake["RobloxRenderer"] = (function()
--[[
	Renderer that deals in terms of Roblox Instances. This is the most
	well-supported renderer after NoopRenderer and is currently the only
	renderer that does anything.
]]

		local Binding = require(script.Parent.Binding)
		local Children = require(script.Parent.PropMarkers.Children)
		local ElementKind = require(script.Parent.ElementKind)
		local SingleEventManager = require(script.Parent.SingleEventManager)
		local getDefaultInstanceProperty = require(script.Parent.getDefaultInstanceProperty)
		local Ref = require(script.Parent.PropMarkers.Ref)
		local Type = require(script.Parent.Type)
		local internalAssert = require(script.Parent.internalAssert)

		local config = require(script.Parent.GlobalConfig).get()

		local applyPropsError = [[
Error applying props:
	%s
In element:
%s
]]

		local updatePropsError = [[
Error updating props:
	%s
In element:
%s
]]

		local function identity(...)
			return ...
		end

		local function applyRef(ref, newHostObject)
			if ref == nil then
				return
			end

			if typeof(ref) == "function" then
				ref(newHostObject)
			elseif Type.of(ref) == Type.Binding then
				Binding.update(ref, newHostObject)
			else
				-- TODO (#197): Better error message
				error(("Invalid ref: Expected type Binding but got %s"):format(typeof(ref)))
			end
		end

		local function setRobloxInstanceProperty(hostObject, key, newValue)
			if newValue == nil then
				local hostClass = hostObject.ClassName
				local _, defaultValue = getDefaultInstanceProperty(hostClass, key)
				newValue = defaultValue
			end

			-- Assign the new value to the object
			hostObject[key] = newValue

			return
		end

		local function removeBinding(virtualNode, key)
			local disconnect = virtualNode.bindings[key]
			disconnect()
			virtualNode.bindings[key] = nil
		end

		local function attachBinding(virtualNode, key, newBinding)
			local function updateBoundProperty(newValue)
				local success, errorMessage = xpcall(function()
					setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)
				end, identity)

				if not success then
					local source = virtualNode.currentElement.source

					if source == nil then
						source = "<enable element tracebacks>"
					end

					local fullMessage = updatePropsError:format(errorMessage, source)
					error(fullMessage, 0)
				end
			end

			if virtualNode.bindings == nil then
				virtualNode.bindings = {}
			end

			virtualNode.bindings[key] = Binding.subscribe(newBinding, updateBoundProperty)

			updateBoundProperty(newBinding:getValue())
		end

		local function detachAllBindings(virtualNode)
			if virtualNode.bindings ~= nil then
				for _, disconnect in pairs(virtualNode.bindings) do
					disconnect()
				end
			end
		end

		local function applyProp(virtualNode, key, newValue, oldValue)
			if newValue == oldValue then
				return
			end

			if key == Ref or key == Children then
				-- Refs and children are handled in a separate pass
				return
			end

			local internalKeyType = Type.of(key)

			if internalKeyType == Type.HostEvent or internalKeyType == Type.HostChangeEvent then
				if virtualNode.eventManager == nil then
					virtualNode.eventManager = SingleEventManager.new(virtualNode.hostObject)
				end

				local eventName = key.name

				if internalKeyType == Type.HostChangeEvent then
					virtualNode.eventManager:connectPropertyChange(eventName, newValue)
				else
					virtualNode.eventManager:connectEvent(eventName, newValue)
				end

				return
			end

			local newIsBinding = Type.of(newValue) == Type.Binding
			local oldIsBinding = Type.of(oldValue) == Type.Binding

			if oldIsBinding then
				removeBinding(virtualNode, key)
			end

			if newIsBinding then
				attachBinding(virtualNode, key, newValue)
			else
				setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)
			end
		end

		local function applyProps(virtualNode, props)
			for propKey, value in pairs(props) do
				applyProp(virtualNode, propKey, value, nil)
			end
		end

		local function updateProps(virtualNode, oldProps, newProps)
			-- Apply props that were added or updated
			for propKey, newValue in pairs(newProps) do
				local oldValue = oldProps[propKey]

				applyProp(virtualNode, propKey, newValue, oldValue)
			end

			-- Clean up props that were removed
			for propKey, oldValue in pairs(oldProps) do
				local newValue = newProps[propKey]

				if newValue == nil then
					applyProp(virtualNode, propKey, nil, oldValue)
				end
			end
		end

		local RobloxRenderer = {}

		function RobloxRenderer.isHostObject(target)
			return typeof(target) == "Instance"
		end

		function RobloxRenderer.mountHostNode(reconciler, virtualNode)
			local element = virtualNode.currentElement
			local hostParent = virtualNode.hostParent
			local hostKey = virtualNode.hostKey

			if config.internalTypeChecks then
				internalAssert(ElementKind.of(element) == ElementKind.Host, "Element at given node is not a host Element")
			end
			if config.typeChecks then
				assert(element.props.Name == nil, "Name can not be specified as a prop to a host component in Roact.")
				assert(element.props.Parent == nil, "Parent can not be specified as a prop to a host component in Roact.")
			end

			local instance = Instance.new(element.component)
			virtualNode.hostObject = instance

			local success, errorMessage = xpcall(function()
				applyProps(virtualNode, element.props)
			end, identity)

			if not success then
				local source = element.source

				if source == nil then
					source = "<enable element tracebacks>"
				end

				local fullMessage = applyPropsError:format(errorMessage, source)
				error(fullMessage, 0)
			end

			instance.Name = tostring(hostKey)

			local children = element.props[Children]

			if children ~= nil then
				reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)
			end

			instance.Parent = hostParent
			virtualNode.hostObject = instance

			applyRef(element.props[Ref], instance)

			if virtualNode.eventManager ~= nil then
				virtualNode.eventManager:resume()
			end
		end

		function RobloxRenderer.unmountHostNode(reconciler, virtualNode)
			local element = virtualNode.currentElement

			applyRef(element.props[Ref], nil)

			for _, childNode in pairs(virtualNode.children) do
				reconciler.unmountVirtualNode(childNode)
			end

			detachAllBindings(virtualNode)

			virtualNode.hostObject:Destroy()
		end

		function RobloxRenderer.updateHostNode(reconciler, virtualNode, newElement)
			local oldProps = virtualNode.currentElement.props
			local newProps = newElement.props

			if virtualNode.eventManager ~= nil then
				virtualNode.eventManager:suspend()
			end

			-- If refs changed, detach the old ref and attach the new one
			if oldProps[Ref] ~= newProps[Ref] then
				applyRef(oldProps[Ref], nil)
				applyRef(newProps[Ref], virtualNode.hostObject)
			end

			local success, errorMessage = xpcall(function()
				updateProps(virtualNode, oldProps, newProps)
			end, identity)

			if not success then
				local source = newElement.source

				if source == nil then
					source = "<enable element tracebacks>"
				end

				local fullMessage = updatePropsError:format(errorMessage, source)
				error(fullMessage, 0)
			end

			local children = newElement.props[Children]
			if children ~= nil or oldProps[Children] ~= nil then
				reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)
			end

			if virtualNode.eventManager ~= nil then
				virtualNode.eventManager:resume()
			end

			return virtualNode
		end

		return RobloxRenderer

	end)
	modules_fake["SingleEventManager"] = (function()
--[[
	A manager for a single host virtual node's connected events.
]]

		local Logging = require(script.Parent.Logging)

		local CHANGE_PREFIX = "Change."

		local EventStatus = {
			-- No events are processed at all; they're silently discarded
			Disabled = "Disabled",

			-- Events are stored in a queue; listeners are invoked when the manager is resumed
			Suspended = "Suspended",

			-- Event listeners are invoked as the events fire
			Enabled = "Enabled",
		}

		local SingleEventManager = {}
		SingleEventManager.__index = SingleEventManager

		function SingleEventManager.new(instance)
			local self = setmetatable({
				-- The queue of suspended events
				_suspendedEventQueue = {},

				-- All the event connections being managed
				-- Events are indexed by a string key
				_connections = {},

				-- All the listeners being managed
				-- These are stored distinctly from the connections
				-- Connections can have their listeners replaced at runtime
				_listeners = {},

				-- The suspension status of the manager
				-- Managers start disabled and are "resumed" after the initial render
				_status = EventStatus.Disabled,

				-- If true, the manager is processing queued events right now.
				_isResuming = false,

				-- The Roblox instance the manager is managing
				_instance = instance,
			}, SingleEventManager)

			return self
		end

		function SingleEventManager:connectEvent(key, listener)
			self:_connect(key, self._instance[key], listener)
		end

		function SingleEventManager:connectPropertyChange(key, listener)
			local success, event = pcall(function()
				return self._instance:GetPropertyChangedSignal(key)
			end)

			if not success then
				error(("Cannot get changed signal on property %q: %s"):format(tostring(key), event), 0)
			end

			self:_connect(CHANGE_PREFIX .. key, event, listener)
		end

		function SingleEventManager:_connect(eventKey, event, listener)
			-- If the listener doesn't exist we can just disconnect the existing connection
			if listener == nil then
				if self._connections[eventKey] ~= nil then
					self._connections[eventKey]:Disconnect()
					self._connections[eventKey] = nil
				end

				self._listeners[eventKey] = nil
			else
				if self._connections[eventKey] == nil then
					self._connections[eventKey] = event:Connect(function(...)
						if self._status == EventStatus.Enabled then
							self._listeners[eventKey](self._instance, ...)
						elseif self._status == EventStatus.Suspended then
							-- Store this event invocation to be fired when resume is
							-- called.

							local argumentCount = select("#", ...)
							table.insert(self._suspendedEventQueue, { eventKey, argumentCount, ... })
						end
					end)
				end

				self._listeners[eventKey] = listener
			end
		end

		function SingleEventManager:suspend()
			self._status = EventStatus.Suspended
		end

		function SingleEventManager:resume()
			-- If we're already resuming events for this instance, trying to resume
			-- again would cause a disaster.
			if self._isResuming then
				return
			end

			self._isResuming = true

			local index = 1

			-- More events might be added to the queue when evaluating events, so we
			-- need to be careful in order to preserve correct evaluation order.
			while index <= #self._suspendedEventQueue do
				local eventInvocation = self._suspendedEventQueue[index]
				local listener = self._listeners[eventInvocation[1]]
				local argumentCount = eventInvocation[2]

				-- The event might have been disconnected since suspension started; in
				-- this case, we drop the event.
				if listener ~= nil then
					-- Wrap the listener in a coroutine to catch errors and handle
					-- yielding correctly.
					local listenerCo = coroutine.create(listener)
					local success, result = coroutine.resume(
						listenerCo,
						self._instance,
						unpack(eventInvocation, 3, 2 + argumentCount)
					)

					-- If the listener threw an error, we log it as a warning, since
					-- there's no way to write error text in Roblox Lua without killing
					-- our thread!
					if not success then
						Logging.warn("%s", result)
					end
				end

				index = index + 1
			end

			self._isResuming = false
			self._status = EventStatus.Enabled
			self._suspendedEventQueue = {}
		end

		return SingleEventManager

	end)
	modules_fake["Symbol"] = (function()
		--!nonstrict
--[[
	A 'Symbol' is an opaque marker type.

	Symbols have the type 'userdata', but when printed to the console, the name
	of the symbol is shown.
]]

		local Symbol = {}

--[[
	Creates a Symbol with the given name.

	When printed or coerced to a string, the symbol will turn into the string
	given as its name.
]]
		function Symbol.named(name)
			assert(type(name) == "string", "Symbols must be created using a string name!")

			local self = newproxy(true)

			local wrappedName = ("Symbol(%s)"):format(name)

			getmetatable(self).__tostring = function()
				return wrappedName
			end

			return self
		end

		return Symbol

	end)
	modules_fake["Type"] = (function()
--[[
	Contains markers for annotating objects with types.

	To set the type of an object, use `Type` as a key and the actual marker as
	the value:

		local foo = {
			[Type] = Type.Foo,
		}
]]

		local Symbol = require(script.Parent.Symbol)
		local strict = require(script.Parent.strict)

		local Type = newproxy(true)

		local TypeInternal = {}

		local function addType(name)
			TypeInternal[name] = Symbol.named("Roact" .. name)
		end

		addType("Binding")
		addType("Element")
		addType("HostChangeEvent")
		addType("HostEvent")
		addType("StatefulComponentClass")
		addType("StatefulComponentInstance")
		addType("VirtualNode")
		addType("VirtualTree")

		function TypeInternal.of(value)
			if typeof(value) ~= "table" then
				return nil
			end

			return value[Type]
		end

		getmetatable(Type).__index = TypeInternal

		getmetatable(Type).__tostring = function()
			return "RoactType"
		end

		strict(TypeInternal, "Type")

		return Type

	end)
	modules_fake["assertDeepEqual"] = (function()
--[[
	A utility used to assert that two objects are value-equal recursively. It
	outputs fairly nicely formatted messages to help diagnose why two objects
	would be different.

	This should only be used in tests.
]]

		local function deepEqual(a, b)
			if typeof(a) ~= typeof(b) then
				local message = ("{1} is of type %s, but {2} is of type %s"):format(typeof(a), typeof(b))
				return false, message
			end

			if typeof(a) == "table" then
				local visitedKeys = {}

				for key, value in pairs(a) do
					visitedKeys[key] = true

					local success, innerMessage = deepEqual(value, b[key])
					if not success then
						local message = innerMessage
							:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
							:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

						return false, message
					end
				end

				for key, value in pairs(b) do
					if not visitedKeys[key] then
						local success, innerMessage = deepEqual(value, a[key])

						if not success then
							local message = innerMessage
								:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
								:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

							return false, message
						end
					end
				end

				return true
			end

			if a == b then
				return true
			end

			local message = "{1} ~= {2}"
			return false, message
		end

		local function assertDeepEqual(a, b)
			local success, innerMessageTemplate = deepEqual(a, b)

			if not success then
				local innerMessage = innerMessageTemplate:gsub("{1}", "first"):gsub("{2}", "second")

				local message = ("Values were not deep-equal.\n%s"):format(innerMessage)

				error(message, 2)
			end
		end

		return assertDeepEqual

	end)
	modules_fake["assign"] = (function()
		local None = require(script.Parent.None)

--[[
	Merges values from zero or more tables onto a target table. If a value is
	set to None, it will instead be removed from the table.

	This function is identical in functionality to JavaScript's Object.assign.
]]
		local function assign(target, ...)
			for index = 1, select("#", ...) do
				local source = select(index, ...)

				if source ~= nil then
					for key, value in pairs(source) do
						if value == None then
							target[key] = nil
						else
							target[key] = value
						end
					end
				end
			end

			return target
		end

		return assign

	end)
	modules_fake["createContext"] = (function()
		local Symbol = require(script.Parent.Symbol)
		local createFragment = require(script.Parent.createFragment)
		local createSignal = require(script.Parent.createSignal)
		local Children = require(script.Parent.PropMarkers.Children)
		local Component = require(script.Parent.Component)

--[[
	Construct the value that is assigned to Roact's context storage.
]]
		local function createContextEntry(currentValue)
			return {
				value = currentValue,
				onUpdate = createSignal(),
			}
		end

		local function createProvider(context)
			local Provider = Component:extend("Provider")

			function Provider:init(props)
				self.contextEntry = createContextEntry(props.value)
				self:__addContext(context.key, self.contextEntry)
			end

			function Provider:willUpdate(nextProps)
				-- If the provided value changed, immediately update the context entry.
				--
				-- During this update, any components that are reachable will receive
				-- this updated value at the same time as any props and state updates
				-- that are being applied.
				if nextProps.value ~= self.props.value then
					self.contextEntry.value = nextProps.value
				end
			end

			function Provider:didUpdate(prevProps)
				-- If the provided value changed, after we've updated every reachable
				-- component, fire a signal to update the rest.
				--
				-- This signal will notify all context consumers. It's expected that
				-- they will compare the last context value they updated with and only
				-- trigger an update on themselves if this value is different.
				--
				-- This codepath will generally only update consumer components that has
				-- a component implementing shouldUpdate between them and the provider.
				if prevProps.value ~= self.props.value then
					self.contextEntry.onUpdate:fire(self.props.value)
				end
			end

			function Provider:render()
				return createFragment(self.props[Children])
			end

			return Provider
		end

		local function createConsumer(context)
			local Consumer = Component:extend("Consumer")

			function Consumer.validateProps(props)
				if type(props.render) ~= "function" then
					return false, "Consumer expects a `render` function"
				else
					return true
				end
			end

			function Consumer:init(_props)
				-- This value may be nil, which indicates that our consumer is not a
				-- descendant of a provider for this context item.
				self.contextEntry = self:__getContext(context.key)
			end

			function Consumer:render()
				-- Render using the latest available for this context item.
				--
				-- We don't store this value in state in order to have more fine-grained
				-- control over our update behavior.
				local value
				if self.contextEntry ~= nil then
					value = self.contextEntry.value
				else
					value = context.defaultValue
				end

				return self.props.render(value)
			end

			function Consumer:didUpdate()
				-- Store the value that we most recently updated with.
				--
				-- This value is compared in the contextEntry onUpdate hook below.
				if self.contextEntry ~= nil then
					self.lastValue = self.contextEntry.value
				end
			end

			function Consumer:didMount()
				if self.contextEntry ~= nil then
					-- When onUpdate is fired, a new value has been made available in
					-- this context entry, but we may have already updated in the same
					-- update cycle.
					--
					-- To avoid sending a redundant update, we compare the new value
					-- with the last value that we updated with (set in didUpdate) and
					-- only update if they differ. This may happen when an update from a
					-- provider was blocked by an intermediate component that returned
					-- false from shouldUpdate.
					self.disconnect = self.contextEntry.onUpdate:subscribe(function(newValue)
						if newValue ~= self.lastValue then
							-- Trigger a dummy state update.
							self:setState({})
						end
					end)
				end
			end

			function Consumer:willUnmount()
				if self.disconnect ~= nil then
					self.disconnect()
					self.disconnect = nil
				end
			end

			return Consumer
		end

		local Context = {}
		Context.__index = Context

		function Context.new(defaultValue)
			return setmetatable({
				defaultValue = defaultValue,
				key = Symbol.named("ContextKey"),
			}, Context)
		end

		function Context:__tostring()
			return "RoactContext"
		end

		local function createContext(defaultValue)
			local context = Context.new(defaultValue)

			return {
				Provider = createProvider(context),
				Consumer = createConsumer(context),
			}
		end

		return createContext

	end)
	modules_fake["createElement"] = (function()
		local Children = require(script.Parent.PropMarkers.Children)
		local ElementKind = require(script.Parent.ElementKind)
		local Logging = require(script.Parent.Logging)
		local Type = require(script.Parent.Type)

		local config = require(script.Parent.GlobalConfig).get()

		local multipleChildrenMessage = [[
The prop `Roact.Children` was defined but was overriden by the third parameter to createElement!
This can happen when a component passes props through to a child element but also uses the `children` argument:

	Roact.createElement("Frame", passedProps, {
		child = ...
	})

Instead, consider using a utility function to merge tables of children together:

	local children = mergeTables(passedProps[Roact.Children], {
		child = ...
	})

	local fullProps = mergeTables(passedProps, {
		[Roact.Children] = children
	})

	Roact.createElement("Frame", fullProps)]]

--[[
	Creates a new element representing the given component.

	Elements are lightweight representations of what a component instance should
	look like.

	Children is a shorthand for specifying `Roact.Children` as a key inside
	props. If specified, the passed `props` table is mutated!
]]
		local function createElement(component, props, children)
			if config.typeChecks then
				assert(component ~= nil, "`component` is required")
				assert(typeof(props) == "table" or props == nil, "`props` must be a table or nil")
				assert(typeof(children) == "table" or children == nil, "`children` must be a table or nil")
			end

			if props == nil then
				props = {}
			end

			if children ~= nil then
				if props[Children] ~= nil then
					Logging.warnOnce(multipleChildrenMessage)
				end

				props[Children] = children
			end

			local elementKind = ElementKind.fromComponent(component)

			local element = {
				[Type] = Type.Element,
				[ElementKind] = elementKind,
				component = component,
				props = props,
			}

			if config.elementTracing then
				-- We trim out the leading newline since there's no way to specify the
				-- trace level without also specifying a message.
				element.source = debug.traceback("", 2):sub(2)
			end

			return element
		end

		return createElement

	end)
	modules_fake["createFragment"] = (function()
		local ElementKind = require(script.Parent.ElementKind)
		local Type = require(script.Parent.Type)

		local function createFragment(elements)
			return {
				[Type] = Type.Element,
				[ElementKind] = ElementKind.Fragment,
				elements = elements,
			}
		end

		return createFragment

	end)
	modules_fake["createReconciler"] = (function()
		--!nonstrict
		local Type = require(script.Parent.Type)
		local ElementKind = require(script.Parent.ElementKind)
		local ElementUtils = require(script.Parent.ElementUtils)
		local Children = require(script.Parent.PropMarkers.Children)
		local Symbol = require(script.Parent.Symbol)
		local internalAssert = require(script.Parent.internalAssert)

		local config = require(script.Parent.GlobalConfig).get()

		local InternalData = Symbol.named("InternalData")

--[[
	The reconciler is the mechanism in Roact that constructs the virtual tree
	that later gets turned into concrete objects by the renderer.

	Roact's reconciler is constructed with the renderer as an argument, which
	enables switching to different renderers for different platforms or
	scenarios.

	When testing the reconciler itself, it's common to use `NoopRenderer` with
	spies replacing some methods. The default (and only) reconciler interface
	exposed by Roact right now uses `RobloxRenderer`.
]]
		local function createReconciler(renderer)
			local reconciler
			local mountVirtualNode
			local updateVirtualNode
			local unmountVirtualNode

	--[[
		Unmount the given virtualNode, replacing it with a new node described by
		the given element.

		Preserves host properties, depth, and legacyContext from parent.
	]]
			local function replaceVirtualNode(virtualNode, newElement)
				local hostParent = virtualNode.hostParent
				local hostKey = virtualNode.hostKey
				local depth = virtualNode.depth
				local parent = virtualNode.parent

				-- If the node that is being replaced has modified context, we need to
				-- use the original *unmodified* context for the new node
				-- The `originalContext` field will be nil if the context was unchanged
				local context = virtualNode.originalContext or virtualNode.context
				local parentLegacyContext = virtualNode.parentLegacyContext

				-- If updating this node has caused a component higher up the tree to re-render
				-- and updateChildren to be re-entered then this node could already have been
				-- unmounted in the previous updateChildren pass.
				if not virtualNode.wasUnmounted then
					unmountVirtualNode(virtualNode)
				end
				local newNode = mountVirtualNode(newElement, hostParent, hostKey, context, parentLegacyContext)

				-- mountVirtualNode can return nil if the element is a boolean
				if newNode ~= nil then
					newNode.depth = depth
					newNode.parent = parent
				end

				return newNode
			end

	--[[
		Utility to update the children of a virtual node based on zero or more
		updated children given as elements.
	]]
			local function updateChildren(virtualNode, hostParent, newChildElements)
				if config.internalTypeChecks then
					internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
				end

				virtualNode.updateChildrenCount = virtualNode.updateChildrenCount + 1

				local currentUpdateChildrenCount = virtualNode.updateChildrenCount

				local removeKeys = {}

				-- Changed or removed children
				for childKey, childNode in pairs(virtualNode.children) do
					local newElement = ElementUtils.getElementByKey(newChildElements, childKey)
					local newNode = updateVirtualNode(childNode, newElement)

					-- If updating this node has caused a component higher up the tree to re-render
					-- and updateChildren to be re-entered for this virtualNode then
					-- this result is invalid and needs to be disgarded.
					if virtualNode.updateChildrenCount ~= currentUpdateChildrenCount then
						if newNode and newNode ~= virtualNode.children[childKey] then
							unmountVirtualNode(newNode)
						end
						return
					end

					if newNode ~= nil then
						virtualNode.children[childKey] = newNode
					else
						removeKeys[childKey] = true
					end
				end

				for childKey in pairs(removeKeys) do
					virtualNode.children[childKey] = nil
				end

				-- Added children
				for childKey, newElement in ElementUtils.iterateElements(newChildElements) do
					local concreteKey = childKey
					if childKey == ElementUtils.UseParentKey then
						concreteKey = virtualNode.hostKey
					end

					if virtualNode.children[childKey] == nil then
						local childNode = mountVirtualNode(
							newElement,
							hostParent,
							concreteKey,
							virtualNode.context,
							virtualNode.legacyContext
						)

						-- If updating this node has caused a component higher up the tree to re-render
						-- and updateChildren to be re-entered for this virtualNode then
						-- this result is invalid and needs to be discarded.
						if virtualNode.updateChildrenCount ~= currentUpdateChildrenCount then
							if childNode then
								unmountVirtualNode(childNode)
							end
							return
						end

						-- mountVirtualNode can return nil if the element is a boolean
						if childNode ~= nil then
							childNode.depth = virtualNode.depth + 1
							childNode.parent = virtualNode
							virtualNode.children[childKey] = childNode
						end
					end
				end
			end

			local function updateVirtualNodeWithChildren(virtualNode, hostParent, newChildElements)
				updateChildren(virtualNode, hostParent, newChildElements)
			end

			local function updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)
				if Type.of(renderResult) == Type.Element or renderResult == nil or typeof(renderResult) == "boolean" then
					updateChildren(virtualNode, hostParent, renderResult)
				else
					error(
						("%s\n%s"):format(
						"Component returned invalid children:",
						virtualNode.currentElement.source or "<enable element tracebacks>"
						),
						0
					)
				end
			end

	--[[
		Unmounts the given virtual node and releases any held resources.
	]]
			function unmountVirtualNode(virtualNode)
				if config.internalTypeChecks then
					internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
				end

				virtualNode.wasUnmounted = true

				local kind = ElementKind.of(virtualNode.currentElement)

				-- selene: allow(if_same_then_else)
				if kind == ElementKind.Host then
					renderer.unmountHostNode(reconciler, virtualNode)
				elseif kind == ElementKind.Function then
					for _, childNode in pairs(virtualNode.children) do
						unmountVirtualNode(childNode)
					end
				elseif kind == ElementKind.Stateful then
					virtualNode.instance:__unmount()
				elseif kind == ElementKind.Portal then
					for _, childNode in pairs(virtualNode.children) do
						unmountVirtualNode(childNode)
					end
				elseif kind == ElementKind.Fragment then
					for _, childNode in pairs(virtualNode.children) do
						unmountVirtualNode(childNode)
					end
				else
					error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
				end
			end

			local function updateFunctionVirtualNode(virtualNode, newElement)
				local children = newElement.component(newElement.props)

				updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)

				return virtualNode
			end

			local function updatePortalVirtualNode(virtualNode, newElement)
				local oldElement = virtualNode.currentElement
				local oldTargetHostParent = oldElement.props.target

				local targetHostParent = newElement.props.target

				assert(renderer.isHostObject(targetHostParent), "Expected target to be host object")

				if targetHostParent ~= oldTargetHostParent then
					return replaceVirtualNode(virtualNode, newElement)
				end

				local children = newElement.props[Children]

				updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)

				return virtualNode
			end

			local function updateFragmentVirtualNode(virtualNode, newElement)
				updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, newElement.elements)

				return virtualNode
			end

	--[[
		Update the given virtual node using a new element describing what it
		should transform into.

		`updateVirtualNode` will return a new virtual node that should replace
		the passed in virtual node. This is because a virtual node can be
		updated with an element referencing a different component!

		In that case, `updateVirtualNode` will unmount the input virtual node,
		mount a new virtual node, and return it in this case, while also issuing
		a warning to the user.
	]]
			function updateVirtualNode(virtualNode, newElement, newState)
				if config.internalTypeChecks then
					internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
				end
				if config.typeChecks then
					assert(
						Type.of(newElement) == Type.Element or typeof(newElement) == "boolean" or newElement == nil,
						"Expected arg #2 to be of type Element, boolean, or nil"
					)
				end

				-- If nothing changed, we can skip this update
				if virtualNode.currentElement == newElement and newState == nil then
					return virtualNode
				end

				if typeof(newElement) == "boolean" or newElement == nil then
					unmountVirtualNode(virtualNode)
					return nil
				end

				if virtualNode.currentElement.component ~= newElement.component then
					return replaceVirtualNode(virtualNode, newElement)
				end

				local kind = ElementKind.of(newElement)

				local shouldContinueUpdate = true

				if kind == ElementKind.Host then
					virtualNode = renderer.updateHostNode(reconciler, virtualNode, newElement)
				elseif kind == ElementKind.Function then
					virtualNode = updateFunctionVirtualNode(virtualNode, newElement)
				elseif kind == ElementKind.Stateful then
					shouldContinueUpdate = virtualNode.instance:__update(newElement, newState)
				elseif kind == ElementKind.Portal then
					virtualNode = updatePortalVirtualNode(virtualNode, newElement)
				elseif kind == ElementKind.Fragment then
					virtualNode = updateFragmentVirtualNode(virtualNode, newElement)
				else
					error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
				end

				-- Stateful components can abort updates via shouldUpdate. If that
				-- happens, we should stop doing stuff at this point.
				if not shouldContinueUpdate then
					return virtualNode
				end

				virtualNode.currentElement = newElement

				return virtualNode
			end

	--[[
		Constructs a new virtual node but not does mount it.
	]]
			local function createVirtualNode(element, hostParent, hostKey, context, legacyContext)
				if config.internalTypeChecks then
					internalAssert(
						renderer.isHostObject(hostParent) or hostParent == nil,
						"Expected arg #2 to be a host object"
					)
					internalAssert(typeof(context) == "table" or context == nil, "Expected arg #4 to be of type table or nil")
					internalAssert(
						typeof(legacyContext) == "table" or legacyContext == nil,
						"Expected arg #5 to be of type table or nil"
					)
				end
				if config.typeChecks then
					assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
					assert(
						Type.of(element) == Type.Element or typeof(element) == "boolean",
						"Expected arg #1 to be of type Element or boolean"
					)
				end

				return {
					[Type] = Type.VirtualNode,
					currentElement = element,
					depth = 1,
					parent = nil,
					children = {},
					hostParent = hostParent,
					hostKey = hostKey,
					updateChildrenCount = 0,
					wasUnmounted = false,

					-- Legacy Context API
					-- A table of context values inherited from the parent node
					legacyContext = legacyContext,

					-- A saved copy of the parent context, used when replacing a node
					parentLegacyContext = legacyContext,

					-- Context API
					-- A table of context values inherited from the parent node
					context = context or {},

					-- A saved copy of the unmodified context; this will be updated when
					-- a component adds new context and used when a node is replaced
					originalContext = nil,
				}
			end

			local function mountFunctionVirtualNode(virtualNode)
				local element = virtualNode.currentElement

				local children = element.component(element.props)

				updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)
			end

			local function mountPortalVirtualNode(virtualNode)
				local element = virtualNode.currentElement

				local targetHostParent = element.props.target
				local children = element.props[Children]

				assert(renderer.isHostObject(targetHostParent), "Expected target to be host object")

				updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)
			end

			local function mountFragmentVirtualNode(virtualNode)
				local element = virtualNode.currentElement
				local children = element.elements

				updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, children)
			end

	--[[
		Constructs a new virtual node and mounts it, but does not place it into
		the tree.
	]]
			function mountVirtualNode(element, hostParent, hostKey, context, legacyContext)
				if config.internalTypeChecks then
					internalAssert(
						renderer.isHostObject(hostParent) or hostParent == nil,
						"Expected arg #2 to be a host object"
					)
					internalAssert(
						typeof(legacyContext) == "table" or legacyContext == nil,
						"Expected arg #5 to be of type table or nil"
					)
				end
				if config.typeChecks then
					assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
					assert(
						Type.of(element) == Type.Element or typeof(element) == "boolean",
						"Expected arg #1 to be of type Element or boolean"
					)
				end

				-- Boolean values render as nil to enable terse conditional rendering.
				if typeof(element) == "boolean" then
					return nil
				end

				local kind = ElementKind.of(element)

				local virtualNode = createVirtualNode(element, hostParent, hostKey, context, legacyContext)

				if kind == ElementKind.Host then
					renderer.mountHostNode(reconciler, virtualNode)
				elseif kind == ElementKind.Function then
					mountFunctionVirtualNode(virtualNode)
				elseif kind == ElementKind.Stateful then
					element.component:__mount(reconciler, virtualNode)
				elseif kind == ElementKind.Portal then
					mountPortalVirtualNode(virtualNode)
				elseif kind == ElementKind.Fragment then
					mountFragmentVirtualNode(virtualNode)
				else
					error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
				end

				return virtualNode
			end

	--[[
		Constructs a new Roact virtual tree, constructs a root node for
		it, and mounts it.
	]]
			local function mountVirtualTree(element, hostParent, hostKey)
				if config.typeChecks then
					assert(Type.of(element) == Type.Element, "Expected arg #1 to be of type Element")
					assert(renderer.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
				end

				if hostKey == nil then
					hostKey = "RoactTree"
				end

				local tree = {
					[Type] = Type.VirtualTree,
					[InternalData] = {
						-- The root node of the tree, which starts into the hierarchy of
						-- Roact component instances.
						rootNode = nil,
						mounted = true,
					},
				}

				tree[InternalData].rootNode = mountVirtualNode(element, hostParent, hostKey)

				return tree
			end

	--[[
		Unmounts the virtual tree, freeing all of its resources.

		No further operations should be done on the tree after it's been
		unmounted, as indicated by its the `mounted` field.
	]]
			local function unmountVirtualTree(tree)
				local internalData = tree[InternalData]
				if config.typeChecks then
					assert(Type.of(tree) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
					assert(internalData.mounted, "Cannot unmounted a Roact tree that has already been unmounted")
				end

				internalData.mounted = false

				if internalData.rootNode ~= nil then
					unmountVirtualNode(internalData.rootNode)
				end
			end

	--[[
		Utility method for updating the root node of a virtual tree given a new
		element.
	]]
			local function updateVirtualTree(tree, newElement)
				local internalData = tree[InternalData]
				if config.typeChecks then
					assert(Type.of(tree) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
					assert(Type.of(newElement) == Type.Element, "Expected arg #2 to be a Roact Element")
				end

				internalData.rootNode = updateVirtualNode(internalData.rootNode, newElement)

				return tree
			end

			reconciler = {
				mountVirtualTree = mountVirtualTree,
				unmountVirtualTree = unmountVirtualTree,
				updateVirtualTree = updateVirtualTree,

				createVirtualNode = createVirtualNode,
				mountVirtualNode = mountVirtualNode,
				unmountVirtualNode = unmountVirtualNode,
				updateVirtualNode = updateVirtualNode,
				updateVirtualNodeWithChildren = updateVirtualNodeWithChildren,
				updateVirtualNodeWithRenderResult = updateVirtualNodeWithRenderResult,
			}

			return reconciler
		end

		return createReconciler

	end)
	modules_fake["createReconcilerCompat"] = (function()
--[[
	Contains deprecated methods from Reconciler. Broken out so that removing
	this shim is easy -- just delete this file and remove it from init.
]]

		local Logging = require(script.Parent.Logging)

		local reifyMessage = [[
Roact.reify has been renamed to Roact.mount and will be removed in a future release.
Check the call to Roact.reify at:
]]

		local teardownMessage = [[
Roact.teardown has been renamed to Roact.unmount and will be removed in a future release.
Check the call to Roact.teardown at:
]]

		local reconcileMessage = [[
Roact.reconcile has been renamed to Roact.update and will be removed in a future release.
Check the call to Roact.reconcile at:
]]

		local function createReconcilerCompat(reconciler)
			local compat = {}

			function compat.reify(...)
				Logging.warnOnce(reifyMessage)

				return reconciler.mountVirtualTree(...)
			end

			function compat.teardown(...)
				Logging.warnOnce(teardownMessage)

				return reconciler.unmountVirtualTree(...)
			end

			function compat.reconcile(...)
				Logging.warnOnce(reconcileMessage)

				return reconciler.updateVirtualTree(...)
			end

			return compat
		end

		return createReconcilerCompat

	end)
	modules_fake["createRef"] = (function()
--[[
	A ref is nothing more than a binding with a special field 'current'
	that maps to the getValue method of the binding
]]
		local Binding = require(script.Parent.Binding)

		local function createRef()
			local binding, _ = Binding.create(nil)

			local ref = {}

	--[[
		A ref is just redirected to a binding via its metatable
	]]
			setmetatable(ref, {
				__index = function(_self, key)
					if key == "current" then
						return binding:getValue()
					else
						return binding[key]
					end
				end,
				__newindex = function(_self, key, value)
					if key == "current" then
						error("Cannot assign to the 'current' property of refs", 2)
					end

					binding[key] = value
				end,
				__tostring = function(_self)
					return ("RoactRef(%s)"):format(tostring(binding:getValue()))
				end,
			})

			return ref
		end

		return createRef

	end)
	modules_fake["createSignal"] = (function()
--[[
	This is a simple signal implementation that has a dead-simple API.

		local signal = createSignal()

		local disconnect = signal:subscribe(function(foo)
			print("Cool foo:", foo)
		end)

		signal:fire("something")

		disconnect()
]]

		local function createSignal()
			local connections = {}
			local suspendedConnections = {}
			local firing = false

			local function subscribe(_self, callback)
				assert(typeof(callback) == "function", "Can only subscribe to signals with a function.")

				local connection = {
					callback = callback,
					disconnected = false,
				}

				-- If the callback is already registered, don't add to the suspendedConnection. Otherwise, this will disable
				-- the existing one.
				if firing and not connections[callback] then
					suspendedConnections[callback] = connection
				end

				connections[callback] = connection

				local function disconnect()
					assert(not connection.disconnected, "Listeners can only be disconnected once.")

					connection.disconnected = true
					connections[callback] = nil
					suspendedConnections[callback] = nil
				end

				return disconnect
			end

			local function fire(_self, ...)
				firing = true
				for callback, connection in pairs(connections) do
					if not connection.disconnected and not suspendedConnections[callback] then
						callback(...)
					end
				end

				firing = false

				for callback, _ in pairs(suspendedConnections) do
					suspendedConnections[callback] = nil
				end
			end

			return {
				subscribe = subscribe,
				fire = fire,
			}
		end

		return createSignal

	end)
	modules_fake["createSpy"] = (function()
		--!strict
--[[
	A utility used to create a function spy that can be used to robustly test
	that functions are invoked the correct number of times and with the correct
	number of arguments.

	This should only be used in tests.
]]

		local assertDeepEqual = require(script.Parent.assertDeepEqual)

		local function createSpy(inner)
			local self = {}
			self.callCount = 0
			self.values = {}
			self.valuesLength = 0
			self.value = function(...)
				self.callCount = self.callCount + 1
				self.values = { ... }
				self.valuesLength = select("#", ...)

				if inner ~= nil then
					return inner(...)
				end
				return nil
			end

			self.assertCalledWith = function(_, ...)
				local len = select("#", ...)

				if self.valuesLength ~= len then
					error(("Expected %d arguments, but was called with %d arguments"):format(self.valuesLength, len), 2)
				end

				for i = 1, len do
					local expected = select(i, ...)

					assert(self.values[i] == expected, "value differs")
				end
			end

			self.assertCalledWithDeepEqual = function(_, ...)
				local len = select("#", ...)

				if self.valuesLength ~= len then
					error(("Expected %d arguments, but was called with %d arguments"):format(self.valuesLength, len), 2)
				end

				for i = 1, len do
					local expected = select(i, ...)

					assertDeepEqual(self.values[i], expected)
				end
			end

			self.captureValues = function(_, ...)
				local len = select("#", ...)
				local result = {}

				assert(self.valuesLength == len, "length of expected values differs from stored values")

				for i = 1, len do
					local key = select(i, ...)
					result[key] = self.values[i]
				end

				return result
			end

			setmetatable(self, {
				__index = function(_, key)
					error(("%q is not a valid member of spy"):format(key))
				end,
			})

			return self
		end

		return createSpy

	end)
	modules_fake["forwardRef"] = (function()
		local assign = require(script.Parent.assign)
		local None = require(script.Parent.None)
		local Ref = require(script.Parent.PropMarkers.Ref)

		local config = require(script.Parent.GlobalConfig).get()

		local excludeRef = {
			[Ref] = None,
		}

--[[
	Allows forwarding of refs to underlying host components. Accepts a render
	callback which accepts props and a ref, and returns an element.
]]
		local function forwardRef(render)
			if config.typeChecks then
				assert(typeof(render) == "function", "Expected arg #1 to be a function")
			end

			return function(props)
				local ref = props[Ref]
				local propsWithoutRef = assign({}, props, excludeRef)

				return render(propsWithoutRef, ref)
			end
		end

		return forwardRef

	end)
	modules_fake["getDefaultInstanceProperty"] = (function()
--[[
	Attempts to get the default value of a given property on a Roblox instance.

	This is used by the reconciler in cases where a prop was previously set on a
	primitive component, but is no longer present in a component's new props.

	Eventually, Roblox might provide a nicer API to query the default property
	of an object without constructing an instance of it.
]]

		local Symbol = require(script.Parent.Symbol)

		local Nil = Symbol.named("Nil")
		local _cachedPropertyValues = {}

		local function getDefaultInstanceProperty(className, propertyName)
			local classCache = _cachedPropertyValues[className]

			if classCache then
				local propValue = classCache[propertyName]

				-- We have to use a marker here, because Lua doesn't distinguish
				-- between 'nil' and 'not in a table'
				if propValue == Nil then
					return true, nil
				end

				if propValue ~= nil then
					return true, propValue
				end
			else
				classCache = {}
				_cachedPropertyValues[className] = classCache
			end

			local created = Instance.new(className)
			local ok, defaultValue = pcall(function()
				return created[propertyName]
			end)

			created:Destroy()

			if ok then
				if defaultValue == nil then
					classCache[propertyName] = Nil
				else
					classCache[propertyName] = defaultValue
				end
			end

			return ok, defaultValue
		end

		return getDefaultInstanceProperty

	end)
	modules_fake["internalAssert"] = (function()
		local function internalAssert(condition, message)
			if not condition then
				error(message .. " (This is probably a bug in Roact!)", 3)
			end
		end

		return internalAssert

	end)
	modules_fake["invalidSetStateMessages"] = (function()
--[[
	These messages are used by Component to help users diagnose when they're
	calling setState in inappropriate places.

	The indentation may seem odd, but it's necessary to avoid introducing extra
	whitespace into the error messages themselves.
]]
		local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)

		local invalidSetStateMessages = {}

		invalidSetStateMessages[ComponentLifecyclePhase.WillUpdate] = [[
setState cannot be used in the willUpdate lifecycle method.
Consider using the didUpdate method instead, or using getDerivedStateFromProps.

Check the definition of willUpdate in the component %q.]]

		invalidSetStateMessages[ComponentLifecyclePhase.WillUnmount] = [[
setState cannot be used in the willUnmount lifecycle method.
A component that is being unmounted cannot be updated!

Check the definition of willUnmount in the component %q.]]

		invalidSetStateMessages[ComponentLifecyclePhase.ShouldUpdate] = [[
setState cannot be used in the shouldUpdate lifecycle method.
shouldUpdate must be a pure function that only depends on props and state.

Check the definition of shouldUpdate in the component %q.]]

		invalidSetStateMessages[ComponentLifecyclePhase.Render] = [[
setState cannot be used in the render method.
render must be a pure function that only depends on props and state.

Check the definition of render in the component %q.]]

		invalidSetStateMessages["default"] = [[
setState can not be used in the current situation, because Roact doesn't know
which part of the lifecycle this component is in.

This is a bug in Roact.
It was triggered by the component %q.
]]

		return invalidSetStateMessages

	end)
	modules_fake["oneChild"] = (function()
--[[
	Retrieves at most one child from the children passed to a component.

	If passed nil or an empty table, will return nil.

	Throws an error if passed more than one child.
]]
		local function oneChild(children)
			if not children then
				return nil
			end

			local key, child = next(children)

			if not child then
				return nil
			end

			local after = next(children, key)

			if after then
				error("Expected at most child, had more than one child.", 2)
			end

			return child
		end

		return oneChild

	end)
	modules_fake["strict"] = (function()
		--!nonstrict
		local function strict(t, name)
			name = name or tostring(t)

			return setmetatable(t, {
				__index = function(_self, key)
					local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), name)

					error(message, 2)
				end,

				__newindex = function(_self, key, _value)
					local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), name)

					error(message, 2)
				end,
			})
		end

		return strict

	end)
	modules_fake["Binding"] = (function()
		local createSignal = require(script.Parent.createSignal)
		local Symbol = require(script.Parent.Symbol)
		local Type = require(script.Parent.Type)

		local config = require(script.Parent.GlobalConfig).get()

		local BindingImpl = Symbol.named("BindingImpl")

		local BindingInternalApi = {}

		local bindingPrototype = {}

		function bindingPrototype:getValue()
			return BindingInternalApi.getValue(self)
		end

		function bindingPrototype:map(predicate)
			return BindingInternalApi.map(self, predicate)
		end

		local BindingPublicMeta = {
			__index = bindingPrototype,
			__tostring = function(self)
				return string.format("RoactBinding(%s)", tostring(self:getValue()))
			end,
		}

		function BindingInternalApi.update(binding, newValue)
			return binding[BindingImpl].update(newValue)
		end

		function BindingInternalApi.subscribe(binding, callback)
			return binding[BindingImpl].subscribe(callback)
		end

		function BindingInternalApi.getValue(binding)
			return binding[BindingImpl].getValue()
		end

		function BindingInternalApi.create(initialValue)
			local impl = {
				value = initialValue,
				changeSignal = createSignal(),
			}

			function impl.subscribe(callback)
				return impl.changeSignal:subscribe(callback)
			end

			function impl.update(newValue)
				impl.value = newValue
				impl.changeSignal:fire(newValue)
			end

			function impl.getValue()
				return impl.value
			end

			return setmetatable({
				[Type] = Type.Binding,
				[BindingImpl] = impl,
			}, BindingPublicMeta), impl.update
		end

		function BindingInternalApi.map(upstreamBinding, predicate)
			if config.typeChecks then
				assert(Type.of(upstreamBinding) == Type.Binding, "Expected arg #1 to be a binding")
				assert(typeof(predicate) == "function", "Expected arg #1 to be a function")
			end

			local impl = {}

			function impl.subscribe(callback)
				return BindingInternalApi.subscribe(upstreamBinding, function(newValue)
					callback(predicate(newValue))
				end)
			end

			function impl.update(_newValue)
				error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
			end

			function impl.getValue()
				return predicate(upstreamBinding:getValue())
			end

			return setmetatable({
				[Type] = Type.Binding,
				[BindingImpl] = impl,
			}, BindingPublicMeta)
		end

		function BindingInternalApi.join(upstreamBindings)
			if config.typeChecks then
				assert(typeof(upstreamBindings) == "table", "Expected arg #1 to be of type table")

				for key, value in pairs(upstreamBindings) do
					if Type.of(value) ~= Type.Binding then
						local message = ("Expected arg #1 to contain only bindings, but key %q had a non-binding value"):format(
						tostring(key)
						)
						error(message, 2)
					end
				end
			end

			local impl = {}

			local function getValue()
				local value = {}

				for key, upstream in pairs(upstreamBindings) do
					value[key] = upstream:getValue()
				end

				return value
			end

			function impl.subscribe(callback)
				local disconnects = {}

				for key, upstream in pairs(upstreamBindings) do
					disconnects[key] = BindingInternalApi.subscribe(upstream, function(_newValue)
						callback(getValue())
					end)
				end

				return function()
					if disconnects == nil then
						return
					end

					for _, disconnect in pairs(disconnects) do
						disconnect()
					end

					disconnects = nil
				end
			end

			function impl.update(_newValue)
				error("Bindings created by joinBindings(...) cannot be updated directly", 2)
			end

			function impl.getValue()
				return getValue()
			end

			return setmetatable({
				[Type] = Type.Binding,
				[BindingImpl] = impl,
			}, BindingPublicMeta)
		end

		return BindingInternalApi

	end)
	local script = modules_fake
	local GlobalConfig = require(script.GlobalConfig)
	local createReconciler = require(script.createReconciler)
	local createReconcilerCompat = require(script.createReconcilerCompat)
	local RobloxRenderer = require(script.RobloxRenderer)
	local strict = require(script.strict)
	local Binding = require(script.Binding)

	local robloxReconciler = createReconciler(RobloxRenderer)
	local reconcilerCompat = createReconcilerCompat(robloxReconciler)

	Roact = strict({
		Component = require(script.Component),
		createElement = require(script.createElement),
		createFragment = require(script.createFragment),
		oneChild = require(script.oneChild),
		PureComponent = require(script.PureComponent),
		None = require(script.None),
		Portal = require(script.Portal),
		createRef = require(script.createRef),
		forwardRef = require(script.forwardRef),
		createBinding = Binding.create,
		joinBindings = Binding.join,
		createContext = require(script.createContext),

		Change = require(script.PropMarkers.Change),
		Children = require(script.PropMarkers.Children),
		Event = require(script.PropMarkers.Event),
		Ref = require(script.PropMarkers.Ref),

		mount = robloxReconciler.mountVirtualTree,
		unmount = robloxReconciler.unmountVirtualTree,
		update = robloxReconciler.updateVirtualTree,

		reify = reconcilerCompat.reify,
		teardown = reconcilerCompat.teardown,
		reconcile = reconcilerCompat.reconcile,

		setGlobalConfig = GlobalConfig.set,

		-- APIs that may change in the future without warning
		UNSTABLE = {},
	})
end
local RunService = game:GetService("RunService")

local JOINT_INFO = {
	LeftShoulder = {
		Limits = { Cone = 70, Twist = 30 },
		Offset = Vector3.new(0, -0.25, 0),
		Rotation = CFrame.Angles(0, 0, math.rad(45))
	},
	["Left Shoulder"] = {},
	["Right Shoulder"] = {},
	["Right Hip"] = {},
	["Left Hip"] = {},
	LeftElbow = {
		Limits = { Lower = 0, Upper = 160 }
	},
	LeftWrist = {
		Limits = { Cone = 90, Twist = 90 }
	},
	RightShoulder = {
		Limits = { Cone = 70, Twist = 30 },
		Offset = Vector3.new(0, -0.25, 0),
		Rotation = CFrame.Angles(0, 0, math.rad(-45))
	},
	RightElbow = {
		Limits = { Lower = 0, Upper = 160 }
	},
	RightWrist = {
		Limits = { Cone = 90, Twist = 90 }
	},

	Waist = {
		Limits = { Lower = -45, Upper = 30 }
	},
	Neck = {
		Limits = { Cone = 20, Twist = 20 }
	},

	LeftHip = {
		Limits = { Cone = 40, Twist = 2.5 },
		Rotation = CFrame.Angles(math.rad(-40), 0, math.rad(35)),
	},
	LeftKnee = {
		Limits = { Lower = 0, Upper = 120 }
	},
	LeftAnkle = {
		Limits = { Cone = 10, Twist = 0.5 }
	},
	RightHip = {
		Limits = { Cone = 40, Twist = 2.5 },
		Rotation = CFrame.Angles(math.rad(-40), 0, math.rad(-35))
	},
	RightKnee = {
		Limits = { Lower = 0, Upper = 120 }
	},
	RightAnkle = {
		Limits = { Cone = 10, Twist = 0.5 }
	}
}

local GROUPS = {
	UpperBody = {
		"Waist",
		"Neck",
		"LeftShoulder",
		"RightShoulder",
		"LeftElbow",
		"RightElbow",
		"LeftWrist",
		"RightWrist",
		"Left Shoulder",
		"Right Shoulder",
	},
	LowerBody = {
		"LeftHip",
		"RightHip",
		"LeftKnee",
		"RightKnee",
		"LeftAnkle",
		"RightAnkle",
		"Left Hip",
		"Right Hip",
	},
	LeftArm = {
		"LeftShoulder",
		"Left Shoulder",
		"LeftElbow",
		"LeftWrist",
	},
	RightArm = {
		"RightShoulder",
		"Right Shoulder",
		"RightElbow",
		"RightWrist"
	},
	LeftLeg = {
		"LeftHip",
		"LeftKnee",
		"LeftAnkle",
		"Left Hip"
	},
	RightLeg = {
		"RightHip",
		"RightKnee",
		"RightAnkle",
		"Right Hip",
	},
}

local R6AttachmentData = {
	["Right Shoulder"] = {CFrame.new(0, 0.5, 0), CFrame.new(1.5, 0.5, 0)},
	["Left Shoulder"] = {CFrame.new(0, 0.5, 0), CFrame.new(-1.5, 0.5, 0)},
	["Right Hip"] = {CFrame.new(0, 0.5, 0), CFrame.new(0.5, -1.5, 0)},
	["Left Hip"] = {CFrame.new(0, 0.5, 0), CFrame.new(-0.5, -1.5, 0)},
	Neck = {CFrame.new(0, -0.5, 0), CFrame.new(0, 1, 0)}
}


local Ragdoll = {}
Ragdoll.__index = Ragdoll

function Ragdoll.new(character)
	local self = setmetatable({}, Ragdoll)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.humanoid.RequiresNeck = false
	self.joints = {}
	for jointName, info in pairs(JOINT_INFO) do
		self.joints[jointName] = self:setupJoint(jointName, info)
	end

	return self
end

function Ragdoll:setupJoint(jointName, info)
	if self.joints[jointName] then
		return self.joints[jointName]
	end

	local constraintName = jointName .. "Constraint"
	local rigAttachmentName = jointName .. "RigAttachment"
	local existingConstraint = self.character:FindFirstChild(constraintName, true)
	local existingMotor = self.character:FindFirstChild(jointName, true)
	if not existingMotor then
		return nil
	end

	if existingConstraint or RunService:IsClient() then
		existingConstraint = self.character:WaitForChild(constraintName)
		return {
			constraint = existingConstraint,
			motor = existingMotor,
			ragdolled = existingMotor.Part1 ~= nil
		}
	else
		local constraintType = "HingeConstraint"
		if (info.Limits and info.Limits.Cone and info.Limits.Twist) or R6AttachmentData[jointName] then
			constraintType = "BallSocketConstraint"
		end

		local a0 = existingMotor.Part0:FindFirstChild(rigAttachmentName)
		local a1 = existingMotor.Part1:FindFirstChild(rigAttachmentName)

		if not a0 then
			a0 = Instance.new("Attachment")
			a0.Name = rigAttachmentName
			a0.CFrame = R6AttachmentData[jointName] and R6AttachmentData[jointName][2] or CFrame.identity
			a0.Parent = existingMotor.Part0
		end

		if not a1 then
			a1 = Instance.new("Attachment")
			a1.Name = rigAttachmentName
			a1.CFrame = R6AttachmentData[jointName] and R6AttachmentData[jointName][1] or CFrame.identity
			a1.Parent = existingMotor.Part1
		end

		local collider = Instance.new("Part")
		collider.Size = existingMotor.Part1.Size * 0.8
		collider.Transparency = 1
		collider.Parent = existingMotor.Part1

		local weld = Instance.new("Weld")
		weld.Part0 = collider.Parent
		weld.Part1 = collider
		weld.Parent = collider

		local constraint = Instance.new(constraintType)
		constraint.Name = constraintName
		constraint.Enabled = false
		constraint.Attachment0 = a0
		constraint.Attachment1 = a1
		constraint.LimitsEnabled = info.Limits ~= nil

		if info.Limits and info.Limits.Cone and info.Limits.Twist then
			constraint.UpperAngle = info.Limits.Cone
			constraint.TwistLimitsEnabled = true
			constraint.TwistLowerAngle = -info.Limits.Twist
			constraint.TwistUpperAngle = info.Limits.Twist
		elseif info.Limits and info.Limits.Lower and info.Limits.Upper then
			constraint.LowerAngle = info.Limits.Lower
			constraint.UpperAngle = info.Limits.Upper
		end

		constraint.Parent = existingMotor.Parent

		return {
			constraint = constraint,
			motor = existingMotor,
			ragdolled = false
		}
	end
end

function Ragdoll:setJointRagdolled(jointName, ragdolled)
	local joint = self.joints[jointName]
	if not joint then return end

	joint.constraint.Enabled = ragdolled
	if joint.motor and joint.motor:IsA("Motor6D") then
		if ragdolled then
			joint.motor.Part1 = nil
		else
			joint.motor.Part1 = joint.motor.Parent
		end
	end
end

function Ragdoll:setGroupRagdolled(groupName, ragdolled)
	local groupJoints = GROUPS[groupName]
	assert(groupJoints, string.format("%s is not a valid ragdoll group", tostring(groupName)))

	for _, jointName in pairs(groupJoints) do
		self:setJointRagdolled(jointName, ragdolled)
	end
end

function Ragdoll:setRagdolled(ragdolled, whitelist)
	for jointName in pairs(self.joints) do
		if not whitelist or whitelist[jointName] then
			self:setJointRagdolled(jointName, ragdolled)
		end
	end
end

function Ragdoll:destroy()
	self:setRagdolled(false)
	for _, joint in pairs(self.joints) do
		if joint.constraint then
			joint.constraint:Destroy()
		end
	end
	self.joints = {}
end

local Roblox = {} do
	local TweenService 		= game:GetService("TweenService")
	local CollectionService = game:GetService("CollectionService")
	local RunService 		= game:GetService("RunService")
	local UserInputService	= game:GetService("UserInputService")

	Roblox.Random = Random.new()
	Roblox.zeroVector2 = Vector2.new()
	Roblox.zeroVector3 = Vector3.new()
	Roblox.identityCFrame = CFrame.new()
	Roblox.upVector2 = Vector2.new(0, 1)
	Roblox.upVector3 = Vector3.new(0, 1, 0)

	local guidCharsText = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()_+./"
	local guidChars = {}
	for i = 1, #guidCharsText do
		guidChars[i] = guidCharsText:sub(i, i)
	end
	local guidRandom = Random.new()

	function Roblox.newGuid()
		local guid = ""
		for _ = 1, 10 do
			local char = guidRandom:NextInteger(1,#guidChars)
			guid = guid .. guidChars[char]
		end
		return guid
	end

	function Roblox.isPlaySolo()
		return RunService:IsClient() and RunService:IsServer() and RunService:IsStudio()
	end

	function Roblox.waitForDescendant(instance, descendantName, timeout)
		timeout = timeout or 60
		local found = instance:FindFirstChild(descendantName, true)
		if found then
			return found
		end

		if timeout < 1e6 and timeout > 0 then
			coroutine.wrap(function()
				wait(timeout)
				if not found then
					warn("Roblox.waitForDescendant(%s, %s) is taking too long")
				end
			end)()
		end

		while not found do
			local newDescendant = instance.DescendantAdded:Wait()
			if newDescendant.Name == descendantName then
				found = newDescendant
				return newDescendant
			end
		end
	end

	function Roblox.create(className)
		return function(props)
			local instance = Instance.new(className)
			for key, val in pairs(props) do
				if key ~= "Parent" then
					instance[key] = val
				end
			end
			instance.Parent = props.Parent
			return instance
		end
	end

	function Roblox.weldModel(model)
		local rootPart = model.PrimaryPart
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part ~= rootPart then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = rootPart
				weld.Part1 = part
				weld.Parent = part
			end
		end
	end

	function Roblox.setNetworkOwner(model, owner)
		if not model then warn("Cannot setNetworkOwner on nil model") return end
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") and not part.Anchored then
				part:SetNetworkOwner(owner)
			end
		end
	end

	function Roblox.createMotor6D(root, child)
		local motor = Instance.new("Motor6D")
		motor.Part0 = root
		motor.Part1 = child

		motor.C0 = root.CFrame:toObjectSpace(child.CFrame)
		motor.C1 = CFrame.new()

		motor.Parent = root
		return motor
	end

	function Roblox.getTotalMass(part)
		local allConnected = part:GetConnectedParts(true)
		local total = 0
		for _, v in pairs(allConnected) do
			total = total + v:GetMass()
		end
		return total
	end

	function Roblox.waitForTween(tweenInstance, tweenInfo, tweenProps)
		local tween = TweenService:Create(tweenInstance, tweenInfo, tweenProps)
		tween:Play()
		tween.Completed:wait()
	end

	function Roblox.tween(tweenInstance, tweenInfo, tweenProps)
		local tween = TweenService:Create(tweenInstance, tweenInfo, tweenProps)
		tween:Play()
	end

	function Roblox.fadeAway(gui, duration, level)
		duration = duration or 0.5
		level = level or 0

		local tweenInfo = TweenInfo.new(duration)
		local tweenProps = { BackgroundTransparency = 1 }

		if gui:IsA("TextButton") or gui:IsA("TextLabel") or gui:IsA("TextBox") then
			tweenProps.TextTransparency = 1
			tweenProps.TextStrokeTransparency = 1
		elseif gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
			tweenProps.ImageTransparency = 1
		else
			return
		end

		for _, v in pairs(gui:GetChildren()) do
			Roblox.fadeAway(v, duration, level + 1)
		end


		if level == 0 then
			coroutine.wrap(function()
				Roblox.waitForTween(gui, tweenInfo, tweenProps)
				gui:Destroy()
			end)()
		else
			Roblox.tween(gui, tweenInfo, tweenProps)
		end
	end

	function Roblox.setModelAnchored(model, anchored)
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = anchored
			end
		end
	end

	function Roblox.setModelLocalVisible(model, visible)
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = visible and 0 or 1
			elseif part:IsA("SurfaceGui") then
				part.Enabled = visible
			elseif part:IsA("Decal") then
				part.Transparency = visible and 0 or 1
			end
		end
	end

	function Roblox.forAllTagged(tagName, enterFunc, exitFunc)
		for _, obj in pairs(CollectionService:GetTagged(tagName)) do
			if enterFunc then
				enterFunc(obj, tagName)
			end
		end
		if enterFunc then
			CollectionService:GetInstanceAddedSignal(tagName):Connect(function(obj) enterFunc(obj, tagName) end)
		end
		if exitFunc then
			CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(obj) exitFunc(obj, tagName) end)
		end
	end

	function Roblox.getHumanoidFromCharacterPart(part)
		local currentNode = part
		while currentNode do
			local humanoid = currentNode:FindFirstChildOfClass("Humanoid")
			if humanoid then return humanoid end
			currentNode = currentNode.Parent
		end
		return nil
	end

	local addEsEndings = {
		s = true,
		sh = true,
		ch = true,
		x = true,
		z = true
	}
	local vowels = {
		a = true,
		e = true,
		i = true,
		o = true,
		u = true
	}
	function Roblox.formatPlural(num, name, wordOnly)
		if num ~= 1 then
			local lastTwo = name:sub(-2):lower()
			local lastOne = name:sub(-1):lower()

			local suffix = "s"
			if addEsEndings[lastTwo] or addEsEndings[lastOne] then
				suffix = "es"
			elseif lastOne == "o" and #lastTwo == 2 then
				local secondToLast = lastTwo:sub(1, 1)
				if not vowels[secondToLast] then
					suffix = "es"
				end
			end
			name = name .. suffix
		end
		if not wordOnly then
			return ("%s %s"):format(Roblox.formatInteger(num), name)
		else
			return name
		end
	end

	function Roblox.formatNumberTight(number)
		local order = math.log10(number)
		if order >= 3 and order < 6 then
			return ("%.1fK"):format(number / (10^3))
		end
		if order >= 6 and order < 9 then
			return ("%.1fM"):format(number / (10^6))
		end
		if order >= 9 then
			return ("%.1fB"):format(number / (10^9))
		end

		return tostring(math.floor(number + 0.5))
	end

	function Roblox.formatInteger(amount)
		amount = math.floor(amount + 0.5)
		local formatted = amount
		local numMatches
		repeat
			formatted, numMatches = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		until numMatches == 0
		return formatted
	end

	function Roblox.round(val, decimal)
		if decimal then
			return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
		else
			return math.floor(val + 0.5)
		end
	end

	function Roblox.formatNumber(number)
		local result, integral, fractional

		integral, fractional = math.modf(number)
		result = Roblox.formatInteger(integral)

		if fractional ~= 0 then
			result = result .. "." .. string.sub(tostring(math.abs(fractional)),3)
		end
		if number < 0 then
			result = "-" .. result
		end

		return result
	end

	function Roblox.isPointInsidePart(point, part)
		local localPos = part.CFrame:pointToObjectSpace(point)
		return math.abs(localPos.X) <= part.Size.X * 0.5 and math.abs(localPos.Y) <= part.Size.Y * 0.5 and math.abs(localPos.Z) <= part.Size.Z * 0.5
	end

	function Roblox.rayPlaneIntersect(ray, pointOnPlane, planeNormal)
		local Vd = planeNormal:Dot(ray.Direction)
		if Vd == 0 then -- parallel, no intersection
			return nil
		end

		local V0 = planeNormal:Dot(pointOnPlane - ray.Origin)
		local t = V0 / Vd
		if t < 0 then --plane is behind ray origin, and thus there is no intersection
			return nil
		end

		return ray.Origin + ray.Direction * t
	end

	function Roblox.debugPrint(t, level)
		level = level or 0
		local tabs = string.rep("\t", level)
		if typeof(t) == "table" then
			for key, val in pairs(t) do
				print(tabs, key, "=", val)
				if typeof(val) == "table" then
					Roblox.debugPrint(val, level + 1)
				end
			end
		end
	end

	local function findInstanceImpl(root, path, getChildFunc)
		local currentInstance = root

		while true do
			local nextChildName
			local nextSeparator = path:find("%.")
			if not nextSeparator then
				nextChildName = path
			else
				nextChildName = path:sub(1, nextSeparator - 1)
				path = path:sub(nextSeparator + 1)
			end

			local child = getChildFunc(currentInstance, nextChildName)
			if child then
				currentInstance = child
			else
				return nil
			end
		end
	end

	local function findFirstChildImpl(parent, childName)
		return parent:FindFirstChild(childName)
	end
	local function waitForChildImpl(parent, childName)
		return parent:WaitForChild(childName)
	end

	function Roblox.findInstance(root, path)
		return findInstanceImpl(root, path, findFirstChildImpl)
	end

	function Roblox.waitForInstance(root, path)
		return findInstanceImpl(root, path, waitForChildImpl)
	end

	function Roblox.penetrateCast(ray, ignoreList)
		debug.profilebegin("penetrateCast")
		local tries = 0
		local hitPart, hitPoint, hitNormal, hitMaterial = nil, ray.Origin + ray.Direction, Vector3.new(0, 1, 0), Enum.Material.Air
		while tries < 50 do
			tries = tries + 1
			hitPart, hitPoint, hitNormal, hitMaterial = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, true)
			if hitPart and (not hitPart.CanCollide or CollectionService:HasTag(hitPart, "DroppedItemPart") or CollectionService:HasTag(hitPart, "Hidden")) and hitPart.Parent:FindFirstChildOfClass("Humanoid") == nil then
				table.insert(ignoreList, hitPart)
			else
				break
			end
		end
		debug.profileend()
		return hitPart, hitPoint, hitNormal, hitMaterial
	end

	function Roblox.posInGuiObject(pos, guiObject)
		local guiMin = guiObject.AbsolutePosition
		local guiMax = guiMin + guiObject.AbsoluteSize
		return pos.X >= guiMin.X and pos.X <= guiMax.X and pos.Y >= guiMin.Y and pos.Y <= guiMax.Y
	end

	function Roblox.getUTCTime()
		local dateInfo = os.date("!*t")
		return string.format("%04d-%02d-%02d %02d:%02d:%02d", dateInfo.year, dateInfo.month, dateInfo.day, dateInfo.hour, dateInfo.min, dateInfo.sec)
	end

	function Roblox.getUTCTimestamp()
		return os.time(os.date("!*t"))
	end

	local DURATION_TOKENS = {
		{ "years",   "y",  31536000 },
		{ "months",  "mo", 2592000 },
		{ "weeks",   "w",  604800 },
		{ "days",    "d",  86400 },
		{ "hours",   "h",  3600 },
		{ "minutes", "m",  60 },
		{ "seconds", "s",  1 },
	}
	function Roblox.parseDurationInSeconds(inputStr)
		local tokensFound = {}
		local totalDurationSeconds = 0
		for _, tokenInfo in pairs(DURATION_TOKENS) do
			local numFound = string.match(inputStr, "(%d+)" .. tokenInfo[2])
			if numFound then
				local num = tonumber(numFound) or 0
				if num > 0 then
					table.insert(tokensFound, string.format("%d %s", num, tokenInfo[1]))
				end
				totalDurationSeconds = totalDurationSeconds + (num * tokenInfo[3])
			end
		end

		local outputStr = table.concat(tokensFound, ", ")
		return totalDurationSeconds, outputStr
	end

	local random = Random.new()
	function Roblox.chooseWeighted(choiceTable)
		local sum = 0
		for _, weight in pairs(choiceTable) do
			sum = sum + weight
		end

		local roll = random:NextNumber(0, 1)
		local choiceSum = 0
		for choiceName, weight in pairs(choiceTable) do
			local chance = weight / sum
			if roll >= choiceSum and roll < choiceSum + chance then
				return choiceName
			else
				choiceSum = choiceSum + chance
			end
		end

		return nil
	end

	function Roblox.hasMatchingTag(instance, tagPattern)
		for _, tagName in pairs(CollectionService:GetTags(instance)) do
			if tagName:match(tagPattern) ~= nil then
				return true
			end
		end
		return false
	end

	local highlightTweens = setmetatable({}, { __mode = 'k' })
	function Roblox.showHighlight(instance, show)
		local highlightInstance = instance:FindFirstChild("Highlight")
		if not highlightInstance or not highlightInstance:IsA("ImageLabel") then
			return
		end

		local existingTween = highlightTweens[instance]
		if existingTween then
			if show then
				return
			else
				existingTween:Cancel()
				highlightTweens[instance] = nil
				highlightInstance.ImageTransparency = 1
			end
		else
			if not show then
				return
			else
				coroutine.wrap(function()
					highlightInstance.ImageTransparency = 1
					local newTween = TweenService:Create(highlightInstance, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true), { ImageTransparency = 0 })
					highlightTweens[instance] = newTween
					while highlightTweens[instance] == newTween do
						newTween:Play()
						newTween.Completed:Wait()
					end
				end)()
			end
		end
	end

	function Roblox.getClickVerb(capitalize)
		local verb = "Click"
		if UserInputService.TouchEnabled then
			verb = "Tap"
		end

		if not capitalize then
			verb = verb:lower()
		end
		return verb
	end

	function Roblox.computeLaunchAngle(relativePoint, launchVelocity)
		local dx, dy = -relativePoint.Z, relativePoint.Y

		local g = workspace.Gravity
		local invRoot = (launchVelocity ^ 4) - (g * ((g * dx * dx) + (2 * dy * launchVelocity * launchVelocity)))
		if invRoot <= 0 then
			return math.pi / 4
		end

		local root = math.sqrt(invRoot)
		local angle1 = math.atan(((launchVelocity * launchVelocity) + root) / (g * dx))
		local angle2 = math.atan(((launchVelocity * launchVelocity) - root) / (g * dx))

		local chosenAngle = math.min(angle1, angle2)

		return chosenAngle
	end

	function Roblox.getClosestPointOnLine(line0, line1, point, doClamp)
		local lineVec = line1 - line0
		local pointFromLine0 = point - line0

		local dotProduct = lineVec:Dot(pointFromLine0)
		local t = dotProduct / (lineVec.Magnitude ^ 2)
		if doClamp ~= false then
			t = math.clamp(t, 0, 1)
		end
		local pointOnLine = line0:Lerp(line1, t)
		return pointOnLine, t, (point - pointOnLine).Magnitude
	end

	function Roblox.getClosestPointOnLines(referencePoint, lines)
		local closestPoint, closestDist, closestLine, closestT = nil, math.huge, nil, 0
		for i = 1, #lines do
			local lineA, lineB = lines[i][1], lines[i][2]

			local point, t, dist = Roblox.getClosestPointOnLine(lineA, lineB, referencePoint)
			if dist < closestDist then
				closestPoint = point
				closestDist = dist
				closestLine = i
				closestT = t
			end
		end

		return closestPoint, closestDist, closestLine, closestT
	end

	function Roblox.getPointInFrontOnLines(referencePoint, forwardOffset, lines)
		local closestPoint, _, closestLine, closestT = Roblox.getClosestPointOnLines(referencePoint, lines)
		if closestPoint then
			local pointOffset = closestPoint
			local offsetBudget = forwardOffset

			if closestLine == 1 and closestT == 0 then
				local beforeDist = (lines[1][1] - Roblox.getClosestPointOnLine(lines[1][1], lines[1][2], referencePoint, false)).Magnitude
				offsetBudget = offsetBudget - beforeDist
			end

			local lineDir = Vector3.new(0, 0, 0)
			while offsetBudget > 0 and closestLine <= #lines do
				local lineA, lineB = lines[closestLine][1], lines[closestLine][2]
				local lineVec = lineB - lineA
				local lineLength = lineVec.Magnitude
				local pointDistAlongLine = (pointOffset - lineA).Magnitude
				local distLeftOnLine = lineLength - pointDistAlongLine
				lineDir = lineVec.Unit

				if offsetBudget > distLeftOnLine then
					offsetBudget = offsetBudget - distLeftOnLine
					pointOffset = lineB
					closestLine = closestLine + 1
				else
					break
				end
			end
			pointOffset = pointOffset + lineDir * offsetBudget

			return pointOffset
		end
		return closestPoint
	end

	function Roblox.applySpread(unspreadDir, randomGenerator, minSpread, maxSpread)
		local spreadRotation = randomGenerator:NextNumber(-math.pi, math.pi)
		local spreadOffset = randomGenerator:NextNumber(minSpread, maxSpread)
		local spreadTransform = CFrame.fromAxisAngle(Vector3.new(math.cos(spreadRotation), math.sin(spreadRotation), 0), spreadOffset)
		local unspreadCFrame = CFrame.new(Vector3.new(), unspreadDir)
		return (unspreadCFrame * spreadTransform).LookVector
	end
end

local GetClosest = (function()
	local Humanoids = {}

	function AddHumanoid(Hum)
		local Root = Hum.RootPart
		if not Root then return end

		local Index = #Humanoids + 1
		table.insert(Humanoids, {Hum, Root})
		Hum.Destroying:Once(function()
			Humanoids[Index] = nil
		end)
	end

	for i, v in workspace:GetDescendants() do
		if v:IsA("Humanoid") then
			AddHumanoid(v)
		end
	end

	workspace.DescendantAdded:Connect(function(v)
		if v:IsA("Humanoid") then
			AddHumanoid(v)
		end
	end)

	return {
		Single = function(Position, Distance, Check)
			local Chosen, TRoot, THum, TPivot

			for Index, Data in Humanoids do
				local Hum, Root = table.unpack(Data)
				if not Hum.RootPart or Hum.Health <= 0 or Hum.Parent:GetAttribute("IgnoreRig") then continue end
				if Hum.Parent:FindFirstChildOfClass("BallSocketConstraint", true) or Hum.Parent:FindFirstChildOfClass("ForceField") then continue end
				if Check then
					if not Check(Hum.Parent) then
						continue
					end
				end
				if not Hum:IsDescendantOf(workspace) then
					Humanoids[Index] = nil
					continue
				end
				local Pivot = Root.CFrame

				local Magnitude = (Pivot.Position - Position).Magnitude
				if Magnitude < Distance then
					Distance = Magnitude
					Chosen = Root.Parent

					THum = Hum
					TRoot = Root
					TPivot = Pivot
				end
			end
			return Chosen, Distance, TRoot, THum, TPivot
		end,
		Collection = function(Position, Distance, Check)
			local Collect = {}
			for Index, Data in Humanoids do
				local Hum, Root = table.unpack(Data)	
				if not Hum.RootPart or Hum.Health <= 0 or Hum.Parent:GetAttribute("IgnoreRig") then continue end
				if Hum.Parent:FindFirstChildOfClass("BallSocketConstraint", true) or Hum.Parent:FindFirstChildOfClass("ForceField") then continue end
				if Check then
					if not Check(Hum.Parent) then
						continue
					end
				end
				if not Hum:IsDescendantOf(workspace) then
					Humanoids[Index] = nil
					continue
				end
				local Pivot = Root.CFrame

				local Magnitude = (Pivot.Position - Position).Magnitude
				if Magnitude < Distance then
					table.insert(Collect, {
						Root.Parent, Magnitude, Root, Hum, Pivot
					})
				end
			end

			return Collect
		end,
	}
end)()

local LibDeflate = (function()

	local Compression = {}
	local LibDeflate = {}

	Compression.Deflate = {}
	Compression.Zlib = {}
	Compression.Library = LibDeflate


	function Compression.Deflate.Compress(data, configs)
		return LibDeflate:CompressDeflate(data, configs)
	end


	function Compression.Deflate.Decompress(compressedData)
		return LibDeflate:DecompressDeflate(compressedData)
	end


	function Compression.Zlib.Compress(data, configs)
		return LibDeflate:CompressZlib(data, configs)
	end


	function Compression.Zlib.Decompress(compressedData)
		return LibDeflate:DecompressZlib(compressedData)
	end




	do
		-- Semantic version. all lowercase.
		-- Suffix can be alpha1, alpha2, beta1, beta2, rc1, rc2, etc.
		-- NOTE: Two version numbers needs to modify.
		-- 1. On the top of LibDeflate.lua
		-- 2. _VERSION
		-- 3. _MINOR

		-- version to store the official version of LibDeflate
		local _VERSION = "1.0.2-release"

		-- When MAJOR is changed, I should name it as LibDeflate2
		local _MAJOR = "LibDeflate"

		-- Update this whenever a new version, for LibStub version registration.
		-- 0 : v0.x
		-- 1 : v1.0.0
		-- 2 : v1.0.1
		-- 3 : v1.0.2
		local _MINOR = 3

		local _COPYRIGHT =
			"LibDeflate ".._VERSION
			.." Copyright (C) 2018-2020 Haoqian He."
			.." Licensed under the zlib License"

		-- Register in the World of Warcraft library "LibStub" if detected.
		LibDeflate = {}

		LibDeflate._VERSION = _VERSION
		LibDeflate._MAJOR = _MAJOR
		LibDeflate._MINOR = _MINOR
		LibDeflate._COPYRIGHT = _COPYRIGHT
	end

	-- localize Lua api for faster access.
	local assert = assert
	local error = error
	local pairs = pairs
	local string_byte = string.byte
	local string_char = string.char
	local string_find = string.find
	local string_gsub = string.gsub
	local string_sub = string.sub
	local table_concat = table.concat
	local table_sort = table.sort
	local tostring = tostring
	local type = type

	-- Converts i to 2^i, (0<=i<=32)
	-- This is used to implement bit left shift and bit right shift.
	-- "x >> y" in C:   "(x-x%_pow2[y])/_pow2[y]" in Lua
	-- "x << y" in C:   "x*_pow2[y]" in Lua
	local _pow2 = {}

	-- Converts any byte to a character, (0<=byte<=255)
	local _byte_to_char = {}

	-- _reverseBitsTbl[len][val] stores the bit reverse of
	-- the number with bit length "len" and value "val"
	-- For example, decimal number 6 with bits length 5 is binary 00110
	-- It's reverse is binary 01100,
	-- which is decimal 12 and 12 == _reverseBitsTbl[5][6]
	-- 1<=len<=9, 0<=val<=2^len-1
	-- The reason for 1<=len<=9 is that the max of min bitlen of huffman code
	-- of a huffman alphabet is 9?
	local _reverse_bits_tbl = {}

	-- Convert a LZ77 length (3<=len<=258) to
	-- a deflate literal/LZ77_length code (257<=code<=285)
	local _length_to_deflate_code = {}

	-- convert a LZ77 length (3<=len<=258) to
	-- a deflate literal/LZ77_length code extra bits.
	local _length_to_deflate_extra_bits = {}

	-- Convert a LZ77 length (3<=len<=258) to
	-- a deflate literal/LZ77_length code extra bit length.
	local _length_to_deflate_extra_bitlen = {}

	-- Convert a small LZ77 distance (1<=dist<=256) to a deflate code.
	local _dist256_to_deflate_code = {}

	-- Convert a small LZ77 distance (1<=dist<=256) to
	-- a deflate distance code extra bits.
	local _dist256_to_deflate_extra_bits = {}

	-- Convert a small LZ77 distance (1<=dist<=256) to
	-- a deflate distance code extra bit length.
	local _dist256_to_deflate_extra_bitlen = {}

	-- Convert a literal/LZ77_length deflate code to LZ77 base length
	-- The key of the table is (code - 256), 257<=code<=285
	local _literal_deflate_code_to_base_len = {
		3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
		35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258,
	}

	-- Convert a literal/LZ77_length deflate code to base LZ77 length extra bits
	-- The key of the table is (code - 256), 257<=code<=285
	local _literal_deflate_code_to_extra_bitlen = {
		0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
		3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0,
	}

	-- Convert a distance deflate code to base LZ77 distance. (0<=code<=29)
	local _dist_deflate_code_to_base_dist = {
		[0] = 1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
		257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
		8193, 12289, 16385, 24577,
	}

	-- Convert a distance deflate code to LZ77 bits length. (0<=code<=29)
	local _dist_deflate_code_to_extra_bitlen = {
		[0] = 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
		7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13,
	}

	-- The code order of the first huffman header in the dynamic deflate block.
	-- See the page 12 of RFC1951
	local _rle_codes_huffman_bitlen_order = {16, 17, 18,
		0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
	}

	-- The following tables are used by fixed deflate block.
	-- The value of these tables are assigned at the bottom of the source.

	-- The huffman code of the literal/LZ77_length deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_code

	-- Convert huffman code of the literal/LZ77_length to deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_to_deflate_code

	-- The bit length of the huffman code of literal/LZ77_length deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_bitlen

	-- The count of each bit length of the literal/LZ77_length deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_bitlen_count

	-- The huffman code of the distance deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_code

	-- Convert huffman code of the distance to deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_to_deflate_code

	-- The bit length of the huffman code of the distance deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_bitlen

	-- The count of each bit length of the huffman code of
	-- the distance deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_bitlen_count

	for i = 0, 255 do
		_byte_to_char[i] = string_char(i)
	end

	do
		local pow = 1
		for i = 0, 32 do
			_pow2[i] = pow
			pow = pow * 2
		end
	end

	for i = 1, 9 do
		_reverse_bits_tbl[i] = {}
		for j=0, _pow2[i+1]-1 do
			local reverse = 0
			local value = j
			for _ = 1, i do
				-- The following line is equivalent to "res | (code %2)" in C.
				reverse = reverse - reverse%2
					+ (((reverse%2==1) or (value % 2) == 1) and 1 or 0)
				value = (value-value%2)/2
				reverse = reverse * 2
			end
			_reverse_bits_tbl[i][j] = (reverse-reverse%2)/2
		end
	end

	-- The source code is written according to the pattern in the numbers
	-- in RFC1951 Page10.
	do
		local a = 18
		local b = 16
		local c = 265
		local bitlen = 1
		for len = 3, 258 do
			if len <= 10 then
				_length_to_deflate_code[len] = len + 254
				_length_to_deflate_extra_bitlen[len] = 0
			elseif len == 258 then
				_length_to_deflate_code[len] = 285
				_length_to_deflate_extra_bitlen[len] = 0
			else
				if len > a then
					a = a + b
					b = b * 2
					c = c + 4
					bitlen = bitlen + 1
				end
				local t = len-a-1+b/2
				_length_to_deflate_code[len] = (t-(t%(b/8)))/(b/8) + c
				_length_to_deflate_extra_bitlen[len] = bitlen
				_length_to_deflate_extra_bits[len] = t % (b/8)
			end
		end
	end

	-- The source code is written according to the pattern in the numbers
	-- in RFC1951 Page11.
	do
		_dist256_to_deflate_code[1] = 0
		_dist256_to_deflate_code[2] = 1
		_dist256_to_deflate_extra_bitlen[1] = 0
		_dist256_to_deflate_extra_bitlen[2] = 0

		local a = 3
		local b = 4
		local code = 2
		local bitlen = 0
		for dist = 3, 256 do
			if dist > b then
				a = a * 2
				b = b * 2
				code = code + 2
				bitlen = bitlen + 1
			end
			_dist256_to_deflate_code[dist] = (dist <= a) and code or (code+1)
			_dist256_to_deflate_extra_bitlen[dist] = (bitlen < 0) and 0 or bitlen
			if b >= 8 then
				_dist256_to_deflate_extra_bits[dist] = (dist-b/2-1) % (b/4)
			end
		end
	end

	--- Calculate the Adler-32 checksum of the string. <br>
	-- See RFC1950 Page 9 https://tools.ietf.org/html/rfc1950 for the
	-- definition of Adler-32 checksum.
	-- @param str [string] the input string to calcuate its Adler-32 checksum.
	-- @return [integer] The Adler-32 checksum, which is greater or equal to 0,
	-- and less than 2^32 (4294967296).
	function LibDeflate:Adler32(str)
		-- This function is loop unrolled by better performance.
		--
		-- Here is the minimum code:
		--
		-- local a = 1
		-- local b = 0
		-- for i=1, #str do
		-- 		local s = string.byte(str, i, i)
		-- 		a = (a+s)%65521
		-- 		b = (b+a)%65521
		-- 		end
		-- return b*65536+a
		if type(str) ~= "string" then
			error(("Usage: LibDeflate:Adler32(str):"
				.." 'str' - string expected got '%s'."):format(type(str)), 2)
		end
		local strlen = #str

		local i = 1
		local a = 1
		local b = 0
		while i <= strlen - 15 do
			local x1, x2, x3, x4, x5, x6, x7, x8,
			x9, x10, x11, x12, x13, x14, x15, x16 = string_byte(str, i, i+15)
			b = (b+16*a+16*x1+15*x2+14*x3+13*x4+12*x5+11*x6+10*x7+9*x8+8*x9
				+7*x10+6*x11+5*x12+4*x13+3*x14+2*x15+x16)%65521
			a = (a+x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14+x15+x16)%65521
			i =  i + 16
		end
		while (i <= strlen) do
			local x = string_byte(str, i, i)
			a = (a + x) % 65521
			b = (b + a) % 65521
			i = i + 1
		end
		return (b*65536+a) % 4294967296
	end

	-- Compare adler32 checksum.
	-- adler32 should be compared with a mod to avoid sign problem
	-- 4072834167 (unsigned) is the same adler32 as -222133129
	local function IsEqualAdler32(actual, expected)
		return (actual % 4294967296) == (expected % 4294967296)
	end

	--- Create a preset dictionary.
	--
	-- This function is not fast, and the memory consumption of the produced
	-- dictionary is about 50 times of the input string. Therefore, it is suggestted
	-- to run this function only once in your program.
	--
	-- It is very important to know that if you do use a preset dictionary,
	-- compressors and decompressors MUST USE THE SAME dictionary. That is,
	-- dictionary must be created using the same string. If you update your program
	-- with a new dictionary, people with the old version won't be able to transmit
	-- data with people with the new version. Therefore, changing the dictionary
	-- must be very careful.
	--
	-- The parameters "strlen" and "adler32" add a layer of verification to ensure
	-- the parameter "str" is not modified unintentionally during the program
	-- development.
	--
	-- @usage local dict_str = "1234567890"
	--
	-- -- print(dict_str:len(), LibDeflate:Adler32(dict_str))
	-- -- Hardcode the print result below to verify it to avoid acciently
	-- -- modification of 'str' during the program development.
	-- -- string length: 10, Adler-32: 187433486,
	-- -- Don't calculate string length and its Adler-32 at run-time.
	--
	-- local dict = LibDeflate:CreateDictionary(dict_str, 10, 187433486)
	--
	-- @param str [string] The string used as the preset dictionary. <br>
	-- You should put stuffs that frequently appears in the dictionary
	-- string and preferablely put more frequently appeared stuffs toward the end
	-- of the string. <br>
	-- Empty string and string longer than 32768 bytes are not allowed.
	-- @param strlen [integer] The length of 'str'. Please pass in this parameter
	-- as a hardcoded constant, in order to verify the content of 'str'. The value
	-- of this parameter should be known before your program runs.
	-- @param adler32 [integer] The Adler-32 checksum of 'str'. Please pass in this
	-- parameter as a hardcoded constant, in order to verify the content of 'str'.
	-- The value of this parameter should be known before your program runs.
	-- @return  [table] The dictionary used for preset dictionary compression and
	-- decompression.
	-- @raise error if 'strlen' does not match the length of 'str',
	-- or if 'adler32' does not match the Adler-32 checksum of 'str'.
	function LibDeflate:CreateDictionary(str, strlen, adler32)
		if type(str) ~= "string" then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'str' - string expected got '%s'."):format(type(str)), 2)
		end
		if type(strlen) ~= "number" then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'strlen' - number expected got '%s'."):format(
					type(strlen)), 2)
		end
		if type(adler32) ~= "number" then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'adler32' - number expected got '%s'."):format(
					type(adler32)), 2)
		end
		if strlen ~= #str then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'strlen' does not match the actual length of 'str'."
				.." 'strlen': %u, '#str': %u ."
				.." Please check if 'str' is modified unintentionally.")
				:format(strlen, #str))
		end
		if strlen == 0 then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'str' - Empty string is not allowed."), 2)
		end
		if strlen > 32768 then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'str' - string longer than 32768 bytes is not allowed."
				.." Got %d bytes."):format(strlen), 2)
		end
		local actual_adler32 = self:Adler32(str)
		if not IsEqualAdler32(adler32, actual_adler32) then
			error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32):"
				.." 'adler32' does not match the actual adler32 of 'str'."
				.." 'adler32': %u, 'Adler32(str)': %u ."
				.." Please check if 'str' is modified unintentionally.")
				:format(adler32, actual_adler32))
		end

		local dictionary = {}
		dictionary.adler32 = adler32
		dictionary.hash_tables = {}
		dictionary.string_table = {}
		dictionary.strlen = strlen
		local string_table = dictionary.string_table
		local hash_tables = dictionary.hash_tables
		string_table[1] = string_byte(str, 1, 1)
		string_table[2] = string_byte(str, 2, 2)
		if strlen >= 3 then
			local i = 1
			local hash = string_table[1]*256+string_table[2]
			while i <= strlen - 2 - 3 do
				local x1, x2, x3, x4 = string_byte(str, i+2, i+5)
				string_table[i+2] = x1
				string_table[i+3] = x2
				string_table[i+4] = x3
				string_table[i+5] = x4
				hash = (hash*256+x1)%16777216
				local t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = i-strlen
				i = i + 1
				hash = (hash*256+x2)%16777216
				t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = i-strlen
				i = i + 1
				hash = (hash*256+x3)%16777216
				t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = i-strlen
				i = i + 1
				hash = (hash*256+x4)%16777216
				t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = i-strlen
				i = i + 1
			end
			while i <= strlen - 2 do
				local x = string_byte(str, i+2)
				string_table[i+2] = x
				hash = (hash*256+x)%16777216
				local t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = i-strlen
				i = i + 1
			end
		end
		return dictionary
	end

	-- Check if the dictionary is valid.
	-- @param dictionary The preset dictionary for compression and decompression.
	-- @return true if valid, false if not valid.
	-- @return if not valid, the error message.
	local function IsValidDictionary(dictionary)
		if type(dictionary) ~= "table" then
			return false, ("'dictionary' - table expected got '%s'.")
				:format(type(dictionary))
		end
		if type(dictionary.adler32) ~= "number"
			or type(dictionary.string_table) ~= "table"
			or type(dictionary.strlen) ~= "number"
			or dictionary.strlen <= 0
			or dictionary.strlen > 32768
			or dictionary.strlen ~= #dictionary.string_table
			or type(dictionary.hash_tables) ~= "table"
		then
			return false, ("'dictionary' - corrupted dictionary.")
				:format(type(dictionary))
		end
		return true, ""
	end

--[[
	key of the configuration table is the compression level,
	and its value stores the compression setting.
	These numbers come from zlib source code.
	Higher compression level usually means better compression.
	(Because LibDeflate uses a simplified version of zlib algorithm,
	there is no guarantee that higher compression level does not create
	bigger file than lower level, but I can say it's 99% likely)
	Be careful with the high compression level. This is a pure lua
	implementation compressor/decompressor, which is significant slower than
	a C/C++ equivalant compressor/decompressor. Very high compression level
	costs significant more CPU time, and usually compression size won't be
	significant smaller when you increase compression level by 1, when the
	level is already very high. Benchmark yourself if you can afford it.
	See also https://github.com/madler/zlib/blob/master/doc/algorithm.txt,
	https://github.com/madler/zlib/blob/master/deflate.c for more information.
	The meaning of each field:
	@field 1 use_lazy_evaluation:
		true/false. Whether the program uses lazy evaluation.
		See what is "lazy evaluation" in the link above.
		lazy_evaluation improves ratio, but relatively slow.
	@field 2 good_prev_length:
		Only effective if lazy is set, Only use 1/4 of max_chain,
		if prev length of lazy match is above this.
	@field 3 max_insert_length/max_lazy_match:
		If not using lazy evaluation,
		insert new strings in the hash table only if the match length is not
		greater than this length.
		If using lazy evaluation, only continue lazy evaluation,
		if previous match length is strictly smaller than this value.
	@field 4 nice_length:
		Number. Don't continue to go down the hash chain,
		if match length is above this.
	@field 5 max_chain:
		Number. The maximum number of hash chains we look.
--]]
	local _compression_level_configs = {
		[0] = {false, nil, 0, 0, 0}, -- level 0, no compression
		[1] = {false, nil, 4, 8, 4}, -- level 1, similar to zlib level 1
		[2] = {false, nil, 5, 18, 8}, -- level 2, similar to zlib level 2
		[3] = {false, nil, 6, 32, 32},	-- level 3, similar to zlib level 3
		[4] = {true, 4,	4, 16, 16},	-- level 4, similar to zlib level 4
		[5] = {true, 8,	16,	32,	32}, -- level 5, similar to zlib level 5
		[6] = {true, 8,	16,	128, 128}, -- level 6, similar to zlib level 6
		[7] = {true, 8,	32,	128, 256}, -- (SLOW) level 7, similar to zlib level 7
		[8] = {true, 32, 128, 258, 1024} , --(SLOW) level 8,similar to zlib level 8
		[9] = {true, 32, 258, 258, 4096},
		-- (VERY SLOW) level 9, similar to zlib level 9
	}

	-- Check if the compression/decompression arguments is valid
	-- @param str The input string.
	-- @param check_dictionary if true, check if dictionary is valid.
	-- @param dictionary The preset dictionary for compression and decompression.
	-- @param check_configs if true, check if config is valid.
	-- @param configs The compression configuration table
	-- @return true if valid, false if not valid.
	-- @return if not valid, the error message.
	local function IsValidArguments(str,
		check_dictionary, dictionary,
		check_configs, configs)

		if type(str) ~= "string" then
			return false,
			("'str' - string expected got '%s'."):format(type(str))
		end
		if check_dictionary then
			local dict_valid, dict_err = IsValidDictionary(dictionary)
			if not dict_valid then
				return false, dict_err
			end
		end
		if check_configs then
			local type_configs = type(configs)
			if type_configs ~= "nil" and type_configs ~= "table" then
				return false,
				("'configs' - nil or table expected got '%s'.")
					:format(type(configs))
			end
			if type_configs == "table" then
				for k, v in pairs(configs) do
					if k ~= "level" and k ~= "strategy" then
						return false,
						("'configs' - unsupported table key in the configs: '%s'.")
							:format(k)
					elseif k == "level" and not _compression_level_configs[v] then
						return false,
						("'configs' - unsupported 'level': %s."):format(tostring(v))
					elseif k == "strategy" and v ~= "fixed" and v ~= "huffman_only"
						and v ~= "dynamic" then
						-- random_block_type is for testing purpose
						return false, ("'configs' - unsupported 'strategy': '%s'.")
							:format(tostring(v))
					end
				end
			end
		end
		return true, ""
	end



--[[ --------------------------------------------------------------------------
	Compress code
--]] --------------------------------------------------------------------------

	-- partial flush to save memory
	local _FLUSH_MODE_MEMORY_CLEANUP = 0
	-- full flush with partial bytes
	local _FLUSH_MODE_OUTPUT = 1
	-- write bytes to get to byte boundary
	local _FLUSH_MODE_BYTE_BOUNDARY = 2
	-- no flush, just get num of bits written so far
	local _FLUSH_MODE_NO_FLUSH = 3

--[[
	Create an empty writer to easily write stuffs as the unit of bits.
	Return values:
	1. WriteBits(code, bitlen):
	2. WriteString(str):
	3. Flush(mode):
--]]

	local step = 0

	local function CreateWriter()
		local buffer_size = 0
		local cache = 0
		local cache_bitlen = 0
		local total_bitlen = 0
		local buffer = {}
		-- When buffer is big enough, flush into result_buffer to save memory.
		local result_buffer = {}

		-- Write bits with value "value" and bit length of "bitlen" into writer.
		-- @param value: The value being written
		-- @param bitlen: The bit length of "value"
		-- @return nil
		local function WriteBits(value, bitlen)
			step += 1
			cache = cache + value * _pow2[cache_bitlen]
			cache_bitlen = cache_bitlen + bitlen
			total_bitlen = total_bitlen + bitlen

			if step % 800 == 0 then
				task.wait()
			end
			-- Only bulk to buffer every 4 bytes. This is quicker.
			if cache_bitlen >= 32 then
				buffer_size = buffer_size + 1
				buffer[buffer_size] =
					_byte_to_char[cache % 256]
					.._byte_to_char[((cache-cache%256)/256 % 256)]
					.._byte_to_char[((cache-cache%65536)/65536 % 256)]
					.._byte_to_char[((cache-cache%16777216)/16777216 % 256)]
				local rshift_mask = _pow2[32 - cache_bitlen + bitlen]
				cache = (value - value%rshift_mask)/rshift_mask
				cache_bitlen = cache_bitlen - 32
			end
		end

		-- Write the entire string into the writer.
		-- @param str The string being written
		-- @return nil
		local function WriteString(str)
			for _ = 1, cache_bitlen, 8 do
				buffer_size = buffer_size + 1
				buffer[buffer_size] = string_char(cache % 256)
				cache = (cache-cache%256)/256
			end
			cache_bitlen = 0
			buffer_size = buffer_size + 1
			buffer[buffer_size] = str
			total_bitlen = total_bitlen + #str*8
		end

		-- Flush current stuffs in the writer and return it.
		-- This operation will free most of the memory.
		-- @param mode See the descrtion of the constant and the source code.
		-- @return The total number of bits stored in the writer right now.
		-- for byte boundary mode, it includes the padding bits.
		-- for output mode, it does not include padding bits.
		-- @return Return the outputs if mode is output.
		local function FlushWriter(mode)
			if mode == _FLUSH_MODE_NO_FLUSH then
				return total_bitlen
			end

			if mode == _FLUSH_MODE_OUTPUT
				or mode == _FLUSH_MODE_BYTE_BOUNDARY then
				-- Full flush, also output cache.
				-- Need to pad some bits if cache_bitlen is not multiple of 8.
				local padding_bitlen = (8 - cache_bitlen % 8) % 8

				if cache_bitlen > 0 then
					-- padding with all 1 bits, mainly because "\000" is not
					-- good to be tranmitted. I do this so "\000" is a little bit
					-- less frequent.
					cache = cache - _pow2[cache_bitlen]
						+ _pow2[cache_bitlen+padding_bitlen]
					for _ = 1, cache_bitlen, 8 do
						buffer_size = buffer_size + 1
						buffer[buffer_size] = _byte_to_char[cache % 256]
						cache = (cache-cache%256)/256
					end

					cache = 0
					cache_bitlen = 0
				end
				if mode == _FLUSH_MODE_BYTE_BOUNDARY then
					total_bitlen = total_bitlen + padding_bitlen
					return total_bitlen
				end
			end

			local flushed = table_concat(buffer)
			buffer = {}
			buffer_size = 0
			result_buffer[#result_buffer+1] = flushed

			if mode == _FLUSH_MODE_MEMORY_CLEANUP then
				return total_bitlen
			else
				return total_bitlen, table_concat(result_buffer)
			end
		end

		return WriteBits, WriteString, FlushWriter
	end

	-- Push an element into a max heap
	-- @param heap A max heap whose max element is at index 1.
	-- @param e The element to be pushed. Assume element "e" is a table
	--  and comparison is done via its first entry e[1]
	-- @param heap_size current number of elements in the heap.
	--  NOTE: There may be some garbage stored in
	--  heap[heap_size+1], heap[heap_size+2], etc..
	-- @return nil
	local function MinHeapPush(heap, e, heap_size)
		heap_size = heap_size + 1
		heap[heap_size] = e
		local value = e[1]
		local pos = heap_size
		local parent_pos = (pos-pos%2)/2

		while (parent_pos >= 1 and heap[parent_pos][1] > value) do
			local t = heap[parent_pos]
			heap[parent_pos] = e
			heap[pos] = t
			pos = parent_pos
			parent_pos = (parent_pos-parent_pos%2)/2
		end
	end

	-- Pop an element from a max heap
	-- @param heap A max heap whose max element is at index 1.
	-- @param heap_size current number of elements in the heap.
	-- @return the poped element
	-- Note: This function does not change table size of "heap" to save CPU time.
	local function MinHeapPop(heap, heap_size)
		local top = heap[1]
		local e = heap[heap_size]
		local value = e[1]
		heap[1] = e
		heap[heap_size] = top
		heap_size = heap_size - 1

		local pos = 1
		local left_child_pos = pos * 2
		local right_child_pos = left_child_pos + 1

		while (left_child_pos <= heap_size) do
			local left_child = heap[left_child_pos]
			if (right_child_pos <= heap_size
				and heap[right_child_pos][1] < left_child[1]) then
				local right_child = heap[right_child_pos]
				if right_child[1] < value then
					heap[right_child_pos] = e
					heap[pos] = right_child
					pos = right_child_pos
					left_child_pos = pos * 2
					right_child_pos = left_child_pos + 1
				else
					break
				end
			else
				if left_child[1] < value then
					heap[left_child_pos] = e
					heap[pos] = left_child
					pos = left_child_pos
					left_child_pos = pos * 2
					right_child_pos = left_child_pos + 1
				else
					break
				end
			end
		end

		return top
	end

	-- Deflate defines a special huffman tree, which is unique once the bit length
	-- of huffman code of all symbols are known.
	-- @param bitlen_count Number of symbols with a specific bitlen
	-- @param symbol_bitlen The bit length of a symbol
	-- @param max_symbol The max symbol among all symbols,
	--		which is (number of symbols - 1)
	-- @param max_bitlen The max huffman bit length among all symbols.
	-- @return The huffman code of all symbols.
	local function GetHuffmanCodeFromBitlen(bitlen_counts, symbol_bitlens
		, max_symbol, max_bitlen)
		local huffman_code = 0
		local next_codes = {}
		local symbol_huffman_codes = {}
		for bitlen = 1, max_bitlen do
			huffman_code = (huffman_code+(bitlen_counts[bitlen-1] or 0))*2
			next_codes[bitlen] = huffman_code
		end
		for symbol = 0, max_symbol do
			local bitlen = symbol_bitlens[symbol]
			if bitlen then
				huffman_code = next_codes[bitlen]
				next_codes[bitlen] = huffman_code + 1

				-- Reverse the bits of huffman code,
				-- because most signifant bits of huffman code
				-- is stored first into the compressed data.
				-- @see RFC1951 Page5 Section 3.1.1
				if bitlen <= 9 then -- Have cached reverse for small bitlen.
					symbol_huffman_codes[symbol] =
						_reverse_bits_tbl[bitlen][huffman_code]
				else
					local reverse = 0
					for _ = 1, bitlen do
						reverse = reverse - reverse%2
							+ (((reverse%2==1)
								or (huffman_code % 2) == 1) and 1 or 0)
						huffman_code = (huffman_code-huffman_code%2)/2
						reverse = reverse*2
					end
					symbol_huffman_codes[symbol] = (reverse-reverse%2)/2
				end
			end
		end
		return symbol_huffman_codes
	end

	-- A helper function to sort heap elements
	-- a[1], b[1] is the huffman frequency
	-- a[2], b[2] is the symbol value.
	local function SortByFirstThenSecond(a, b)
		return a[1] < b[1] or
			(a[1] == b[1] and a[2] < b[2])
	end

	-- Calculate the huffman bit length and huffman code.
	-- @param symbol_count: A table whose table key is the symbol, and table value
	--		is the symbol frenquency (nil means 0 frequency).
	-- @param max_bitlen: See description of return value.
	-- @param max_symbol: The maximum symbol
	-- @return a table whose key is the symbol, and the value is the huffman bit
	--		bit length. We guarantee that all bit length <= max_bitlen.
	--		For 0<=symbol<=max_symbol, table value could be nil if the frequency
	--		of the symbol is 0 or nil.
	-- @return a table whose key is the symbol, and the value is the huffman code.
	-- @return a number indicating the maximum symbol whose bitlen is not 0.
	local function GetHuffmanBitlenAndCode(symbol_counts, max_bitlen, max_symbol)
		local heap_size
		local max_non_zero_bitlen_symbol = -1
		local leafs = {}
		local heap = {}
		local symbol_bitlens = {}
		local symbol_codes = {}
		local bitlen_counts = {}

	--[[
		tree[1]: weight, temporarily used as parent and bitLengths
		tree[2]: symbol
		tree[3]: left child
		tree[4]: right child
	--]]
		local number_unique_symbols = 0
		for symbol, count in pairs(symbol_counts) do
			number_unique_symbols = number_unique_symbols + 1
			leafs[number_unique_symbols] = {count, symbol}
		end

		if (number_unique_symbols == 0) then
			-- no code.
			return {}, {}, -1
		elseif (number_unique_symbols == 1) then
			-- Only one code. In this case, its huffman code
			-- needs to be assigned as 0, and bit length is 1.
			-- This is the only case that the return result
			-- represents an imcomplete huffman tree.
			local symbol = leafs[1][2]
			symbol_bitlens[symbol] = 1
			symbol_codes[symbol] = 0
			return symbol_bitlens, symbol_codes, symbol
		else
			table_sort(leafs, SortByFirstThenSecond)
			heap_size = number_unique_symbols
			for i = 1, heap_size do
				heap[i] = leafs[i]
			end

			while (heap_size > 1) do
				-- Note: pop does not change table size of heap
				local leftChild = MinHeapPop(heap, heap_size)
				heap_size = heap_size - 1
				local rightChild = MinHeapPop(heap, heap_size)
				heap_size = heap_size - 1
				local newNode =
					{leftChild[1]+rightChild[1], -1, leftChild, rightChild}
				MinHeapPush(heap, newNode, heap_size)
				heap_size = heap_size + 1
			end

			-- Number of leafs whose bit length is greater than max_len.
			local number_bitlen_overflow = 0

			-- Calculate bit length of all nodes
			local fifo = {heap[1], 0, 0, 0} -- preallocate some spaces.
			local fifo_size = 1
			local index = 1
			heap[1][1] = 0
			while (index <= fifo_size) do -- Breath first search
				local e = fifo[index]
				local bitlen = e[1]
				local symbol = e[2]
				local left_child = e[3]
				local right_child = e[4]
				if left_child then
					fifo_size = fifo_size + 1
					fifo[fifo_size] = left_child
					left_child[1] = bitlen + 1
				end
				if right_child then
					fifo_size = fifo_size + 1
					fifo[fifo_size] = right_child
					right_child[1] = bitlen + 1
				end
				index = index + 1

				if (bitlen > max_bitlen) then
					number_bitlen_overflow = number_bitlen_overflow + 1
					bitlen = max_bitlen
				end
				if symbol >= 0 then
					symbol_bitlens[symbol] = bitlen
					max_non_zero_bitlen_symbol =
						(symbol > max_non_zero_bitlen_symbol)
						and symbol or max_non_zero_bitlen_symbol
					bitlen_counts[bitlen] = (bitlen_counts[bitlen] or 0) + 1
				end
			end

			-- Resolve bit length overflow
			-- @see ZLib/trees.c:gen_bitlen(s, desc), for reference
			if (number_bitlen_overflow > 0) then
				repeat
					local bitlen = max_bitlen - 1
					while ((bitlen_counts[bitlen] or 0) == 0) do
						bitlen = bitlen - 1
					end
					-- move one leaf down the tree
					bitlen_counts[bitlen] = bitlen_counts[bitlen] - 1
					-- move one overflow item as its brother
					bitlen_counts[bitlen+1] = (bitlen_counts[bitlen+1] or 0) + 2
					bitlen_counts[max_bitlen] = bitlen_counts[max_bitlen] - 1
					number_bitlen_overflow = number_bitlen_overflow - 2
				until (number_bitlen_overflow <= 0)

				index = 1
				for bitlen = max_bitlen, 1, -1 do
					local n = bitlen_counts[bitlen] or 0
					while (n > 0) do
						local symbol = leafs[index][2]
						symbol_bitlens[symbol] = bitlen
						n = n - 1
						index = index + 1
					end
				end
			end

			symbol_codes = GetHuffmanCodeFromBitlen(bitlen_counts, symbol_bitlens,
				max_symbol, max_bitlen)
			return symbol_bitlens, symbol_codes, max_non_zero_bitlen_symbol
		end
	end

	-- Calculate the first huffman header in the dynamic huffman block
	-- @see RFC1951 Page 12
	-- @param lcode_bitlen: The huffman bit length of literal/LZ77_length.
	-- @param max_non_zero_bitlen_lcode: The maximum literal/LZ77_length symbol
	--		whose huffman bit length is not zero.
	-- @param dcode_bitlen: The huffman bit length of LZ77 distance.
	-- @param max_non_zero_bitlen_dcode: The maximum LZ77 distance symbol
	--		whose huffman bit length is not zero.
	-- @return The run length encoded codes.
	-- @return The extra bits. One entry for each rle code that needs extra bits.
	--		(code == 16 or 17 or 18).
	-- @return The count of appearance of each rle codes.
	local function RunLengthEncodeHuffmanBitlen(
		lcode_bitlens,
		max_non_zero_bitlen_lcode,
		dcode_bitlens,
		max_non_zero_bitlen_dcode)
		local rle_code_tblsize = 0
		local rle_codes = {}
		local rle_code_counts = {}
		local rle_extra_bits_tblsize = 0
		local rle_extra_bits = {}
		local prev = nil
		local count = 0

		-- If there is no distance code, assume one distance code of bit length 0.
		-- RFC1951: One distance code of zero bits means that
		-- there are no distance codes used at all (the data is all literals).
		max_non_zero_bitlen_dcode = (max_non_zero_bitlen_dcode < 0)
			and 0 or max_non_zero_bitlen_dcode
		local max_code = max_non_zero_bitlen_lcode+max_non_zero_bitlen_dcode+1

		for code = 0, max_code+1 do
			local len = (code <= max_non_zero_bitlen_lcode)
				and (lcode_bitlens[code] or 0)
				or ((code <= max_code)
					and (dcode_bitlens[code-max_non_zero_bitlen_lcode-1] or 0) or nil)
			if len == prev then
				count = count + 1
				if len ~= 0 and count == 6 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = 16
					rle_extra_bits_tblsize = rle_extra_bits_tblsize + 1
					rle_extra_bits[rle_extra_bits_tblsize] = 3
					rle_code_counts[16] = (rle_code_counts[16] or 0) + 1
					count = 0
				elseif len == 0 and count == 138 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = 18
					rle_extra_bits_tblsize = rle_extra_bits_tblsize + 1
					rle_extra_bits[rle_extra_bits_tblsize] = 127
					rle_code_counts[18] = (rle_code_counts[18] or 0) + 1
					count = 0
				end
			else
				if count == 1 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = prev
					rle_code_counts[prev] = (rle_code_counts[prev] or 0) + 1
				elseif count == 2 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = prev
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = prev
					rle_code_counts[prev] = (rle_code_counts[prev] or 0) + 2
				elseif count >= 3 then
					rle_code_tblsize = rle_code_tblsize + 1
					local rleCode = (prev ~= 0) and 16 or (count <= 10 and 17 or 18)
					rle_codes[rle_code_tblsize] = rleCode
					rle_code_counts[rleCode] = (rle_code_counts[rleCode] or 0) + 1
					rle_extra_bits_tblsize = rle_extra_bits_tblsize + 1
					rle_extra_bits[rle_extra_bits_tblsize] =
						(count <= 10) and (count - 3) or (count - 11)
				end

				prev = len
				if len and len ~= 0 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = len
					rle_code_counts[len] = (rle_code_counts[len] or 0) + 1
					count = 0
				else
					count = 1
				end
			end
		end

		return rle_codes, rle_extra_bits, rle_code_counts
	end

	-- Load the string into a table, in order to speed up LZ77.
	-- Loop unrolled 16 times to speed this function up.
	-- @param str The string to be loaded.
	-- @param t The load destination
	-- @param start str[index] will be the first character to be loaded.
	-- @param end str[index] will be the last character to be loaded
	-- @param offset str[index] will be loaded into t[index-offset]
	-- @return t
	local function LoadStringToTable(str, t, start, stop, offset)
		local i = start - offset
		while i <= stop - 15 - offset do
			t[i], t[i+1], t[i+2], t[i+3], t[i+4], t[i+5], t[i+6], t[i+7], t[i+8],
			t[i+9], t[i+10], t[i+11], t[i+12], t[i+13], t[i+14], t[i+15] =
				string_byte(str, i + offset, i + 15 + offset)
			i = i + 16
		end
		while (i <= stop - offset) do
			t[i] = string_byte(str, i + offset, i + offset)
			i = i + 1
		end
		return t
	end

	-- Do LZ77 process. This function uses the majority of the CPU time.
	-- @see zlib/deflate.c:deflate_fast(), zlib/deflate.c:deflate_slow()
	-- @see https://github.com/madler/zlib/blob/master/doc/algorithm.txt
	-- This function uses the algorithms used above. You should read the
	-- algorithm.txt above to understand what is the hash function and the
	-- lazy evaluation.
	--
	-- The special optimization used here is hash functions used here.
	-- The hash function is just the multiplication of the three consective
	-- characters. So if the hash matches, it guarantees 3 characters are matched.
	-- This optimization can be implemented because Lua table is a hash table.
	--
	-- @param level integer that describes compression level.
	-- @param string_table table that stores the value of string to be compressed.
	--			The index of this table starts from 1.
	--			The caller needs to make sure all values needed by this function
	--			are loaded.
	--			Assume "str" is the origin input string into the compressor
	--			str[block_start]..str[block_end+3] needs to be loaded into
	--			string_table[block_start-offset]..string_table[block_end-offset]
	--			If dictionary is presented, the last 258 bytes of the dictionary
	--			needs to be loaded into sing_table[-257..0]
	--			(See more in the description of offset.)
	-- @param hash_tables. The table key is the hash value (0<=hash<=16777216=256^3)
	--			The table value is an array0 that stores the indexes of the
	--			input data string to be compressed, such that
	--			hash == str[index]*str[index+1]*str[index+2]
	--			Indexes are ordered in this array.
	-- @param block_start The indexes of the input data string to be compressed.
	--				that starts the LZ77 block.
	-- @param block_end The indexes of the input data string to be compressed.
	--				that stores the LZ77 block.
	-- @param offset str[index] is stored in string_table[index-offset],
	--			This offset is mainly an optimization to limit the index
	--			of string_table, so lua can access this table quicker.
	-- @param dictionary See LibDeflate:CreateDictionary
	-- @return literal/LZ77_length deflate codes.
	-- @return the extra bits of literal/LZ77_length deflate codes.
	-- @return the count of each literal/LZ77 deflate code.
	-- @return LZ77 distance deflate codes.
	-- @return the extra bits of LZ77 distance deflate codes.
	-- @return the count of each LZ77 distance deflate code.
	local function GetBlockLZ77Result(level, string_table, hash_tables, block_start,
		block_end, offset, dictionary)
		local config = _compression_level_configs[level]
		local config_use_lazy
		, config_good_prev_length
		, config_max_lazy_match
		, config_nice_length
		, config_max_hash_chain =
			config[1], config[2], config[3], config[4], config[5]

		local config_max_insert_length = (not config_use_lazy)
			and config_max_lazy_match or 2147483646
		local config_good_hash_chain =
			(config_max_hash_chain-config_max_hash_chain%4/4)

		local hash

		local dict_hash_tables
		local dict_string_table
		local dict_string_len = 0

		if dictionary then
			dict_hash_tables = dictionary.hash_tables
			dict_string_table = dictionary.string_table
			dict_string_len = dictionary.strlen
			assert(block_start == 1)
			if block_end >= block_start and dict_string_len >= 2 then
				hash = dict_string_table[dict_string_len-1]*65536
					+ dict_string_table[dict_string_len]*256 + string_table[1]
				local t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = -1
			end
			if block_end >= block_start+1 and dict_string_len >= 1 then
				hash = dict_string_table[dict_string_len]*65536
					+ string_table[1]*256 + string_table[2]
				local t = hash_tables[hash]
				if not t then t = {}; hash_tables[hash] = t end
				t[#t+1] = 0
			end
		end

		local dict_string_len_plus3 = dict_string_len + 3

		hash = (string_table[block_start-offset] or 0)*256
			+ (string_table[block_start+1-offset] or 0)

		local lcodes = {}
		local lcode_tblsize = 0
		local lcodes_counts = {}
		local dcodes = {}
		local dcodes_tblsize = 0
		local dcodes_counts = {}

		local lextra_bits = {}
		local lextra_bits_tblsize = 0
		local dextra_bits = {}
		local dextra_bits_tblsize = 0

		local match_available = false
		local prev_len
		local prev_dist
		local cur_len = 0
		local cur_dist = 0

		local index = block_start
		local index_end = block_end + (config_use_lazy and 1 or 0)

		-- the zlib source code writes separate code for lazy evaluation and
		-- not lazy evaluation, which is easier to understand.
		-- I put them together, so it is a bit harder to understand.
		-- because I think this is easier for me to maintain it.
		while (index <= index_end) do
			local string_table_index = index - offset
			local offset_minus_three = offset - 3
			prev_len = cur_len
			prev_dist = cur_dist
			cur_len = 0

			hash = (hash*256+(string_table[string_table_index+2] or 0))%16777216

			local chain_index
			local cur_chain
			local hash_chain = hash_tables[hash]
			local chain_old_size
			if not hash_chain then
				chain_old_size = 0
				hash_chain = {}
				hash_tables[hash] = hash_chain
				if dict_hash_tables then
					cur_chain = dict_hash_tables[hash]
					chain_index = cur_chain and #cur_chain or 0
				else
					chain_index = 0
				end
			else
				chain_old_size = #hash_chain
				cur_chain = hash_chain
				chain_index = chain_old_size
			end

			if index <= block_end then
				hash_chain[chain_old_size+1] = index
			end

			if (chain_index > 0 and index + 2 <= block_end
				and (not config_use_lazy or prev_len < config_max_lazy_match)) then

				local depth =
					(config_use_lazy and prev_len >= config_good_prev_length)
					and config_good_hash_chain or config_max_hash_chain

				local max_len_minus_one = block_end - index
				max_len_minus_one = (max_len_minus_one >= 257) and 257 or max_len_minus_one
				max_len_minus_one = max_len_minus_one + string_table_index
				local string_table_index_plus_three = string_table_index + 3

				while chain_index >= 1 and depth > 0 do
					local prev = cur_chain[chain_index]

					if index - prev > 32768 then
						break
					end
					if prev < index then
						local sj = string_table_index_plus_three

						if prev >= -257 then
							local pj = prev - offset_minus_three
							while (sj <= max_len_minus_one
								and string_table[pj]
								== string_table[sj]) do
								sj = sj + 1
								pj = pj + 1
							end
						else
							local pj = dict_string_len_plus3 + prev
							while (sj <= max_len_minus_one
								and dict_string_table[pj]
								== string_table[sj]) do
								sj = sj + 1
								pj = pj + 1
							end
						end
						local j = sj - string_table_index
						if j > cur_len then
							cur_len = j
							cur_dist = index - prev
						end
						if cur_len >= config_nice_length then
							break
						end
					end

					chain_index = chain_index - 1
					depth = depth - 1
					if chain_index == 0 and prev > 0 and dict_hash_tables then
						cur_chain = dict_hash_tables[hash]
						chain_index = cur_chain and #cur_chain or 0
					end
				end
			end

			if not config_use_lazy then
				prev_len, prev_dist = cur_len, cur_dist
			end
			if ((not config_use_lazy or match_available)
				and (prev_len > 3 or (prev_len == 3 and prev_dist < 4096))
				and cur_len <= prev_len )then
				local code = _length_to_deflate_code[prev_len]
				local length_extra_bits_bitlen =
					_length_to_deflate_extra_bitlen[prev_len]
				local dist_code, dist_extra_bits_bitlen, dist_extra_bits
				if prev_dist <= 256 then -- have cached code for small distance.
					dist_code = _dist256_to_deflate_code[prev_dist]
					dist_extra_bits = _dist256_to_deflate_extra_bits[prev_dist]
					dist_extra_bits_bitlen =
						_dist256_to_deflate_extra_bitlen[prev_dist]
				else
					dist_code = 16
					dist_extra_bits_bitlen = 7
					local a = 384
					local b = 512

					while true do
						if prev_dist <= a then
							dist_extra_bits = (prev_dist-(b/2)-1) % (b/4)
							break
						elseif prev_dist <= b then
							dist_extra_bits = (prev_dist-(b/2)-1) % (b/4)
							dist_code = dist_code + 1
							break
						else
							dist_code = dist_code + 2
							dist_extra_bits_bitlen = dist_extra_bits_bitlen + 1
							a = a*2
							b = b*2
						end
					end
				end
				lcode_tblsize = lcode_tblsize + 1
				lcodes[lcode_tblsize] = code
				lcodes_counts[code] = (lcodes_counts[code] or 0) + 1

				dcodes_tblsize = dcodes_tblsize + 1
				dcodes[dcodes_tblsize] = dist_code
				dcodes_counts[dist_code] = (dcodes_counts[dist_code] or 0) + 1

				if length_extra_bits_bitlen > 0 then
					local lenExtraBits = _length_to_deflate_extra_bits[prev_len]
					lextra_bits_tblsize = lextra_bits_tblsize + 1
					lextra_bits[lextra_bits_tblsize] = lenExtraBits
				end
				if dist_extra_bits_bitlen > 0 then
					dextra_bits_tblsize = dextra_bits_tblsize + 1
					dextra_bits[dextra_bits_tblsize] = dist_extra_bits
				end

				for i=index+1, index+prev_len-(config_use_lazy and 2 or 1) do
					hash = (hash*256+(string_table[i-offset+2] or 0))%16777216
					if prev_len <= config_max_insert_length then
						hash_chain = hash_tables[hash]
						if not hash_chain then
							hash_chain = {}
							hash_tables[hash] = hash_chain
						end
						hash_chain[#hash_chain+1] = i
					end
				end
				index = index + prev_len - (config_use_lazy and 1 or 0)
				match_available = false
			elseif (not config_use_lazy) or match_available then
				local code = string_table[config_use_lazy
					and (string_table_index-1) or string_table_index]
				lcode_tblsize = lcode_tblsize + 1
				lcodes[lcode_tblsize] = code
				lcodes_counts[code] = (lcodes_counts[code] or 0) + 1
				index = index + 1
			else
				match_available = true
				index = index + 1
			end
		end

		-- Write "end of block" symbol
		lcode_tblsize = lcode_tblsize + 1
		lcodes[lcode_tblsize] = 256
		lcodes_counts[256] = (lcodes_counts[256] or 0) + 1

		return lcodes, lextra_bits, lcodes_counts, dcodes, dextra_bits
		, dcodes_counts
	end

	-- Get the header data of dynamic block.
	-- @param lcodes_count The count of each literal/LZ77_length codes.
	-- @param dcodes_count The count of each Lz77 distance codes.
	-- @return a lots of stuffs.
	-- @see RFC1951 Page 12
	local function GetBlockDynamicHuffmanHeader(lcodes_counts, dcodes_counts)
		local lcodes_huffman_bitlens, lcodes_huffman_codes
		, max_non_zero_bitlen_lcode =
			GetHuffmanBitlenAndCode(lcodes_counts, 15, 285)
		local dcodes_huffman_bitlens, dcodes_huffman_codes
		, max_non_zero_bitlen_dcode =
			GetHuffmanBitlenAndCode(dcodes_counts, 15, 29)

		local rle_deflate_codes, rle_extra_bits, rle_codes_counts =
			RunLengthEncodeHuffmanBitlen(lcodes_huffman_bitlens
				,max_non_zero_bitlen_lcode, dcodes_huffman_bitlens
				, max_non_zero_bitlen_dcode)

		local rle_codes_huffman_bitlens, rle_codes_huffman_codes =
			GetHuffmanBitlenAndCode(rle_codes_counts, 7, 18)

		local HCLEN = 0
		for i = 1, 19 do
			local symbol = _rle_codes_huffman_bitlen_order[i]
			local length = rle_codes_huffman_bitlens[symbol] or 0
			if length ~= 0 then
				HCLEN = i
			end
		end

		HCLEN = HCLEN - 4
		local HLIT = max_non_zero_bitlen_lcode + 1 - 257
		local HDIST = max_non_zero_bitlen_dcode + 1 - 1
		if HDIST < 0 then HDIST = 0 end

		return HLIT, HDIST, HCLEN, rle_codes_huffman_bitlens
		, rle_codes_huffman_codes, rle_deflate_codes, rle_extra_bits
		, lcodes_huffman_bitlens, lcodes_huffman_codes
		, dcodes_huffman_bitlens, dcodes_huffman_codes
	end

	-- Get the size of dynamic block without writing any bits into the writer.
	-- @param ... Read the source code of GetBlockDynamicHuffmanHeader()
	-- @return the bit length of the dynamic block
	local function GetDynamicHuffmanBlockSize(lcodes, dcodes, HCLEN
		, rle_codes_huffman_bitlens, rle_deflate_codes
		, lcodes_huffman_bitlens, dcodes_huffman_bitlens)

		local block_bitlen = 17 -- 1+2+5+5+4
		block_bitlen = block_bitlen + (HCLEN+4)*3

		for i = 1, #rle_deflate_codes do
			local code = rle_deflate_codes[i]
			block_bitlen = block_bitlen + rle_codes_huffman_bitlens[code]
			if code >= 16 then
				block_bitlen = block_bitlen +
					((code == 16) and 2 or (code == 17 and 3 or 7))
			end
		end

		local length_code_count = 0
		for i = 1, #lcodes do
			local code = lcodes[i]
			local huffman_bitlen = lcodes_huffman_bitlens[code]
			block_bitlen = block_bitlen + huffman_bitlen
			if code > 256 then -- Length code
				length_code_count = length_code_count + 1
				if code > 264 and code < 285 then -- Length code with extra bits
					local extra_bits_bitlen =
						_literal_deflate_code_to_extra_bitlen[code-256]
					block_bitlen = block_bitlen + extra_bits_bitlen
				end
				local dist_code = dcodes[length_code_count]
				local dist_huffman_bitlen = dcodes_huffman_bitlens[dist_code]
				block_bitlen = block_bitlen + dist_huffman_bitlen

				if dist_code > 3 then -- dist code with extra bits
					local dist_extra_bits_bitlen = (dist_code-dist_code%2)/2 - 1
					block_bitlen = block_bitlen + dist_extra_bits_bitlen
				end
			end
		end
		return block_bitlen
	end

	-- Write dynamic block.
	-- @param ... Read the source code of GetBlockDynamicHuffmanHeader()
	local function CompressDynamicHuffmanBlock(WriteBits, is_last_block
		, lcodes, lextra_bits, dcodes, dextra_bits, HLIT, HDIST, HCLEN
		, rle_codes_huffman_bitlens, rle_codes_huffman_codes
		, rle_deflate_codes, rle_extra_bits
		, lcodes_huffman_bitlens, lcodes_huffman_codes
		, dcodes_huffman_bitlens, dcodes_huffman_codes)

		WriteBits(is_last_block and 1 or 0, 1) -- Last block identifier
		WriteBits(2, 2) -- Dynamic Huffman block identifier

		WriteBits(HLIT, 5)
		WriteBits(HDIST, 5)
		WriteBits(HCLEN, 4)

		for i = 1, HCLEN+4 do
			local symbol = _rle_codes_huffman_bitlen_order[i]
			local length = rle_codes_huffman_bitlens[symbol] or 0
			WriteBits(length, 3)
		end

		local rleExtraBitsIndex = 1
		for i=1, #rle_deflate_codes do
			local code = rle_deflate_codes[i]
			WriteBits(rle_codes_huffman_codes[code]
				, rle_codes_huffman_bitlens[code])
			if code >= 16 then
				local extraBits = rle_extra_bits[rleExtraBitsIndex]
				WriteBits(extraBits, (code == 16) and 2 or (code == 17 and 3 or 7))
				rleExtraBitsIndex = rleExtraBitsIndex + 1
			end
		end

		local length_code_count = 0
		local length_code_with_extra_count = 0
		local dist_code_with_extra_count = 0

		for i=1, #lcodes do
			local deflate_codee = lcodes[i]
			local huffman_code = lcodes_huffman_codes[deflate_codee]
			local huffman_bitlen = lcodes_huffman_bitlens[deflate_codee]
			WriteBits(huffman_code, huffman_bitlen)
			if deflate_codee > 256 then -- Length code
				length_code_count = length_code_count + 1
				if deflate_codee > 264 and deflate_codee < 285 then
					-- Length code with extra bits
					length_code_with_extra_count = length_code_with_extra_count + 1
					local extra_bits = lextra_bits[length_code_with_extra_count]
					local extra_bits_bitlen =
						_literal_deflate_code_to_extra_bitlen[deflate_codee-256]
					WriteBits(extra_bits, extra_bits_bitlen)
				end
				-- Write distance code
				local dist_deflate_code = dcodes[length_code_count]
				local dist_huffman_code = dcodes_huffman_codes[dist_deflate_code]
				local dist_huffman_bitlen =
					dcodes_huffman_bitlens[dist_deflate_code]
				WriteBits(dist_huffman_code, dist_huffman_bitlen)

				if dist_deflate_code > 3 then -- dist code with extra bits
					dist_code_with_extra_count = dist_code_with_extra_count + 1
					local dist_extra_bits = dextra_bits[dist_code_with_extra_count]
					local dist_extra_bits_bitlen =
						(dist_deflate_code-dist_deflate_code%2)/2 - 1
					WriteBits(dist_extra_bits, dist_extra_bits_bitlen)
				end
			end
		end
	end

	-- Get the size of fixed block without writing any bits into the writer.
	-- @param lcodes literal/LZ77_length deflate codes
	-- @param decodes LZ77 distance deflate codes
	-- @return the bit length of the fixed block
	local function GetFixedHuffmanBlockSize(lcodes, dcodes)
		local block_bitlen = 3
		local length_code_count = 0
		for i=1, #lcodes do
			local code = lcodes[i]
			local huffman_bitlen = _fix_block_literal_huffman_bitlen[code]
			block_bitlen = block_bitlen + huffman_bitlen
			if code > 256 then -- Length code
				length_code_count = length_code_count + 1
				if code > 264 and code < 285 then -- Length code with extra bits
					local extra_bits_bitlen =
						_literal_deflate_code_to_extra_bitlen[code-256]
					block_bitlen = block_bitlen + extra_bits_bitlen
				end
				local dist_code = dcodes[length_code_count]
				block_bitlen = block_bitlen + 5

				if dist_code > 3 then -- dist code with extra bits
					local dist_extra_bits_bitlen =
						(dist_code-dist_code%2)/2 - 1
					block_bitlen = block_bitlen + dist_extra_bits_bitlen
				end
			end
		end
		return block_bitlen
	end

	-- Write fixed block.
	-- @param lcodes literal/LZ77_length deflate codes
	-- @param decodes LZ77 distance deflate codes
	local function CompressFixedHuffmanBlock(WriteBits, is_last_block,
		lcodes, lextra_bits, dcodes, dextra_bits)
		WriteBits(is_last_block and 1 or 0, 1) -- Last block identifier
		WriteBits(1, 2) -- Fixed Huffman block identifier
		local length_code_count = 0
		local length_code_with_extra_count = 0
		local dist_code_with_extra_count = 0
		for i=1, #lcodes do
			local deflate_code = lcodes[i]
			local huffman_code = _fix_block_literal_huffman_code[deflate_code]
			local huffman_bitlen = _fix_block_literal_huffman_bitlen[deflate_code]
			WriteBits(huffman_code, huffman_bitlen)
			if deflate_code > 256 then -- Length code
				length_code_count = length_code_count + 1
				if deflate_code > 264 and deflate_code < 285 then
					-- Length code with extra bits
					length_code_with_extra_count = length_code_with_extra_count + 1
					local extra_bits = lextra_bits[length_code_with_extra_count]
					local extra_bits_bitlen =
						_literal_deflate_code_to_extra_bitlen[deflate_code-256]
					WriteBits(extra_bits, extra_bits_bitlen)
				end
				-- Write distance code
				local dist_code = dcodes[length_code_count]
				local dist_huffman_code = _fix_block_dist_huffman_code[dist_code]
				WriteBits(dist_huffman_code, 5)

				if dist_code > 3 then -- dist code with extra bits
					dist_code_with_extra_count = dist_code_with_extra_count + 1
					local dist_extra_bits = dextra_bits[dist_code_with_extra_count]
					local dist_extra_bits_bitlen = (dist_code-dist_code%2)/2 - 1
					WriteBits(dist_extra_bits, dist_extra_bits_bitlen)
				end
			end
		end
	end

	-- Get the size of store block without writing any bits into the writer.
	-- @param block_start The start index of the origin input string
	-- @param block_end The end index of the origin input string
	-- @param Total bit lens had been written into the compressed result before,
	-- because store block needs to shift to byte boundary.
	-- @return the bit length of the fixed block
	local function GetStoreBlockSize(block_start, block_end, total_bitlen)
		assert(block_end-block_start+1 <= 65535)
		local block_bitlen = 3
		total_bitlen = total_bitlen + 3
		local padding_bitlen = (8-total_bitlen%8)%8
		block_bitlen = block_bitlen + padding_bitlen
		block_bitlen = block_bitlen + 32
		block_bitlen = block_bitlen + (block_end - block_start + 1) * 8
		return block_bitlen
	end

	-- Write the store block.
	-- @param ... lots of stuffs
	-- @return nil
	local function CompressStoreBlock(WriteBits, WriteString, is_last_block, str
		, block_start, block_end, total_bitlen)
		assert(block_end-block_start+1 <= 65535)
		WriteBits(is_last_block and 1 or 0, 1) -- Last block identifer.
		WriteBits(0, 2) -- Store block identifier.
		total_bitlen = total_bitlen + 3
		local padding_bitlen = (8-total_bitlen%8)%8
		if padding_bitlen > 0 then
			WriteBits(_pow2[padding_bitlen]-1, padding_bitlen)
		end
		local size = block_end - block_start + 1
		WriteBits(size, 16)

		-- Write size's one's complement
		local comp = (255 - size % 256) + (255 - (size-size%256)/256)*256
		WriteBits(comp, 16)

		WriteString(str:sub(block_start, block_end))
	end

	-- Do the deflate
	-- Currently using a simple way to determine the block size
	-- (This is why the compression ratio is little bit worse than zlib when
	-- the input size is very large
	-- The first block is 64KB, the following block is 32KB.
	-- After each block, there is a memory cleanup operation.
	-- This is not a fast operation, but it is needed to save memory usage, so
	-- the memory usage does not grow unboundly. If the data size is less than
	-- 64KB, then memory cleanup won't happen.
	-- This function determines whether to use store/fixed/dynamic blocks by
	-- calculating the block size of each block type and chooses the smallest one.
	local function Deflate(configs, WriteBits, WriteString, FlushWriter, str
		, dictionary)
		local string_table = {}
		local hash_tables = {}
		local is_last_block = nil
		local block_start
		local block_end
		local bitlen_written
		local total_bitlen = FlushWriter(_FLUSH_MODE_NO_FLUSH)
		local strlen = #str
		local offset

		local level
		local strategy
		if configs then
			if configs.level then
				level = configs.level
			end
			if configs.strategy then
				strategy = configs.strategy
			end
		end

		if not level then
			if strlen < 2048 then
				level = 7
			elseif strlen > 65536 then
				level = 3
			else
				level = 5
			end
		end

		while not is_last_block do
			if not block_start then
				block_start = 1
				block_end = 64*1024 - 1
				offset = 0
			else
				block_start = block_end + 1
				block_end = block_end + 32*1024
				offset = block_start - 32*1024 - 1
			end

			if block_end >= strlen then
				block_end = strlen
				is_last_block = true
			else
				is_last_block = false
			end

			local lcodes, lextra_bits, lcodes_counts, dcodes, dextra_bits
			, dcodes_counts

			local HLIT, HDIST, HCLEN, rle_codes_huffman_bitlens
			, rle_codes_huffman_codes, rle_deflate_codes
			, rle_extra_bits, lcodes_huffman_bitlens, lcodes_huffman_codes
			, dcodes_huffman_bitlens, dcodes_huffman_codes

			local dynamic_block_bitlen
			local fixed_block_bitlen
			local store_block_bitlen

			if level ~= 0 then

				-- GetBlockLZ77 needs block_start to block_end+3 to be loaded.
				LoadStringToTable(str, string_table, block_start, block_end + 3
					, offset)
				if block_start == 1 and dictionary then
					local dict_string_table = dictionary.string_table
					local dict_strlen = dictionary.strlen
					for i=0, (-dict_strlen+1)<-257
						and -257 or (-dict_strlen+1), -1 do
						string_table[i] = dict_string_table[dict_strlen+i]
					end
				end

				if strategy == "huffman_only" then
					lcodes = {}
					LoadStringToTable(str, lcodes, block_start, block_end
						, block_start-1)
					lextra_bits = {}
					lcodes_counts = {}
					lcodes[block_end - block_start+2] = 256 -- end of block
					for i=1, block_end - block_start+2 do
						local code = lcodes[i]
						lcodes_counts[code] = (lcodes_counts[code] or 0) + 1
					end
					dcodes = {}
					dextra_bits = {}
					dcodes_counts = {}
				else
					lcodes, lextra_bits, lcodes_counts, dcodes, dextra_bits
					, dcodes_counts = GetBlockLZ77Result(level, string_table
						, hash_tables, block_start, block_end, offset, dictionary
					)
				end

				HLIT, HDIST, HCLEN, rle_codes_huffman_bitlens
				, rle_codes_huffman_codes, rle_deflate_codes
				, rle_extra_bits, lcodes_huffman_bitlens, lcodes_huffman_codes
				, dcodes_huffman_bitlens, dcodes_huffman_codes =
					GetBlockDynamicHuffmanHeader(lcodes_counts, dcodes_counts)
				dynamic_block_bitlen = GetDynamicHuffmanBlockSize(
					lcodes, dcodes, HCLEN, rle_codes_huffman_bitlens
					, rle_deflate_codes, lcodes_huffman_bitlens
					, dcodes_huffman_bitlens)
				fixed_block_bitlen = GetFixedHuffmanBlockSize(lcodes, dcodes)
			end

			store_block_bitlen = GetStoreBlockSize(block_start, block_end
				, total_bitlen)

			local min_bitlen = store_block_bitlen
			min_bitlen = (fixed_block_bitlen and fixed_block_bitlen < min_bitlen)
				and fixed_block_bitlen or min_bitlen
			min_bitlen = (dynamic_block_bitlen
				and dynamic_block_bitlen < min_bitlen)
				and dynamic_block_bitlen or min_bitlen

			if level == 0 or (strategy ~= "fixed" and strategy ~= "dynamic" and
				store_block_bitlen == min_bitlen) then
				CompressStoreBlock(WriteBits, WriteString, is_last_block
					, str, block_start, block_end, total_bitlen)
				total_bitlen = total_bitlen + store_block_bitlen
			elseif strategy ~= "dynamic" and (
				strategy == "fixed" or fixed_block_bitlen == min_bitlen) then
				CompressFixedHuffmanBlock(WriteBits, is_last_block,
					lcodes, lextra_bits, dcodes, dextra_bits)
				total_bitlen = total_bitlen + fixed_block_bitlen
			elseif strategy == "dynamic" or dynamic_block_bitlen == min_bitlen then
				CompressDynamicHuffmanBlock(WriteBits, is_last_block, lcodes
					, lextra_bits, dcodes, dextra_bits, HLIT, HDIST, HCLEN
					, rle_codes_huffman_bitlens, rle_codes_huffman_codes
					, rle_deflate_codes, rle_extra_bits
					, lcodes_huffman_bitlens, lcodes_huffman_codes
					, dcodes_huffman_bitlens, dcodes_huffman_codes)
				total_bitlen = total_bitlen + dynamic_block_bitlen
			end

			if is_last_block then
				bitlen_written = FlushWriter(_FLUSH_MODE_NO_FLUSH)
			else
				bitlen_written = FlushWriter(_FLUSH_MODE_MEMORY_CLEANUP)
			end

			assert(bitlen_written == total_bitlen)

			-- Memory clean up, so memory consumption does not always grow linearly
			-- , even if input string is > 64K.
			-- Not a very efficient operation, but this operation won't happen
			-- when the input data size is less than 64K.
			if not is_last_block then
				local j
				if dictionary and block_start == 1 then
					j = 0
					while (string_table[j]) do
						string_table[j] = nil
						j = j - 1
					end
				end
				dictionary = nil
				j = 1
				for i = block_end-32767, block_end do
					string_table[j] = string_table[i-offset]
					j = j + 1
				end

				for k, t in pairs(hash_tables) do
					local tSize = #t
					if tSize > 0 and block_end+1 - t[1] > 32768 then
						if tSize == 1 then
							hash_tables[k] = nil
						else
							local new = {}
							local newSize = 0
							for i = 2, tSize do
								j = t[i]
								if block_end+1 - j <= 32768 then
									newSize = newSize + 1
									new[newSize] = j
								end
							end
							hash_tables[k] = new
						end
					end
				end
			end
		end
	end

	--- The description to compression configuration table. <br>
	-- Any field can be nil to use its default. <br>
	-- Table with keys other than those below is an invalid table.
	-- @class table
	-- @name compression_configs
	-- @field level The compression level ranged from 0 to 9. 0 is no compression.
	-- 9 is the slowest but best compression. Use nil for default level.
	-- @field strategy The compression strategy. "fixed" to only use fixed deflate
	-- compression block. "dynamic" to only use dynamic block. "huffman_only" to
	-- do no LZ77 compression. Only do huffman compression.


	-- @see LibDeflate:CompressDeflate(str, configs)
	-- @see LibDeflate:CompressDeflateWithDict(str, dictionary, configs)
	local function CompressDeflateInternal(str, dictionary, configs)
		local WriteBits, WriteString, FlushWriter = CreateWriter()
		Deflate(configs, WriteBits, WriteString, FlushWriter, str, dictionary)
		local total_bitlen, result = FlushWriter(_FLUSH_MODE_OUTPUT)
		local padding_bitlen = (8-total_bitlen%8)%8
		return result, padding_bitlen
	end

	-- @see LibDeflate:CompressZlib
	-- @see LibDeflate:CompressZlibWithDict
	local function CompressZlibInternal(str, dictionary, configs)
		local WriteBits, WriteString, FlushWriter = CreateWriter()

		local CM = 8 -- Compression method
		local CINFO = 7 --Window Size = 32K
		local CMF = CINFO*16+CM
		WriteBits(CMF, 8)

		local FDIST = dictionary and 1 or 0
		local FLEVEL = 2 -- Default compression
		local FLG = FLEVEL*64+FDIST*32
		local FCHECK = (31-(CMF*256+FLG)%31)
		-- The FCHECK value must be such that CMF and FLG,
		-- when viewed as a 16-bit unsigned integer stored
		-- in MSB order (CMF*256 + FLG), is a multiple of 31.
		FLG = FLG + FCHECK
		WriteBits(FLG, 8)

		if FDIST == 1 then
			local adler32 = dictionary.adler32
			local byte0 = adler32 % 256
			adler32 = (adler32 - byte0) / 256
			local byte1 = adler32 % 256
			adler32 = (adler32 - byte1) / 256
			local byte2 = adler32 % 256
			adler32 = (adler32 - byte2) / 256
			local byte3 = adler32 % 256
			WriteBits(byte3, 8)
			WriteBits(byte2, 8)
			WriteBits(byte1, 8)
			WriteBits(byte0, 8)
		end

		Deflate(configs, WriteBits, WriteString, FlushWriter, str, dictionary)
		FlushWriter(_FLUSH_MODE_BYTE_BOUNDARY)

		local adler32 = LibDeflate:Adler32(str)

		-- Most significant byte first
		local byte3 = adler32%256
		adler32 = (adler32 - byte3) / 256
		local byte2 = adler32%256
		adler32 = (adler32 - byte2) / 256
		local byte1 = adler32%256
		adler32 = (adler32 - byte1) / 256
		local byte0 = adler32%256

		WriteBits(byte0, 8)
		WriteBits(byte1, 8)
		WriteBits(byte2, 8)
		WriteBits(byte3, 8)
		local total_bitlen, result = FlushWriter(_FLUSH_MODE_OUTPUT)
		local padding_bitlen = (8-total_bitlen%8)%8
		return result, padding_bitlen
	end

	--- Compress using the raw deflate format.
	-- @param str [string] The data to be compressed.
	-- @param configs [table/nil] The configuration table to control the compression
	-- . If nil, use the default configuration.
	-- @return [string] The compressed data.
	-- @return [integer] The number of bits padded at the end of output.
	-- 0 <= bits < 8  <br>
	-- This means the most significant "bits" of the last byte of the returned
	-- compressed data are padding bits and they don't affect decompression.
	-- You don't need to use this value unless you want to do some postprocessing
	-- to the compressed data.
	-- @see compression_configs
	-- @see LibDeflate:DecompressDeflate
	function LibDeflate:CompressDeflate(str, configs)
		local arg_valid, arg_err = IsValidArguments(str, false, nil, true, configs)
		if not arg_valid then
			error(("Usage: LibDeflate:CompressDeflate(str, configs): "
				..arg_err), 2)
		end
		return CompressDeflateInternal(str, nil, configs)
	end

	--- Compress using the raw deflate format with a preset dictionary.
	-- @param str [string] The data to be compressed.
	-- @param dictionary [table] The preset dictionary produced by
	-- LibDeflate:CreateDictionary
	-- @param configs [table/nil] The configuration table to control the compression
	-- . If nil, use the default configuration.
	-- @return [string] The compressed data.
	-- @return [integer] The number of bits padded at the end of output.
	-- 0 <= bits < 8  <br>
	-- This means the most significant "bits" of the last byte of the returned
	-- compressed data are padding bits and they don't affect decompression.
	-- You don't need to use this value unless you want to do some postprocessing
	-- to the compressed data.
	-- @see compression_configs
	-- @see LibDeflate:CreateDictionary
	-- @see LibDeflate:DecompressDeflateWithDict
	function LibDeflate:CompressDeflateWithDict(str, dictionary, configs)
		local arg_valid, arg_err = IsValidArguments(str, true, dictionary
			, true, configs)
		if not arg_valid then
			error(("Usage: LibDeflate:CompressDeflateWithDict"
				.."(str, dictionary, configs): "
				..arg_err), 2)
		end
		return CompressDeflateInternal(str, dictionary, configs)
	end

	--- Compress using the zlib format.
	-- @param str [string] the data to be compressed.
	-- @param configs [table/nil] The configuration table to control the compression
	-- . If nil, use the default configuration.
	-- @return [string] The compressed data.
	-- @return [integer] The number of bits padded at the end of output.
	-- Should always be 0.
	-- Zlib formatted compressed data never has padding bits at the end.
	-- @see compression_configs
	-- @see LibDeflate:DecompressZlib
	function LibDeflate:CompressZlib(str, configs)
		local arg_valid, arg_err = IsValidArguments(str, false, nil, true, configs)
		if not arg_valid then
			error(("Usage: LibDeflate:CompressZlib(str, configs): "
				..arg_err), 2)
		end
		return CompressZlibInternal(str, nil, configs)
	end

	--- Compress using the zlib format with a preset dictionary.
	-- @param str [string] the data to be compressed.
	-- @param dictionary [table] A preset dictionary produced
	-- by LibDeflate:CreateDictionary()
	-- @param configs [table/nil] The configuration table to control the compression
	-- . If nil, use the default configuration.
	-- @return [string] The compressed data.
	-- @return [integer] The number of bits padded at the end of output.
	-- Should always be 0.
	-- Zlib formatted compressed data never has padding bits at the end.
	-- @see compression_configs
	-- @see LibDeflate:CreateDictionary
	-- @see LibDeflate:DecompressZlibWithDict
	function LibDeflate:CompressZlibWithDict(str, dictionary, configs)
		local arg_valid, arg_err = IsValidArguments(str, true, dictionary
			, true, configs)
		if not arg_valid then
			error(("Usage: LibDeflate:CompressZlibWithDict"
				.."(str, dictionary, configs): "
				..arg_err), 2)
		end
		return CompressZlibInternal(str, dictionary, configs)
	end

--[[ --------------------------------------------------------------------------
	Decompress code
--]] --------------------------------------------------------------------------

--[[
	Create a reader to easily reader stuffs as the unit of bits.
	Return values:
	1. ReadBits(bitlen)
	2. ReadBytes(bytelen, buffer, buffer_size)
	3. Decode(huffman_bitlen_count, huffman_symbol, min_bitlen)
	4. ReaderBitlenLeft()
	5. SkipToByteBoundary()
--]]
	local function CreateReader(input_string)
		local input = input_string
		local input_strlen = #input_string
		local input_next_byte_pos = 1
		local cache_bitlen = 0
		local cache = 0

		-- Read some bits.
		-- To improve speed, this function does not
		-- check if the input has been exhausted.
		-- Use ReaderBitlenLeft() < 0 to check it.
		-- @param bitlen the number of bits to read
		-- @return the data is read.
		local function ReadBits(bitlen)
			local rshift_mask = _pow2[bitlen]
			local code
			if bitlen <= cache_bitlen then
				code = cache % rshift_mask
				cache = (cache - code) / rshift_mask
				cache_bitlen = cache_bitlen - bitlen
			else -- Whether input has been exhausted is not checked.
				local lshift_mask = _pow2[cache_bitlen]
				local byte1, byte2, byte3, byte4 = string_byte(input
					, input_next_byte_pos, input_next_byte_pos+3)
				-- This requires lua number to be at least double ()
				cache = cache + ((byte1 or 0)+(byte2 or 0)*256
					+ (byte3 or 0)*65536+(byte4 or 0)*16777216)*lshift_mask
				input_next_byte_pos = input_next_byte_pos + 4
				cache_bitlen = cache_bitlen + 32 - bitlen
				code = cache % rshift_mask
				cache = (cache - code) / rshift_mask
			end
			return code
		end

		-- Read some bytes from the reader.
		-- Assume reader is on the byte boundary.
		-- @param bytelen The number of bytes to be read.
		-- @param buffer The byte read will be stored into this buffer.
		-- @param buffer_size The buffer will be modified starting from
		--	buffer[buffer_size+1], ending at buffer[buffer_size+bytelen-1]
		-- @return the new buffer_size
		local function ReadBytes(bytelen, buffer, buffer_size)
			assert(cache_bitlen % 8 == 0)

			local byte_from_cache = (cache_bitlen/8 < bytelen)
				and (cache_bitlen/8) or bytelen
			for _=1, byte_from_cache do
				local byte = cache % 256
				buffer_size = buffer_size + 1
				buffer[buffer_size] = string_char(byte)
				cache = (cache - byte) / 256
			end
			cache_bitlen = cache_bitlen - byte_from_cache*8
			bytelen = bytelen - byte_from_cache
			if (input_strlen - input_next_byte_pos - bytelen + 1) * 8
				+ cache_bitlen < 0 then
				return -1 -- out of input
			end
			for i=input_next_byte_pos, input_next_byte_pos+bytelen-1 do
				buffer_size = buffer_size + 1
				buffer[buffer_size] = string_sub(input, i, i)
			end

			input_next_byte_pos = input_next_byte_pos + bytelen
			return buffer_size
		end

		-- Decode huffman code
		-- To improve speed, this function does not check
		-- if the input has been exhausted.
		-- Use ReaderBitlenLeft() < 0 to check it.
		-- Credits for Mark Adler. This code is from puff:Decode()
		-- @see puff:Decode(...)
		-- @param huffman_bitlen_count
		-- @param huffman_symbol
		-- @param min_bitlen The minimum huffman bit length of all symbols
		-- @return The decoded deflate code.
		--	Negative value is returned if decoding fails.
		local function Decode(huffman_bitlen_counts, huffman_symbols, min_bitlen)
			local code = 0
			local first = 0
			local index = 0
			local count
			if min_bitlen > 0 then
				if cache_bitlen < 15 and input then
					local lshift_mask = _pow2[cache_bitlen]
					local byte1, byte2, byte3, byte4 =
						string_byte(input, input_next_byte_pos
							, input_next_byte_pos+3)
					-- This requires lua number to be at least double ()
					cache = cache + ((byte1 or 0)+(byte2 or 0)*256
						+(byte3 or 0)*65536+(byte4 or 0)*16777216)*lshift_mask
					input_next_byte_pos = input_next_byte_pos + 4
					cache_bitlen = cache_bitlen + 32
				end

				local rshift_mask = _pow2[min_bitlen]
				cache_bitlen = cache_bitlen - min_bitlen
				code = cache % rshift_mask
				cache = (cache - code) / rshift_mask
				-- Reverse the bits
				code = _reverse_bits_tbl[min_bitlen][code]

				count = huffman_bitlen_counts[min_bitlen]
				if code < count then
					return huffman_symbols[code]
				end
				index = count
				first = count * 2
				code = code * 2
			end

			for bitlen = min_bitlen+1, 15 do
				local bit
				bit = cache % 2
				cache = (cache - bit) / 2
				cache_bitlen = cache_bitlen - 1

				code = (bit==1) and (code + 1 - code % 2) or code
				count = huffman_bitlen_counts[bitlen] or 0
				local diff = code - first
				if diff < count then
					return huffman_symbols[index + diff]
				end
				index = index + count
				first = first + count
				first = first * 2
				code = code * 2
			end
			-- invalid literal/length or distance code
			-- in fixed or dynamic block (run out of code)
			return -10
		end

		local function ReaderBitlenLeft()
			return (input_strlen - input_next_byte_pos + 1) * 8 + cache_bitlen
		end

		local function SkipToByteBoundary()
			local skipped_bitlen = cache_bitlen%8
			local rshift_mask = _pow2[skipped_bitlen]
			cache_bitlen = cache_bitlen - skipped_bitlen
			cache = (cache - cache % rshift_mask) / rshift_mask
		end

		return ReadBits, ReadBytes, Decode, ReaderBitlenLeft, SkipToByteBoundary
	end

	-- Create a deflate state, so I can pass in less arguments to functions.
	-- @param str the whole string to be decompressed.
	-- @param dictionary The preset dictionary. nil if not provided.
	--		This dictionary should be produced by LibDeflate:CreateDictionary(str)
	-- @return The decomrpess state.
	local function CreateDecompressState(str, dictionary)
		local ReadBits, ReadBytes, Decode, ReaderBitlenLeft
		, SkipToByteBoundary = CreateReader(str)
		local state =
			{
				ReadBits = ReadBits,
				ReadBytes = ReadBytes,
				Decode = Decode,
				ReaderBitlenLeft = ReaderBitlenLeft,
				SkipToByteBoundary = SkipToByteBoundary,
				buffer_size = 0,
				buffer = {},
				result_buffer = {},
				dictionary = dictionary,
			}
		return state
	end

	-- Get the stuffs needed to decode huffman codes
	-- @see puff.c:construct(...)
	-- @param huffman_bitlen The huffman bit length of the huffman codes.
	-- @param max_symbol The maximum symbol
	-- @param max_bitlen The min huffman bit length of all codes
	-- @return zero or positive for success, negative for failure.
	-- @return The count of each huffman bit length.
	-- @return A table to convert huffman codes to deflate codes.
	-- @return The minimum huffman bit length.
	local function GetHuffmanForDecode(huffman_bitlens, max_symbol, max_bitlen)
		local huffman_bitlen_counts = {}
		local min_bitlen = max_bitlen
		for symbol = 0, max_symbol do
			local bitlen = huffman_bitlens[symbol] or 0
			min_bitlen = (bitlen > 0 and bitlen < min_bitlen)
				and bitlen or min_bitlen
			huffman_bitlen_counts[bitlen] = (huffman_bitlen_counts[bitlen] or 0)+1
		end

		if huffman_bitlen_counts[0] == max_symbol+1 then -- No Codes
			return 0, huffman_bitlen_counts, {}, 0 -- Complete, but decode will fail
		end

		local left = 1
		for len = 1, max_bitlen do
			left = left * 2
			left = left - (huffman_bitlen_counts[len] or 0)
			if left < 0 then
				return left -- Over-subscribed, return negative
			end
		end

		-- Generate offsets info symbol table for each length for sorting
		local offsets = {}
		offsets[1] = 0
		for len = 1, max_bitlen-1 do
			offsets[len + 1] = offsets[len] + (huffman_bitlen_counts[len] or 0)
		end

		local huffman_symbols = {}
		for symbol = 0, max_symbol do
			local bitlen = huffman_bitlens[symbol] or 0
			if bitlen ~= 0 then
				local offset = offsets[bitlen]
				huffman_symbols[offset] = symbol
				offsets[bitlen] = offsets[bitlen] + 1
			end
		end

		-- Return zero for complete set, positive for incomplete set.
		return left, huffman_bitlen_counts, huffman_symbols, min_bitlen
	end

	-- Decode a fixed or dynamic huffman blocks, excluding last block identifier
	-- and block type identifer.
	-- @see puff.c:codes()
	-- @param state decompression state that will be modified by this function.
	--	@see CreateDecompressState
	-- @param ... Read the source code
	-- @return 0 on success, other value on failure.
	local function DecodeUntilEndOfBlock(state, lcodes_huffman_bitlens
		, lcodes_huffman_symbols, lcodes_huffman_min_bitlen
		, dcodes_huffman_bitlens, dcodes_huffman_symbols
		, dcodes_huffman_min_bitlen)
		local buffer, buffer_size, ReadBits, Decode, ReaderBitlenLeft
		, result_buffer =
			state.buffer, state.buffer_size, state.ReadBits, state.Decode
		, state.ReaderBitlenLeft, state.result_buffer
		local dictionary = state.dictionary
		local dict_string_table
		local dict_strlen

		local buffer_end = 1
		if dictionary and not buffer[0] then
			-- If there is a dictionary, copy the last 258 bytes into
			-- the string_table to make the copy in the main loop quicker.
			-- This is done only once per decompression.
			dict_string_table = dictionary.string_table
			dict_strlen = dictionary.strlen
			buffer_end = -dict_strlen + 1
			for i=0, (-dict_strlen+1)<-257 and -257 or (-dict_strlen+1), -1 do
				buffer[i] = _byte_to_char[dict_string_table[dict_strlen+i]]
			end
		end

		repeat
			local symbol = Decode(lcodes_huffman_bitlens
				, lcodes_huffman_symbols, lcodes_huffman_min_bitlen)
			if symbol < 0 or symbol > 285 then
				-- invalid literal/length or distance code in fixed or dynamic block
				return -10
			elseif symbol < 256 then -- Literal
				buffer_size = buffer_size + 1
				buffer[buffer_size] = _byte_to_char[symbol]
			elseif symbol > 256 then -- Length code
				symbol = symbol - 256
				local bitlen = _literal_deflate_code_to_base_len[symbol]
				bitlen = (symbol >= 8)
					and (bitlen
						+ ReadBits(_literal_deflate_code_to_extra_bitlen[symbol]))
					or bitlen
				symbol = Decode(dcodes_huffman_bitlens, dcodes_huffman_symbols
					, dcodes_huffman_min_bitlen)
				if symbol < 0 or symbol > 29 then
					-- invalid literal/length or distance code in fixed or dynamic block
					return -10
				end
				local dist = _dist_deflate_code_to_base_dist[symbol]
				dist = (dist > 4) and (dist
					+ ReadBits(_dist_deflate_code_to_extra_bitlen[symbol])) or dist

				local char_buffer_index = buffer_size-dist+1
				if char_buffer_index < buffer_end then
					-- distance is too far back in fixed or dynamic block
					return -11
				end
				if char_buffer_index >= -257 then
					for _=1, bitlen do
						buffer_size = buffer_size + 1
						buffer[buffer_size] = buffer[char_buffer_index]
						char_buffer_index = char_buffer_index + 1
					end
				else
					char_buffer_index = dict_strlen + char_buffer_index
					for _=1, bitlen do
						buffer_size = buffer_size + 1
						buffer[buffer_size] =
							_byte_to_char[dict_string_table[char_buffer_index]]
						char_buffer_index = char_buffer_index + 1
					end
				end
			end

			if ReaderBitlenLeft() < 0 then
				return 2 -- available inflate data did not terminate
			end

			if buffer_size >= 65536 then
				result_buffer[#result_buffer+1] =
					table_concat(buffer, "", 1, 32768)
				for i=32769, buffer_size do
					buffer[i-32768] = buffer[i]
				end
				buffer_size = buffer_size - 32768
				buffer[buffer_size+1] = nil
				-- NOTE: buffer[32769..end] and buffer[-257..0] are not cleared.
				-- This is why "buffer_size" variable is needed.
			end
		until symbol == 256

		state.buffer_size = buffer_size

		return 0
	end

	-- Decompress a store block
	-- @param state decompression state that will be modified by this function.
	-- @return 0 if succeeds, other value if fails.
	local function DecompressStoreBlock(state)
		local buffer, buffer_size, ReadBits, ReadBytes, ReaderBitlenLeft
		, SkipToByteBoundary, result_buffer =
			state.buffer, state.buffer_size, state.ReadBits, state.ReadBytes
		, state.ReaderBitlenLeft, state.SkipToByteBoundary, state.result_buffer

		SkipToByteBoundary()
		local bytelen = ReadBits(16)
		if ReaderBitlenLeft() < 0 then
			return 2 -- available inflate data did not terminate
		end
		local bytelenComp = ReadBits(16)
		if ReaderBitlenLeft() < 0 then
			return 2 -- available inflate data did not terminate
		end

		if bytelen % 256 + bytelenComp % 256 ~= 255 then
			return -2 -- Not one's complement
		end
		if (bytelen-bytelen % 256)/256
			+ (bytelenComp-bytelenComp % 256)/256 ~= 255 then
			return -2 -- Not one's complement
		end

		-- Note that ReadBytes will skip to the next byte boundary first.
		buffer_size = ReadBytes(bytelen, buffer, buffer_size)
		if buffer_size < 0 then
			return 2 -- available inflate data did not terminate
		end

		-- memory clean up when there are enough bytes in the buffer.
		if buffer_size >= 65536 then
			result_buffer[#result_buffer+1] = table_concat(buffer, "", 1, 32768)
			for i=32769, buffer_size do
				buffer[i-32768] = buffer[i]
			end
			buffer_size = buffer_size - 32768
			buffer[buffer_size+1] = nil
		end
		state.buffer_size = buffer_size
		return 0
	end

	-- Decompress a fixed block
	-- @param state decompression state that will be modified by this function.
	-- @return 0 if succeeds other value if fails.
	local function DecompressFixBlock(state)
		return DecodeUntilEndOfBlock(state
			, _fix_block_literal_huffman_bitlen_count
			, _fix_block_literal_huffman_to_deflate_code, 7
			, _fix_block_dist_huffman_bitlen_count
			, _fix_block_dist_huffman_to_deflate_code, 5)
	end

	-- Decompress a dynamic block
	-- @param state decompression state that will be modified by this function.
	-- @return 0 if success, other value if fails.
	local function DecompressDynamicBlock(state)
		local ReadBits, Decode = state.ReadBits, state.Decode
		local nlen = ReadBits(5) + 257
		local ndist = ReadBits(5) + 1
		local ncode = ReadBits(4) + 4
		if nlen > 286 or ndist > 30 then
			-- dynamic block code description: too many length or distance codes
			return -3
		end

		local rle_codes_huffman_bitlens = {}

		for i = 1, ncode do
			rle_codes_huffman_bitlens[_rle_codes_huffman_bitlen_order[i]] =
				ReadBits(3)
		end

		local rle_codes_err, rle_codes_huffman_bitlen_counts,
		rle_codes_huffman_symbols, rle_codes_huffman_min_bitlen =
			GetHuffmanForDecode(rle_codes_huffman_bitlens, 18, 7)
		if rle_codes_err ~= 0 then -- Require complete code set here
			-- dynamic block code description: code lengths codes incomplete
			return -4
		end

		local lcodes_huffman_bitlens = {}
		local dcodes_huffman_bitlens = {}
		-- Read length/literal and distance code length tables
		local index = 0
		while index < nlen + ndist do
			local symbol -- Decoded value
			local bitlen -- Last length to repeat

			symbol = Decode(rle_codes_huffman_bitlen_counts
				, rle_codes_huffman_symbols, rle_codes_huffman_min_bitlen)

			if symbol < 0 then
				return symbol -- Invalid symbol
			elseif symbol < 16 then
				if index < nlen then
					lcodes_huffman_bitlens[index] = symbol
				else
					dcodes_huffman_bitlens[index-nlen] = symbol
				end
				index = index + 1
			else
				bitlen = 0
				if symbol == 16 then
					if index == 0 then
						-- dynamic block code description: repeat lengths
						-- with no first length
						return -5
					end
					if index-1 < nlen then
						bitlen = lcodes_huffman_bitlens[index-1]
					else
						bitlen = dcodes_huffman_bitlens[index-nlen-1]
					end
					symbol = 3 + ReadBits(2)
				elseif symbol == 17 then -- Repeat zero 3..10 times
					symbol = 3 + ReadBits(3)
				else -- == 18, repeat zero 11.138 times
					symbol = 11 + ReadBits(7)
				end
				if index + symbol > nlen + ndist then
					-- dynamic block code description:
					-- repeat more than specified lengths
					return -6
				end
				while symbol > 0 do -- Repeat last or zero symbol times
					symbol = symbol - 1
					if index < nlen then
						lcodes_huffman_bitlens[index] = bitlen
					else
						dcodes_huffman_bitlens[index-nlen] = bitlen
					end
					index = index + 1
				end
			end
		end

		if (lcodes_huffman_bitlens[256] or 0) == 0 then
			-- dynamic block code description: missing end-of-block code
			return -9
		end

		local lcodes_err, lcodes_huffman_bitlen_counts
		, lcodes_huffman_symbols, lcodes_huffman_min_bitlen =
			GetHuffmanForDecode(lcodes_huffman_bitlens, nlen-1, 15)
		--dynamic block code description: invalid literal/length code lengths,
		-- Incomplete code ok only for single length 1 code
		if (lcodes_err ~=0 and (lcodes_err < 0
			or nlen ~= (lcodes_huffman_bitlen_counts[0] or 0)
			+(lcodes_huffman_bitlen_counts[1] or 0))) then
			return -7
		end

		local dcodes_err, dcodes_huffman_bitlen_counts
		, dcodes_huffman_symbols, dcodes_huffman_min_bitlen =
			GetHuffmanForDecode(dcodes_huffman_bitlens, ndist-1, 15)
		-- dynamic block code description: invalid distance code lengths,
		-- Incomplete code ok only for single length 1 code
		if (dcodes_err ~=0 and (dcodes_err < 0
			or ndist ~= (dcodes_huffman_bitlen_counts[0] or 0)
			+ (dcodes_huffman_bitlen_counts[1] or 0))) then
			return -8
		end

		-- Build buffman table for literal/length codes
		return DecodeUntilEndOfBlock(state, lcodes_huffman_bitlen_counts
			, lcodes_huffman_symbols, lcodes_huffman_min_bitlen
			, dcodes_huffman_bitlen_counts, dcodes_huffman_symbols
			, dcodes_huffman_min_bitlen)
	end

	-- Decompress a deflate stream
	-- @param state: a decompression state
	-- @return the decompressed string if succeeds. nil if fails.
	local function Inflate(state)
		local ReadBits = state.ReadBits

		local is_last_block
		while not is_last_block do
			is_last_block = (ReadBits(1) == 1)
			local block_type = ReadBits(2)
			local status
			if block_type == 0 then
				status = DecompressStoreBlock(state)
			elseif block_type == 1 then
				status = DecompressFixBlock(state)
			elseif block_type == 2 then
				status = DecompressDynamicBlock(state)
			else
				return nil, -1 -- invalid block type (type == 3)
			end
			if status ~= 0 then
				return nil, status
			end
		end

		state.result_buffer[#state.result_buffer+1] =
			table_concat(state.buffer, "", 1, state.buffer_size)
		local result = table_concat(state.result_buffer)
		return result
	end

	-- @see LibDeflate:DecompressDeflate(str)
	-- @see LibDeflate:DecompressDeflateWithDict(str, dictionary)
	local function DecompressDeflateInternal(str, dictionary)
		local state = CreateDecompressState(str, dictionary)
		local result, status = Inflate(state)
		if not result then
			return nil, status
		end

		local bitlen_left = state.ReaderBitlenLeft()
		local bytelen_left = (bitlen_left - bitlen_left % 8) / 8
		return result, bytelen_left
	end

	-- @see LibDeflate:DecompressZlib(str)
	-- @see LibDeflate:DecompressZlibWithDict(str)
	local function DecompressZlibInternal(str, dictionary)
		local state = CreateDecompressState(str, dictionary)
		local ReadBits = state.ReadBits

		local CMF = ReadBits(8)
		if state.ReaderBitlenLeft() < 0 then
			return nil, 2 -- available inflate data did not terminate
		end
		local CM = CMF % 16
		local CINFO = (CMF - CM) / 16
		if CM ~= 8 then
			return nil, -12 -- invalid compression method
		end
		if CINFO > 7 then
			return nil, -13 -- invalid window size
		end

		local FLG = ReadBits(8)
		if state.ReaderBitlenLeft() < 0 then
			return nil, 2 -- available inflate data did not terminate
		end
		if (CMF*256+FLG)%31 ~= 0 then
			return nil, -14 -- invalid header checksum
		end

		local FDIST = ((FLG-FLG%32)/32 % 2)
		local FLEVEL = ((FLG-FLG%64)/64 % 4) -- luacheck: ignore FLEVEL

		if FDIST == 1 then
			if not dictionary then
				return nil, -16 -- need dictonary, but dictionary is not provided.
			end
			local byte3 = ReadBits(8)
			local byte2 = ReadBits(8)
			local byte1 = ReadBits(8)
			local byte0 = ReadBits(8)
			local actual_adler32 = byte3*16777216+byte2*65536+byte1*256+byte0
			if state.ReaderBitlenLeft() < 0 then
				return nil, 2 -- available inflate data did not terminate
			end
			if not IsEqualAdler32(actual_adler32, dictionary.adler32) then
				return nil, -17 -- dictionary adler32 does not match
			end
		end
		local result, status = Inflate(state)
		if not result then
			return nil, status
		end
		state.SkipToByteBoundary()

		local adler_byte0 = ReadBits(8)
		local adler_byte1 = ReadBits(8)
		local adler_byte2 = ReadBits(8)
		local adler_byte3 = ReadBits(8)
		if state.ReaderBitlenLeft() < 0 then
			return nil, 2 -- available inflate data did not terminate
		end

		local adler32_expected = adler_byte0*16777216
			+ adler_byte1*65536 + adler_byte2*256 + adler_byte3
		local adler32_actual = LibDeflate:Adler32(result)
		if not IsEqualAdler32(adler32_expected, adler32_actual) then
			return nil, -15 -- Adler32 checksum does not match
		end

		local bitlen_left = state.ReaderBitlenLeft()
		local bytelen_left = (bitlen_left - bitlen_left % 8) / 8
		return result, bytelen_left
	end

	--- Decompress a raw deflate compressed data.
	-- @param str [string] The data to be decompressed.
	-- @return [string/nil] If the decompression succeeds, return the decompressed
	-- data. If the decompression fails, return nil. You should check if this return
	-- value is non-nil to know if the decompression succeeds.
	-- @return [integer] If the decompression succeeds, return the number of
	-- unprocessed bytes in the input compressed data. This return value is a
	-- positive integer if the input data is a valid compressed data appended by an
	-- arbitary non-empty string. This return value is 0 if the input data does not
	-- contain any extra bytes.<br>
	-- If the decompression fails (The first return value of this function is nil),
	-- this return value is undefined.
	-- @see LibDeflate:CompressDeflate
	function LibDeflate:DecompressDeflate(str)
		local arg_valid, arg_err = IsValidArguments(str)
		if not arg_valid then
			error(("Usage: LibDeflate:DecompressDeflate(str): "
				..arg_err), 2)
		end
		return DecompressDeflateInternal(str)
	end

	--- Decompress a raw deflate compressed data with a preset dictionary.
	-- @param str [string] The data to be decompressed.
	-- @param dictionary [table] The preset dictionary used by
	-- LibDeflate:CompressDeflateWithDict when the compressed data is produced.
	-- Decompression and compression must use the same dictionary.
	-- Otherwise wrong decompressed data could be produced without generating any
	-- error.
	-- @return [string/nil] If the decompression succeeds, return the decompressed
	-- data. If the decompression fails, return nil. You should check if this return
	-- value is non-nil to know if the decompression succeeds.
	-- @return [integer] If the decompression succeeds, return the number of
	-- unprocessed bytes in the input compressed data. This return value is a
	-- positive integer if the input data is a valid compressed data appended by an
	-- arbitary non-empty string. This return value is 0 if the input data does not
	-- contain any extra bytes.<br>
	-- If the decompression fails (The first return value of this function is nil),
	-- this return value is undefined.
	-- @see LibDeflate:CompressDeflateWithDict
	function LibDeflate:DecompressDeflateWithDict(str, dictionary)
		local arg_valid, arg_err = IsValidArguments(str, true, dictionary)
		if not arg_valid then
			error(("Usage: LibDeflate:DecompressDeflateWithDict(str, dictionary): "
				..arg_err), 2)
		end
		return DecompressDeflateInternal(str, dictionary)
	end

	--- Decompress a zlib compressed data.
	-- @param str [string] The data to be decompressed
	-- @return [string/nil] If the decompression succeeds, return the decompressed
	-- data. If the decompression fails, return nil. You should check if this return
	-- value is non-nil to know if the decompression succeeds.
	-- @return [integer] If the decompression succeeds, return the number of
	-- unprocessed bytes in the input compressed data. This return value is a
	-- positive integer if the input data is a valid compressed data appended by an
	-- arbitary non-empty string. This return value is 0 if the input data does not
	-- contain any extra bytes.<br>
	-- If the decompression fails (The first return value of this function is nil),
	-- this return value is undefined.
	-- @see LibDeflate:CompressZlib
	function LibDeflate:DecompressZlib(str)
		local arg_valid, arg_err = IsValidArguments(str)
		if not arg_valid then
			error(("Usage: LibDeflate:DecompressZlib(str): "
				..arg_err), 2)
		end
		return DecompressZlibInternal(str)
	end

	--- Decompress a zlib compressed data with a preset dictionary.
	-- @param str [string] The data to be decompressed
	-- @param dictionary [table] The preset dictionary used by
	-- LibDeflate:CompressDeflateWithDict when the compressed data is produced.
	-- Decompression and compression must use the same dictionary.
	-- Otherwise wrong decompressed data could be produced without generating any
	-- error.
	-- @return [string/nil] If the decompression succeeds, return the decompressed
	-- data. If the decompression fails, return nil. You should check if this return
	-- value is non-nil to know if the decompression succeeds.
	-- @return [integer] If the decompression succeeds, return the number of
	-- unprocessed bytes in the input compressed data. This return value is a
	-- positive integer if the input data is a valid compressed data appended by an
	-- arbitary non-empty string. This return value is 0 if the input data does not
	-- contain any extra bytes.<br>
	-- If the decompression fails (The first return value of this function is nil),
	-- this return value is undefined.
	-- @see LibDeflate:CompressZlibWithDict
	function LibDeflate:DecompressZlibWithDict(str, dictionary)
		local arg_valid, arg_err = IsValidArguments(str, true, dictionary)
		if not arg_valid then
			error(("Usage: LibDeflate:DecompressZlibWithDict(str, dictionary): "
				..arg_err), 2)
		end
		return DecompressZlibInternal(str, dictionary)
	end

	-- Calculate the huffman code of fixed block
	do
		_fix_block_literal_huffman_bitlen = {}
		for sym=0, 143 do
			_fix_block_literal_huffman_bitlen[sym] = 8
		end
		for sym=144, 255 do
			_fix_block_literal_huffman_bitlen[sym] = 9
		end
		for sym=256, 279 do
			_fix_block_literal_huffman_bitlen[sym] = 7
		end
		for sym=280, 287 do
			_fix_block_literal_huffman_bitlen[sym] = 8
		end

		_fix_block_dist_huffman_bitlen = {}
		for dist=0, 31 do
			_fix_block_dist_huffman_bitlen[dist] = 5
		end
		local status
		status, _fix_block_literal_huffman_bitlen_count
		, _fix_block_literal_huffman_to_deflate_code =
			GetHuffmanForDecode(_fix_block_literal_huffman_bitlen, 287, 9)
		assert(status == 0)
		status, _fix_block_dist_huffman_bitlen_count,
		_fix_block_dist_huffman_to_deflate_code =
			GetHuffmanForDecode(_fix_block_dist_huffman_bitlen, 31, 5)
		assert(status == 0)

		_fix_block_literal_huffman_code =
			GetHuffmanCodeFromBitlen(_fix_block_literal_huffman_bitlen_count
				, _fix_block_literal_huffman_bitlen, 287, 9)
		_fix_block_dist_huffman_code =
			GetHuffmanCodeFromBitlen(_fix_block_dist_huffman_bitlen_count
				, _fix_block_dist_huffman_bitlen, 31, 5)
	end

	-- Prefix encoding algorithm
	-- Credits to LibCompress.
	-- The code has been rewritten by the author of LibDeflate.
	------------------------------------------------------------------------------

	-- to be able to match any requested byte value, the search
	-- string must be preprocessed characters to escape with %:
	-- ( ) . % + - * ? [ ] ^ $
	-- "illegal" byte values:
	-- 0 is replaces %z
	local _gsub_escape_table = {
		["\000"] = "%z", ["("] = "%(", [")"] = "%)", ["."] = "%.",
		["%"] = "%%", ["+"] = "%+", ["-"] = "%-", ["*"] = "%*",
		["?"] = "%?", ["["] = "%[", ["]"] = "%]", ["^"] = "%^",
		["$"] = "%$",
	}

	local function escape_for_gsub(str)
		return str:gsub("([%z%(%)%.%%%+%-%*%?%[%]%^%$])", _gsub_escape_table)
	end

	--- Create a custom codec with encoder and decoder. <br>
	-- This codec is used to convert an input string to make it not contain
	-- some specific bytes.
	-- This created codec and the parameters of this function do NOT take
	-- localization into account. One byte (0-255) in the string is exactly one
	-- character (0-255).
	-- Credits to LibCompress.
	-- The code has been rewritten by the author of LibDeflate. <br>
	-- @param reserved_chars [string] The created encoder will ensure encoded
	-- data does not contain any single character in reserved_chars. This parameter
	-- should be non-empty.
	-- @param escape_chars [string] The escape character(s) used in the created
	-- codec. The codec converts any character included in reserved\_chars /
	-- escape\_chars / map\_chars to (one escape char + one character not in
	-- reserved\_chars / escape\_chars / map\_chars).
	-- You usually only need to provide a length-1 string for this parameter.
	-- Length-2 string is only needed when
	-- reserved\_chars + escape\_chars + map\_chars is longer than 127.
	-- This parameter should be non-empty.
	-- @param map_chars [string] The created encoder will map every
	-- reserved\_chars:sub(i, i) (1 <= i <= #map\_chars) to map\_chars:sub(i, i).
	-- This parameter CAN be empty string.
	-- @return [table/nil] If the codec cannot be created, return nil.<br>
	-- If the codec can be created according to the given
	-- parameters, return the codec, which is a encode/decode table.
	-- The table contains two functions: <br>
	-- t:Encode(str) returns the encoded string. <br>
	-- t:Decode(str) returns the decoded string if succeeds. nil if fails.
	-- @return [nil/string] If the codec is successfully created, return nil.
	-- If not, return a string that describes the reason why the codec cannot be
	-- created.
	-- @usage
	-- -- Create an encoder/decoder that maps all "\000" to "\003",
	-- -- and escape "\001" (and "\002" and "\003") properly
	-- local codec = LibDeflate:CreateCodec("\000\001", "\002", "\003")
	--
	-- local encoded = codec:Encode(SOME_STRING)
	-- -- "encoded" does not contain "\000" or "\001"
	-- local decoded = codec:Decode(encoded)
	-- -- assert(decoded == SOME_STRING)
	function LibDeflate:CreateCodec(reserved_chars, escape_chars
		, map_chars)
		if type(reserved_chars) ~= "string"
			or type(escape_chars) ~= "string"
			or type(map_chars) ~= "string" then
			error(
				"Usage: LibDeflate:CreateCodec(reserved_chars,"
					.." escape_chars, map_chars):"
					.." All arguments must be string.", 2)
		end

		if escape_chars == "" then
			return nil, "No escape characters supplied."
		end
		if #reserved_chars < #map_chars then
			return nil, "The number of reserved characters must be"
				.." at least as many as the number of mapped chars."
		end
		if reserved_chars == "" then
			return nil, "No characters to encode."
		end

		local encode_bytes = reserved_chars..escape_chars..map_chars
		-- build list of bytes not available as a suffix to a prefix byte
		local taken = {}
		for i = 1, #encode_bytes do
			local byte = string_byte(encode_bytes, i, i)
			if taken[byte] then
				return nil, "There must be no duplicate characters in the"
					.." concatenation of reserved_chars, escape_chars and"
					.." map_chars."
			end
			taken[byte] = true
		end

		local decode_patterns = {}
		local decode_repls = {}

		-- the encoding can be a single gsub
		-- , but the decoding can require multiple gsubs
		local encode_search = {}
		local encode_translate = {}

		-- map single byte to single byte
		if #map_chars > 0 then
			local decode_search = {}
			local decode_translate = {}
			for i = 1, #map_chars do
				local from = string_sub(reserved_chars, i, i)
				local to = string_sub(map_chars, i, i)
				encode_translate[from] = to
				encode_search[#encode_search+1] = from
				decode_translate[to] = from
				decode_search[#decode_search+1] = to
			end
			decode_patterns[#decode_patterns+1] =
				"([".. escape_for_gsub(table_concat(decode_search)).."])"
			decode_repls[#decode_repls+1] = decode_translate
		end

		local escape_char_index = 1
		local escape_char = string_sub(escape_chars
			, escape_char_index, escape_char_index)
		-- map single byte to double-byte
		local r = 0 -- suffix char value to the escapeChar

		local decode_search = {}
		local decode_translate = {}
		for i = 1, #encode_bytes do
			local c = string_sub(encode_bytes, i, i)
			if not encode_translate[c] then
				while r >= 256 or taken[r] do
					r = r + 1
					if r > 255 then -- switch to next escapeChar
						decode_patterns[#decode_patterns+1] =
							escape_for_gsub(escape_char)
							.."(["
							.. escape_for_gsub(table_concat(decode_search)).."])"
						decode_repls[#decode_repls+1] = decode_translate

						escape_char_index = escape_char_index + 1
						escape_char = string_sub(escape_chars, escape_char_index
							, escape_char_index)
						r = 0
						decode_search = {}
						decode_translate = {}

						if not escape_char or escape_char == "" then
							-- actually I don't need to check
							-- "not ecape_char", but what if Lua changes
							-- the behavior of string.sub() in the future?
							-- we are out of escape chars and we need more!
							return nil, "Out of escape characters."
						end
					end
				end

				local char_r = _byte_to_char[r]
				encode_translate[c] = escape_char..char_r
				encode_search[#encode_search+1] = c
				decode_translate[char_r] = c
				decode_search[#decode_search+1] = char_r
				r = r + 1
			end
			if i == #encode_bytes then
				decode_patterns[#decode_patterns+1] =
					escape_for_gsub(escape_char).."(["
					.. escape_for_gsub(table_concat(decode_search)).."])"
				decode_repls[#decode_repls+1] = decode_translate
			end
		end

		local codec = {}

		local encode_pattern = "(["
			.. escape_for_gsub(table_concat(encode_search)).."])"
		local encode_repl = encode_translate

		function codec:Encode(str)
			if type(str) ~= "string" then
				error(("Usage: codec:Encode(str):"
					.." 'str' - string expected got '%s'."):format(type(str)), 2)
			end
			return string_gsub(str, encode_pattern, encode_repl)
		end

		local decode_tblsize = #decode_patterns
		local decode_fail_pattern = "(["
			.. escape_for_gsub(reserved_chars).."])"

		function codec:Decode(str)
			if type(str) ~= "string" then
				error(("Usage: codec:Decode(str):"
					.." 'str' - string expected got '%s'."):format(type(str)), 2)
			end
			if string_find(str, decode_fail_pattern) then
				return nil
			end
			for i = 1, decode_tblsize do
				str = string_gsub(str, decode_patterns[i], decode_repls[i])
			end
			return str
		end

		return codec
	end

	local _addon_channel_codec


	-- Credits to WeakAuras2 and Galmok for the 6 bit encoding algorithm.
	-- The code has been rewritten by the author of LibDeflate.
	-- The result of encoding will be 25% larger than the
	-- origin string, but every single byte of the encoding result will be
	-- printable characters as the following.
	local _byte_to_6bit_char = {
		[0]="a", "b", "c", "d", "e", "f", "g", "h",
		"i", "j", "k", "l", "m", "n", "o", "p",
		"q", "r", "s", "t", "u", "v", "w", "x",
		"y", "z", "A", "B", "C", "D", "E", "F",
		"G", "H", "I", "J", "K", "L", "M", "N",
		"O", "P", "Q", "R", "S", "T", "U", "V",
		"W", "X", "Y", "Z", "0", "1", "2", "3",
		"4", "5", "6", "7", "8", "9", "(", ")",
	}

	local _6bit_to_byte = {
		[97]=0,[98]=1,[99]=2,[100]=3,[101]=4,[102]=5,[103]=6,[104]=7,
		[105]=8,[106]=9,[107]=10,[108]=11,[109]=12,[110]=13,[111]=14,[112]=15,
		[113]=16,[114]=17,[115]=18,[116]=19,[117]=20,[118]=21,[119]=22,[120]=23,
		[121]=24,[122]=25,[65]=26,[66]=27,[67]=28,[68]=29,[69]=30,[70]=31,
		[71]=32,[72]=33,[73]=34,[74]=35,[75]=36,[76]=37,[77]=38,[78]=39,
		[79]=40,[80]=41,[81]=42,[82]=43,[83]=44,[84]=45,[85]=46,[86]=47,
		[87]=48,[88]=49,[89]=50,[90]=51,[48]=52,[49]=53,[50]=54,[51]=55,
		[52]=56,[53]=57,[54]=58,[55]=59,[56]=60,[57]=61,[40]=62,[41]=63,
	}

	--- Encode the string to make it printable. <br>
	--
	-- Credit to WeakAuras2, this function is equivalant to the implementation
	-- it is using right now. <br>
	-- The code has been rewritten by the author of LibDeflate. <br>
	-- The encoded string will be 25% larger than the origin string. However, every
	-- single byte of the encoded string will be one of 64 printable ASCII
	-- characters, which are can be easier copied, pasted and displayed.
	-- (26 lowercase letters, 26 uppercase letters, 10 numbers digits,
	-- left parenthese, or right parenthese)
	-- @param str [string] The string to be encoded.
	-- @return [string] The encoded string.
	function LibDeflate:EncodeForPrint(str)
		if type(str) ~= "string" then
			error(("Usage: LibDeflate:EncodeForPrint(str):"
				.." 'str' - string expected got '%s'."):format(type(str)), 2)
		end
		local strlen = #str
		local strlenMinus2 = strlen - 2
		local i = 1
		local buffer = {}
		local buffer_size = 0
		while i <= strlenMinus2 do
			local x1, x2, x3 = string_byte(str, i, i+2)
			i = i + 3
			local cache = x1+x2*256+x3*65536
			local b1 = cache % 64
			cache = (cache - b1) / 64
			local b2 = cache % 64
			cache = (cache - b2) / 64
			local b3 = cache % 64
			local b4 = (cache - b3) / 64
			buffer_size = buffer_size + 1
			buffer[buffer_size] =
				_byte_to_6bit_char[b1].._byte_to_6bit_char[b2]
				.._byte_to_6bit_char[b3].._byte_to_6bit_char[b4]
		end

		local cache = 0
		local cache_bitlen = 0
		while i <= strlen do
			local x = string_byte(str, i, i)
			cache = cache + x * _pow2[cache_bitlen]
			cache_bitlen = cache_bitlen + 8
			i = i + 1
		end
		while cache_bitlen > 0 do
			local bit6 = cache % 64
			buffer_size = buffer_size + 1
			buffer[buffer_size] = _byte_to_6bit_char[bit6]
			cache = (cache - bit6) / 64
			cache_bitlen = cache_bitlen - 6
		end

		return table_concat(buffer)
	end

	--- Decode the printable string produced by LibDeflate:EncodeForPrint.
	-- "str" will have its prefixed and trailing control characters or space
	-- removed before it is decoded, so it is easier to use if "str" comes form
	-- user copy and paste with some prefixed or trailing spaces.
	-- Then decode fails if the string contains any characters cant be produced by
	-- LibDeflate:EncodeForPrint. That means, decode fails if the string contains a
	-- characters NOT one of 26 lowercase letters, 26 uppercase letters,
	-- 10 numbers digits, left parenthese, or right parenthese.
	-- @param str [string] The string to be decoded
	-- @return [string/nil] The decoded string if succeeds. nil if fails.
	function LibDeflate:DecodeForPrint(str)
		if type(str) ~= "string" then
			error(("Usage: LibDeflate:DecodeForPrint(str):"
				.." 'str' - string expected got '%s'."):format(type(str)), 2)
		end
		str = str:gsub("^[%c ]+", "")
		str = str:gsub("[%c ]+$", "")

		local strlen = #str
		if strlen == 1 then
			return nil
		end
		local strlenMinus3 = strlen - 3
		local i = 1
		local buffer = {}
		local buffer_size = 0
		while i <= strlenMinus3 do
			local x1, x2, x3, x4 = string_byte(str, i, i+3)
			x1 = _6bit_to_byte[x1]
			x2 = _6bit_to_byte[x2]
			x3 = _6bit_to_byte[x3]
			x4 = _6bit_to_byte[x4]
			if not (x1 and x2 and x3 and x4) then
				return nil
			end
			i = i + 4
			local cache = x1+x2*64+x3*4096+x4*262144
			local b1 = cache % 256
			cache = (cache - b1) / 256
			local b2 = cache % 256
			local b3 = (cache - b2) / 256
			buffer_size = buffer_size + 1
			buffer[buffer_size] =
				_byte_to_char[b1].._byte_to_char[b2].._byte_to_char[b3]
		end

		local cache  = 0
		local cache_bitlen = 0
		while i <= strlen do
			local x = string_byte(str, i, i)
			x =  _6bit_to_byte[x]
			if not x then
				return nil
			end
			cache = cache + x * _pow2[cache_bitlen]
			cache_bitlen = cache_bitlen + 6
			i = i + 1
		end

		while cache_bitlen >= 8 do
			local byte = cache % 256
			buffer_size = buffer_size + 1
			buffer[buffer_size] = _byte_to_char[byte]
			cache = (cache - byte) / 256
			cache_bitlen = cache_bitlen - 8
		end

		return table_concat(buffer)
	end

	local function InternalClearCache()
		_addon_channel_codec = nil
	end

	-- For test. Don't use the functions in this table for real application.
	-- Stuffs in this table is subject to change.
	LibDeflate.internals = {
		LoadStringToTable = LoadStringToTable,
		IsValidDictionary = IsValidDictionary,
		IsEqualAdler32 = IsEqualAdler32,
		_byte_to_6bit_char = _byte_to_6bit_char,
		_6bit_to_byte = _6bit_to_byte,
		InternalClearCache = InternalClearCache,
	}

	return Compression
end)()

local CanvasDraw = (function()

	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

	do

		local module = {}

		local OFF_SCREEN = UDim2.fromOffset(0, math.huge)

		local TableInsert = table.insert
		local TableRemove = table.remove

		function module.new(original: GuiObject, initSize: number?)
			initSize = initSize or 50

			local Pool = {
				_Available = table.create(initSize),
				_Source = original:Clone(),
				_Index = initSize,
			}

			for i = 1, initSize do
				Pool._Available[i] = Pool._Source:Clone()
			end

			function Pool:Get()
				local Index = self._Index

				if Index > 0 then
					local object = self._Available[Index]
					TableRemove(self._Available, Index)
					self._Index -= 1
					return object
				end

				return self._Source:Clone()
			end

			function Pool:Return(object: GuiObject)
				object.Position = OFF_SCREEN
				TableInsert(self._Available, object)
				self._Index += 1
			end

			return Pool
		end

		local GuiPool = module

		local module = {}

		--local Util = require(script.Util)

		-- Micro optimisations
		local TableInsert = table.insert
		local TableClear = table.clear
		local TableCreate = table.create

		local Mclamp = math.clamp

		local UDim2FromScale = UDim2.fromScale
		local ColorSeqKeyPNew = ColorSequenceKeypoint.new
		local ColorSeqNew = ColorSequence.new

		function module.new(ResX: number, ResY: number, BlurEnabled: boolean)
			local Canvas = {
				_Active = 0,
				_ColumnFrames = {},
				_UpdatedColumns = {},

				--Threshold = 2,
				--LossyThreshold = 4,
			}

			local invX, invY = 1 / ResX, 1 / ResY
			--local dist = ResY * 0.03

			-- Generate initial grid of color data
			local Grid = TableCreate(ResX)
			for x = 1, ResX do
				Grid[x] = TableCreate(ResY, Color3.new(0.98, 1, 1))
			end
			Canvas._Grid = Grid

			-- Create a pool of Frame instances with Gradients
			do
				local Pixel = Instance.new("Frame")
				Pixel.BackgroundColor3 = Color3.new(1, 1, 1)
				Pixel.BorderSizePixel = 0
				Pixel.Name = "Pixel"
				local Gradient = Instance.new("UIGradient")
				Gradient.Name = "Gradient"
				Gradient.Rotation = 90
				Gradient.Parent = Pixel

				Canvas._Pool = GuiPool.new(Pixel, ResX)
				Pixel:Destroy()
			end

			-- Create GUIs
			local Gui = Instance.new("Frame")
			Gui.Name = "GradientCanvas"
			Gui.BackgroundTransparency = 1
			Gui.ClipsDescendants = true
			Gui.Size = UDim2.fromScale(1, 1)
			Gui.Position = UDim2.fromScale(0.5, 0.5)
			Gui.AnchorPoint = Vector2.new(0.5, 0.5)

			local AspectRatio = Instance.new("UIAspectRatioConstraint")
			AspectRatio.AspectRatio = ResX / ResY
			AspectRatio.Parent = Gui

			local Container = Instance.new("Folder")
			Container.Name = "FrameContainer"
			Container.Parent = Gui

			-- Define API
			local function createGradient(colorData, x, pixelStart, pixelCount)
				local Sequence = TableCreate(#colorData)
				for i, data in colorData do
					Sequence[i] = ColorSeqKeyPNew(Mclamp(data.p / pixelCount, 0, 1), data.c)
				end

				local Frame = Canvas._Pool:Get()
				Frame.Position = UDim2FromScale(invX * (x - 1), pixelStart * invY)
				Frame.Size = UDim2FromScale(invX, invY * pixelCount)
				Frame.Gradient.Color = ColorSeqNew(Sequence)
				Frame.Parent = Container

				if Canvas._ColumnFrames[x] == nil then
					Canvas._ColumnFrames[x] = { Frame }
				else
					TableInsert(Canvas._ColumnFrames[x], Frame)
				end

				Canvas._Active += 1
			end

			Canvas.Gui = Gui
			function Canvas:Destroy()
				TableClear(Canvas._Grid)
				TableClear(Canvas)
				Gui:Destroy()
			end

			function Canvas:SetParent(parent: Instance)
				Gui.Parent = parent
			end

			function Canvas:SetPixel(x: number, y: number, color: Color3)
				local Col = self._Grid[x]

				if Col[y] ~= color then
					Col[y] = color
					self._UpdatedColumns[x] = Col
				end
			end

			function Canvas:GetPixel(x: number, y: number)
				--local Col = self._Grid[x]
				--if not Col then
				--	return
				--end

				return self._Grid[x][y]
			end

			function Canvas:Clear(x: number?)
				if x then
					local column = self._ColumnFrames[x]
					if column == nil then return end

					for _, object in column do
						self._Pool:Return(object)
						self._Active -= 1
					end
					TableClear(column)
				else
					for _, object in Container:GetChildren() do
						self._Pool:Return(object)
					end
					self._Active = 0
					TableClear(self._ColumnFrames)
				end
			end

			function Canvas:Render()
				for x, column in self._UpdatedColumns do
					self:Clear(x)

					local colorCount, colorData = 1, {
						{ p = 0, c = column[1] },
					}

					local pixelStart, pixelCount = 0, 0
					--local pixelStart, lastPixel, pixelCount = 0, 0, 0

					local lastColor = column[1]

					-- Compress into gradients
					for y, color in column do
						pixelCount += 1

						-- Early exit to avoid the delta check on direct equality
						if lastColor == color then
							continue
						end

						--local delta = Util.DeltaRGB(lastColor, color)
						--if delta > self.Threshold then
						local offset = y - pixelStart - 1

						--if (delta > self.LossyThreshold) or (y-lastPixel > dist) then

						TableInsert(colorData, { p = offset - 0.08, c = lastColor })
						--colorCount += 1

						TableInsert(colorData, { p = offset, c = color })
						colorCount += 2

						lastColor = color
						--lastPixel = y

						if colorCount > 18 then
							TableInsert(colorData, { p = pixelCount, c = color })
							createGradient(colorData, x, pixelStart, pixelCount)

							pixelStart = y - 1
							pixelCount = 0
							colorCount = 1
							TableClear(colorData)
							colorData[1] = { p = 0, c = color }
						end
						--end
					end

					if pixelCount + pixelStart ~= ResY then
						pixelCount += 1
					end
					TableInsert(colorData, { p = pixelCount, c = lastColor })
					createGradient(colorData, x, pixelStart, pixelCount)
				end

				TableClear(self._UpdatedColumns)
			end

			return Canvas
		end

		GradientCanvas = module
	end
	-- Module by 1waffle1, optimized by boatbomber
	-- https://devforum.roblox.com/t/text-compression/163637

	local dictionary = {}
	do -- populate dictionary
		local length = 0
		for i = 32, 127 do
			if i ~= 34 and i ~= 92 then
				local c = string.char(i)
				dictionary[c], dictionary[length] = length, c
				length = length + 1
			end
		end
	end

	local escapemap = {}
	do -- Populate escape map
		for i = 1, 34 do
			i = ({ 34, 92, 127 })[i - 31] or i
			local c, e = string.char(i), string.char(i + 31)
			escapemap[c], escapemap[e] = e, c
		end
	end

	local function escape(s)
		return string.gsub(s, '[%c"\\]', function(c)
			return "\127" .. escapemap[c]
		end)
	end
	local function unescape(s)
		return string.gsub(s, "\127(.)", function(c)
			return escapemap[c]
		end)
	end

	local function copy(t)
		local new = {}
		for k, v in pairs(t) do
			new[k] = v
		end
		return new
	end

	local b93Cache = {}
	local function tobase93(n)
		local value = b93Cache[n]
		if value then
			return value
		end

		value = ""
		repeat
			local remainder = n % 93
			value = dictionary[remainder] .. value
			n = (n - remainder) / 93
		until n == 0

		b93Cache[n] = value
		return value
	end

	local b10Cache = {}
	local function tobase10(value)
		local n = b10Cache[value]
		if n then
			return n
		end

		n = 0
		for i = 1, #value do
			n = n + 93 ^ (i - 1) * dictionary[string.sub(value, -i, -i)]
		end

		b10Cache[value] = n
		return n
	end

	local function compress(text)
		local dictionaryCopy = copy(dictionary)
		local key, sequence, size = "", {}, #dictionaryCopy
		local width, spans, span = 1, {}, 0
		local function listkey(k)
			local value = tobase93(dictionaryCopy[k])
			local valueLength = #value
			if valueLength > width then
				width, span, spans[width] = valueLength, 0, span
			end
			table.insert(sequence, string.rep(" ", width - valueLength) .. value)
			span += 1
		end
		text = escape(text)
		for i = 1, #text do
			local c = string.sub(text, i, i)
			local new = key .. c
			if dictionaryCopy[new] then
				key = new
			else
				listkey(key)
				key = c
				size += 1
				dictionaryCopy[new], dictionaryCopy[size] = size, new
			end
		end
		listkey(key)
		spans[width] = span
		return table.concat(spans, ",") .. "|" .. table.concat(sequence)
	end

	local function decompress(text)
		local dictionaryCopy = copy(dictionary)
		local sequence, spans, content = {}, string.match(text, "(.-)|(.*)")
		local groups, start = {}, 1
		for span in string.gmatch(spans, "%d+") do
			local width = #groups + 1
			groups[width] = string.sub(content, start, start + span * width - 1)
			start = start + span * width
		end
		local previous

		for width, group in ipairs(groups) do
			for value in string.gmatch(group, string.rep(".", width)) do
				local entry = dictionaryCopy[tobase10(value)]
				if previous then
					if entry then
						table.insert(dictionaryCopy, previous .. string.sub(entry, 1, 1))
					else
						entry = previous .. string.sub(previous, 1, 1)
						table.insert(dictionaryCopy, entry)
					end
					table.insert(sequence, entry)
				else
					sequence[1] = entry
				end
				previous = entry
			end
		end
		return unescape(table.concat(sequence))
	end

	local StringCompressor = { Compress = compress, Decompress = decompress }
	local PixelTextCharacters = {
		-- Numbers
		["0"] = {
			{1,1,1},
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{1,1,1},
		},
		["1"] = {
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{0,1,0},
		},
		["2"] = {
			{1,1,1},
			{0,0,1},
			{1,1,1},
			{1,0,0},
			{1,1,1},
		},
		["3"] = {
			{1,1,1},
			{0,0,1},
			{1,1,1},
			{0,0,1},
			{1,1,1},
		},
		["4"] = {
			{1,0,1},
			{1,0,1},
			{1,1,1},
			{0,0,1},
			{0,0,1},
		},
		["5"] = {
			{1,1,1},
			{1,0,0},
			{1,1,1},
			{0,0,1},
			{1,1,1},
		},
		["6"] = {
			{1,1,1},
			{1,0,0},
			{1,1,1},
			{1,0,1},
			{1,1,1},
		},
		["7"] = {
			{1,1,1},
			{0,0,1},
			{0,0,1},
			{0,0,1},
			{0,0,1},
		},
		["8"] = {
			{1,1,1},
			{1,0,1},
			{1,1,1},
			{1,0,1},
			{1,1,1},
		},
		["9"] = {
			{1,1,1},
			{1,0,1},
			{1,1,1},
			{0,0,1},
			{1,1,1},
		},

		-- Letters
		["a"] = {
			{1,1,1},
			{1,0,1},
			{1,1,1},
			{1,0,1},
			{1,0,1},
		},
		["b"] = {
			{1,1,0},
			{1,0,1},
			{1,1,1},
			{1,0,1},
			{1,1,1},
		},
		["c"] = {
			{1,1,1},
			{1,0,0},
			{1,0,0},
			{1,0,0},
			{1,1,1},
		},
		["d"] = {
			{1,1,0},
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{1,1,1},
		},
		["e"] = {
			{1,1,1},
			{1,0,0},
			{1,1,1},
			{1,0,0},
			{1,1,1},
		},
		["f"] = {
			{1,1,1},
			{1,0,0},
			{1,1,1},
			{1,0,0},
			{1,0,0},
		},
		["g"] = {
			{1,1,1},
			{1,0,0},
			{1,0,1},
			{1,0,1},
			{1,1,1},
		},
		["h"] = {
			{1,0,1},
			{1,0,1},
			{1,1,1},
			{1,0,1},
			{1,0,1},
		},
		["i"] = {
			{1,1,1},
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{1,1,1},
		},
		["j"] = {
			{0,0,1},
			{0,0,1},
			{0,0,1},
			{1,0,1},
			{1,1,1},
		},
		["k"] = {
			{1,0,1},
			{1,0,1},
			{1,1,0},
			{1,0,1},
			{1,0,1},
		},
		["l"] = {
			{1,0,0},
			{1,0,0},
			{1,0,0},
			{1,0,0},
			{1,1,1},
		},
		["m"] = {
			{1,0,1},
			{1,1,1},
			{1,1,1},
			{1,0,1},
			{1,0,1},
		},
		["n"] = {
			{1,1,1},
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{1,0,1},
		},
		["o"] = {
			{1,1,1},
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{1,1,1},
		},
		["p"] = {
			{1,1,1},
			{1,0,1},
			{1,1,1},
			{1,0,0},
			{1,0,0},
		},
		["q"] = {
			{1,1,1},
			{1,0,1},
			{1,0,1},
			{1,1,1},
			{0,1,0},
		},
		["r"] = {
			{1,1,1},
			{1,0,1},
			{1,1,0},
			{1,0,1},
			{1,0,1},
		},
		["s"] = {
			{1,1,1},
			{1,0,0},
			{1,1,1},
			{0,0,1},
			{1,1,1},
		},
		["t"] = {
			{1,1,1},
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{0,1,0},
		},
		["u"] = {
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{1,1,1},
		},
		["v"] = {
			{1,0,1},
			{1,0,1},
			{1,0,1},
			{0,1,0},
			{0,1,0},
		},
		["w"] = {
			{1,0,1},
			{1,0,1},
			{1,1,1},
			{1,1,1},
			{1,0,1},
		},
		["x"] = {
			{1,0,1},
			{1,0,1},
			{0,1,0},
			{1,0,1},
			{1,0,1},
		},
		["y"] = {
			{1,0,1},
			{1,0,1},
			{1,1,1},
			{0,1,0},
			{0,1,0},
		},
		["z"] = {
			{1,1,1},
			{0,0,1},
			{0,1,0},
			{1,0,0},
			{1,1,1},
		},

		-- Symbols
		["!"] = {
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{0,0,0},
			{0,1,0},
		},
		["@"] = {
			{1,1,0},
			{0,0,1},
			{1,1,1},
			{1,0,1},
			{1,1,0},
		},
		["#"] = {
			{1,0,1},
			{1,1,1},
			{1,0,1},
			{1,1,1},
			{1,0,1},
		},
		["$"] = {
			{0,1,0},
			{1,1,1},
			{1,0,0},
			{1,1,1},
			{0,1,0},
		},
		["%"] = {
			{1,0,1},
			{0,0,1},
			{0,1,0},
			{1,0,0},
			{1,0,1},
		},
		["^"] = {
			{0,1,0},
			{1,0,1},
			{0,0,0},
			{0,0,0},
			{0,0,0},
		},
		["&"] = {
			{0,1,0},
			{1,0,1},
			{0,1,0},
			{1,0,1},
			{1,1,1},
		},
		["*"] = {
			{1,0,1},
			{0,1,0},
			{1,0,1},
			{0,0,0},
			{0,0,0},
		},
		["("] = {
			{0,1,1},
			{1,0,0},
			{1,0,0},
			{1,0,0},
			{0,1,1},
		},
		[")"] = {
			{1,1,0},
			{0,0,1},
			{0,0,1},
			{0,0,1},
			{1,1,0},
		},
		["["] = {
			{1,1,1},
			{1,0,0},
			{1,0,0},
			{1,0,0},
			{1,1,1},
		},
		["]"] = {
			{1,1,1},
			{0,0,1},
			{0,0,1},
			{0,0,1},
			{1,1,1},
		},
		["{"] = {
			{0,1,1},
			{0,1,0},
			{1,1,0},
			{0,1,0},
			{0,1,1},
		},
		["}"] = {
			{1,1,0},
			{0,1,0},
			{0,1,1},
			{0,1,0},
			{1,1,0},
		},
		["-"] = {
			{0,0,0},
			{0,0,0},
			{1,1,1},
			{0,0,0},
			{0,0,0},
		},
		["_"] = {
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{1,1,1},
		},
		["+"] = {
			{0,0,0},
			{0,1,0},
			{1,1,1},
			{0,1,0},
			{0,0,0},
		},
		["="] = {
			{0,0,0},
			{1,1,1},
			{0,0,0},
			{1,1,1},
			{0,0,0},
		},
		["<"] = {
			{0,0,1},
			{0,1,0},
			{1,0,0},
			{0,1,0},
			{0,0,1},
		},
		[">"] = {
			{1,0,0},
			{0,1,0},
			{0,0,1},
			{0,1,0},
			{1,0,0},
		},
		["?"] = {
			{1,1,0},
			{0,0,1},
			{0,1,0},
			{0,0,0},
			{0,1,0},
		},
		["."] = {
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{0,1,0},
		},
		[","] = {
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{0,1,0},
			{0,1,0},
		},
		["/"] = {
			{0,0,1},
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{1,0,0},
		},
		["|"] = {
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{0,1,0},
			{0,1,0},
		},
		[":"] = {
			{1,0,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{1,0,0},
		},
		[";"] = {
			{1,0,0},
			{0,0,0},
			{0,0,0},
			{1,0,0},
			{1,0,0},
		},
		['"'] = {
			{1,0,1},
			{1,0,1},
			{0,0,0},
			{0,0,0},
			{0,0,0},
		},
		["'"] = {
			{0,1,0},
			{0,1,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
		},
		["`"] = {
			{1,0,0},
			{0,1,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
		},
		["~"] = {
			{0,0,0},
			{1,1,0},
			{0,1,1},
			{0,0,0},
			{0,0,0},
		},
		[" "] = {
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
			{0,0,0},
		},
	}
	local Abs = math.abs

	function getNormalFromPartFace(part, normalId)
		return part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(normalId))
	end

	function normalVectorToFace(part, normalVector)
		local normalIDs = {
			Enum.NormalId.Front,
			Enum.NormalId.Back,
			Enum.NormalId.Bottom,
			Enum.NormalId.Top,
			Enum.NormalId.Left,
			Enum.NormalId.Right
		}  

		for _, normalId in ipairs(normalIDs) do
			if getNormalFromPartFace(part, normalId):Dot(normalVector) > 0.999 then
				return normalId
			end
		end

		return nil -- None found within tolerance.
	end

	function getTopLeftCorners(part)
		local size = part.Size
		return {
			[Enum.NormalId.Front] = part.CFrame * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
			[Enum.NormalId.Back] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
			[Enum.NormalId.Right] = part.CFrame * CFrame.new(size.X/2, size.Y/2, size.Z/2),
			[Enum.NormalId.Left] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
			[Enum.NormalId.Bottom] = part.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
			[Enum.NormalId.Top] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2)
		}
	end

	function getRotationComponents(offset) 
		local components = {offset:GetComponents()}
		table.remove(components, 1)
		table.remove(components, 2)
		table.remove(components, 3)

		return components
	end

	local VectorFuncs = {
		["normalVectorToFace"] = normalVectorToFace,
		["getTopLeftCorners"] = getTopLeftCorners
	}

	local CanvasDraw = {}

	-- These variables are only accessed by this module
	local SaveObjectResolutionLimit = Vector2.new(256, 256) -- [DO NOT EDIT!] Roblox string value character limits
	local CanvasResolutionLimit = Vector2.new(256, 256) -- Too many frames can cause rendering issues for roblox. So I think having this limit will help solve this problem for now.

	-- Micro optimisations
	local TableInsert = table.insert
	local TableFind = table.find
	local RoundN = math.round
	local Vector2New = Vector2.new
	local CeilN = math.ceil

	--== BUILT-IN FUNCTIONS ==--

	local function Swap(A, B)
		return B, A
	end

	local function GetRange(A, B)
		if A > B then
			return RoundN(A - B), -1
		else
			return RoundN(B - A), 1
		end
	end

	local function RoundPoint(Point)
		local X = RoundN(Point.X)
		local Y = RoundN(Point.Y)
		return Vector2New(X, Y)
	end

	local function PointToPixelIndex(Point, Resolution)
		return RoundN(Point.X) + (RoundN(Point.Y) - 1) * Resolution.X
	end

	local function XYToPixelIndex(X, Y, ResolutionX)
		return X + (Y - 1) * ResolutionX
	end

	local function Lerp(A, B, T)
		return A + (B - A) * T
	end

	local function LerpF(A, B, T) -- Assumes values range from 0 to 1
		return A + (B - A) * T
	end

	--== MODULE FUCNTIONS ==--

	-- Canvas functions

	function CanvasDraw.new(Frame: GuiObject, Resolution: Vector2?, CanvasColour: Color3?)
		local Canvas = {
			-- Modifyable properties/events
			OutputWarnings = true,
			AutoUpdate = true,

			-- Read only
			Resolution = Vector2New(100, 100),

			Updated = RunService.Heartbeat -- Event
		}


		--==<< Interal Functions >>==--

		local function OutputWarn(Message)
			if Canvas.OutputWarnings then
				warn("(!) CanvasDraw Module Warning: '" .. Message .. "'")
			end
		end

		--==<< Canvas Set-up >>==--

		-- Parameter defaults
		if CanvasColour then
			Canvas.CanvasColour = CanvasColour 
		else
			Canvas.CanvasColour = Frame.BackgroundColor3
		end

		if Resolution then
			if Resolution.X > CanvasResolutionLimit.X or Resolution.Y > CanvasResolutionLimit.Y then
				OutputWarn("A canvas cannot be built with a resolution larger than " .. CanvasResolutionLimit.X .. " x " .. CanvasResolutionLimit.Y .. ".")
				Resolution = CanvasResolutionLimit
			end
			Canvas.Resolution = Resolution
			Canvas.CurrentResX = Resolution.X
			Canvas.CurrentResY = Resolution.Y
		else
			Canvas.CurrentResX = 100
			Canvas.CurrentResY = 100
		end

		-- Create the canvas
		local InternalCanvas = GradientCanvas.new(Canvas.CurrentResX, Canvas.CurrentResY)
		InternalCanvas:SetParent(Frame)
		Canvas.Gui = InternalCanvas.Gui

		Canvas.AutoUpdateConnection = RunService.Heartbeat:Connect(function()
			if InternalCanvas and Canvas.AutoUpdate then
				InternalCanvas:Render()
			end
		end)

		Canvas.CurrentCanvasFrame = Frame

		for Y = 1, Canvas.CurrentResY do
			for X = 1, Canvas.CurrentResX do
				InternalCanvas:SetPixel(X, Y, Canvas.CanvasColour)
			end
		end

		InternalCanvas:Render()

		Canvas.InternalCanvas = InternalCanvas



		--============================================================================================================--
		--====  <<   Canvas API   >>   ================================================================================--
		--============================================================================================================--

		--==<< Canvas Methods >>==--

		function Canvas:DestroyCanvas()
			InternalCanvas:Destroy()
			self.InternalCanvas = nil
			self.CurrentCanvasFrame = nil
			self.AutoUpdateConnection:Disconnect()
		end

		function Canvas:FillCanvas(Colour: Color3)
			for Y = 1, self.CurrentResY do
				for X = 1, self.CurrentResX do
					InternalCanvas:SetPixel(X, Y, Colour)
				end
			end
		end

		function Canvas:ClearCanvas()
			self:FillCanvas(self.CanvasColour)
		end

		function Canvas:Update()
			InternalCanvas:Render()
		end


		--==<< Fetch Methods >>==--

		function Canvas:GetPixel(Point: Vector2): Color3
			Point = RoundPoint(Point)

			local X = Point.X
			local Y = Point.Y

			if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then
				return InternalCanvas:GetPixel(X, Y)
			end
		end

		function Canvas:GetPixelXY(X: number, Y: number): Color3
			return self.InternalCanvas:GetPixel(X, Y)
		end

		function Canvas:GetPixels(PointA: Vector2, PointB: Vector2): {}
			local PixelsArray = {}

			-- Get the all pixels between PointA and PointB
			if PointA and PointB then
				local DistX, FlipMultiplierX = GetRange(PointA.X, PointB.X)
				local DistY, FlipMultiplierY = GetRange(PointA.Y, PointB.Y)

				for Y = 0, DistY do
					for X = 0, DistX do
						local Point = Vector2New(PointA.X + X * FlipMultiplierX, PointA.Y + Y * FlipMultiplierY)
						local Pixel = self:GetPixel(Point)
						if Pixel then
							TableInsert(PixelsArray, Pixel)
						end
					end
				end
			else
				-- If there isn't any points in the paramaters, then return all pixels in the canvas
				for Y = 1, self.CurrentResX do
					for X = 1, self.CurrentResY do
						local Pixel = self:GetPixelXY(X, Y)
						if Pixel then
							TableInsert(PixelsArray, Pixel)
						end
					end
				end
			end

			return PixelsArray
		end

		function Canvas:GetMousePoint(): Vector2?
			if RunService:IsClient() then
				local MouseLocation = UserInputService:GetMouseLocation()
				local GuiInset = game.GuiService:GetGuiInset()

				local CanvasFrameSize = self.CurrentCanvasFrame.AbsoluteSize
				local GradientCanvasFrameSize = self.CurrentCanvasFrame.GradientCanvas.AbsoluteSize
				local CanvasPosition = self.CurrentCanvasFrame.AbsolutePosition

				local SurfaceGui = Frame:FindFirstAncestorOfClass("SurfaceGui")

				MouseLocation -= GuiInset

				if not SurfaceGui then
					-- Gui
					local MousePoint = MouseLocation - CanvasPosition

					local TransformedPoint = (MousePoint / GradientCanvasFrameSize) -- Normalised

					TransformedPoint *= self.Resolution -- Canvas space

					-- Make sure everything is aligned when the canvas is at different aspect ratios
					local RatioDifference = Vector2New(CanvasFrameSize.X / GradientCanvasFrameSize.X, CanvasFrameSize.Y / GradientCanvasFrameSize.Y) - Vector2New(1, 1)
					TransformedPoint -= (RatioDifference / 2) * self.Resolution

					local RoundX = math.ceil(TransformedPoint.X)
					local RoundY = math.ceil(TransformedPoint.Y)

					TransformedPoint = Vector2.new(RoundX, RoundY)

					-- If the point is within the canvas, return it.
					if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
						return TransformedPoint
					end
				else
					-- SurfaceGui
					local Part = SurfaceGui.Adornee or SurfaceGui:FindFirstAncestorWhichIsA("BasePart") 
					local Camera = workspace.CurrentCamera

					local GradientCanvasFrame = Frame:FindFirstChild("GradientCanvas")

					if Part and GradientCanvasFrame then
						local Params = RaycastParams.new()
						Params.FilterType = Enum.RaycastFilterType.Include
						Params.FilterDescendantsInstances = {Part}

						local UnitRay = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

						local Result = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Params)

						if Result then
							local Normal = Result.Normal
							local IntersectionPos = Result.Position

							if VectorFuncs.normalVectorToFace(Part, Normal) ~= SurfaceGui.Face then
								return
							end

							-- Credits to @Krystaltinan for some of this code
							local hitCF = CFrame.lookAt(IntersectionPos, IntersectionPos + Normal)

							local topLeftCorners = VectorFuncs.getTopLeftCorners(Part)
							local topLeftCFrame = topLeftCorners[SurfaceGui.Face]

							local hitOffset = topLeftCFrame:ToObjectSpace(hitCF)

							local ScreenPos = Vector2.new(
								math.abs(hitOffset.X), 
								math.abs(hitOffset.Y)
							)

							-- Ensure the calculations work for all faces
							if SurfaceGui.Face == Enum.NormalId.Front or SurfaceGui.Face == Enum.NormalId.Back then
								ScreenPos -= Vector2.new(Part.Size.X / 2, Part.Size.Y / 2)
								ScreenPos /= Vector2.new(Part.Size.X, Part.Size.Y)
							else
								return -- Other faces don't seem to work for now
							end

							local PositionalOffset
							local AspectRatioDifference = GradientCanvasFrameSize / CanvasFrameSize
							local SurfaceGuiSizeDifference = SurfaceGui.AbsoluteSize / CanvasFrameSize

							--print(SurfaceGuiSizeDifference)

							local PosFixed = ScreenPos + Vector2.new(0.5, 0.5) -- Move origin to top left

							ScreenPos = PosFixed * SurfaceGui.AbsoluteSize -- Convert to SurfaceGui space

							ScreenPos -= CanvasPosition

							local TransformedPoint = (ScreenPos / GradientCanvasFrameSize) -- Normalised

							TransformedPoint *= self.Resolution -- Canvas space
							TransformedPoint += Vector2.new(0.5, 0.5)

							-- Make sure everything is aligned when the canvas is at different aspect ratios
							local RatioDifference = Vector2New(CanvasFrameSize.X / GradientCanvasFrameSize.X, CanvasFrameSize.Y / GradientCanvasFrameSize.Y) - Vector2New(1, 1)
							TransformedPoint -= (RatioDifference / 2) * self.Resolution

							TransformedPoint = RoundPoint(TransformedPoint)

							-- If the point is within the canvas, return it.
							if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
								return TransformedPoint
							end

							return TransformedPoint
						end
					end	
				end
			else
				OutputWarn("Failed to get point from mouse (you cannot use this function on the server. Please call this function from a LocalScript).")
			end
		end


		--==<< Canvas Image Data Methods >>==--

		function Canvas:CreateImageDataFromCanvas(PointA: Vector2, PointB: Vector2): {}
			-- Set the default points to be the whole canvas corners
			if not PointA and not PointB then
				PointA = Vector2New(1, 1)
				PointB = self.Resolution
			end

			local ImageResolutionX = GetRange(PointA.X, PointB.X) + 1
			local ImageResolutionY = GetRange(PointA.Y, PointB.Y) + 1

			local ColoursData = self:GetPixels(PointA, PointB)
			local AlphasData = {}

			-- Canvas has no transparency. So all alpha values will be 255
			for i = 1, #ColoursData do
				TableInsert(AlphasData, 255)
			end

			return {ImageColours = ColoursData, ImageAlphas = AlphasData, ImageResolution = Vector2New(ImageResolutionX, ImageResolutionY)}
		end

		function Canvas:DrawImageXY(ImageData, X: number?, Y: number?, ScaleX: number?, ScaleY: number?, TransparencyEnabled: boolean?)
			X = X or 1
			Y = Y or 1
			ScaleX = ScaleX or 1
			ScaleY = ScaleY or 1

			local ImageResolutionX = ImageData.ImageResolution.X
			local ImageResolutionY = ImageData.ImageResolution.Y
			local ImageColours = ImageData.ImageColours
			local ImageAlphas = ImageData.ImageAlphas

			local ScaledImageResX = ImageResolutionX * ScaleX
			local ScaledImageResY = ImageResolutionY * ScaleY

			local StartX = 1
			local StartY = 1

			-- Clipping
			if X < 1 then
				StartX = -X + 2
			end
			if Y < 1 then
				StartY = -Y + 2
			end
			if X + ScaledImageResX - 1 > self.CurrentResX then
				ScaledImageResX -= (X + ScaledImageResX - 1) - self.CurrentResX
			end
			if Y + ScaledImageResY - 1 > self.CurrentResY then
				ScaledImageResY -= (Y + ScaledImageResY - 1) - self.CurrentResY
			end

			if not TransparencyEnabled then
				if ScaleX == 1 and ScaleY == 1 then
					-- Draw normal image with no transparency and no scale adjustments (most optimal)
					for ImgX = StartX, ScaledImageResX do
						local PlacementX = X + ImgX - 1

						for ImgY = StartY, ScaledImageResY do
							local PlacementY = Y + ImgY - 1

							local ImgPixelColour = ImageColours[ImgX + (ImgY - 1) * ImageResolutionX]
							InternalCanvas:SetPixel(PlacementX, PlacementY, ImgPixelColour)
						end
					end
				else
					-- Draw normal image with no transparency with scale adjustments (pretty optimal)
					for ImgX = StartX, ScaledImageResX do
						local SampleX = CeilN(ImgX / ScaleX)
						local PlacementX = X + ImgX - 1

						for ImgY = StartY, ScaledImageResY do
							local SampleY = CeilN(ImgY / ScaleY)
							local PlacementY = Y + ImgY - 1

							local ImgPixelColour = ImageColours[SampleX + (SampleY - 1) * ImageResolutionX]
							InternalCanvas:SetPixel(PlacementX, PlacementY, ImgPixelColour)
						end
					end
				end	
			else
				-- Draw image with transparency (more expensive)
				for ImgX = StartX, ScaledImageResX do
					local SampleX = CeilN(ImgX / ScaleX)
					local PlacementX = X + ImgX - 1

					for ImgY = StartY, ScaledImageResY do
						local SampleY = CeilN(ImgY / ScaleY)
						local PlacementY = Y + ImgY - 1

						local ImgPixelIndex = SampleX + (SampleY - 1) * ImageResolutionX
						local ImgPixelAlpha = ImageAlphas[ImgPixelIndex]

						if ImgPixelAlpha <= 1 then -- No need to do any calculations for completely transparent pixels
							continue
						end

						local BgColour = InternalCanvas:GetPixel(PlacementX, PlacementY)

						local ImgPixelColour = ImageColours[ImgPixelIndex]

						InternalCanvas:SetPixel(PlacementX, PlacementY, BgColour:Lerp(ImgPixelColour, ImgPixelAlpha / 255))
					end
				end
			end
		end

		function Canvas:DrawImage(ImageData, Point: Vector2?, Scale: Vector2, TransparencyEnabled: boolean?)
			Point = Point or Vector2.new(1, 1)
			Scale = Scale or Vector2.new(1, 1)

			Point = RoundPoint(Point)

			Canvas:DrawImageXY(ImageData, Point.X, Point.Y, Scale.X, Scale.Y, TransparencyEnabled)
		end


		---==<< Draw Methods >>==--

		function Canvas:ClearPixels(PixelPoints: table)
			self:FillPixels(PixelPoints, self.CanvasColour)
		end

		function Canvas:FillPixels(Points: table, Colour: Color3)
			for i, Point in pairs(Points) do
				self:DrawPixel(Point, Colour)
			end
		end

		function Canvas:FloodFill(Point: Vector2, Colour: Color3) -- Optimised by @Arevoir
			Point = RoundPoint(Point)

			local OriginColour = self:GetPixel(Point)
			local ReturnPointsArray = {}
			local seen = {} 

			local vectorUp = Vector2New(0, -1)
			local vectorRight = Vector2New(1, 0)
			local vectorDown = Vector2New(0, 1)
			local vectorLeft = Vector2New(-1, 0)

			local queue = { Point }

			local canvasWidth, canvasHeight = self.CurrentResX, self.CurrentResY

			while #queue > 0 do
				local currentPoint = table.remove(queue)

				local currentPointX = currentPoint.X
				local currentPointY = currentPoint.Y

				if currentPointX > 0 and currentPointY > 0 and currentPointX <= canvasWidth and currentPointY <= canvasHeight then
					local key = currentPointX + (currentPointY - 1) * canvasWidth --currentPointX .. "," .. currentPointY

					if not seen[key] then
						local pixelColour = self:GetPixelXY(currentPointX, currentPointY)
						if pixelColour == OriginColour then
							table.insert(ReturnPointsArray, currentPoint)
							InternalCanvas:SetPixel(currentPointX, currentPointY, Colour)

							seen[key] = true

							table.insert(queue, currentPoint + vectorUp)
							table.insert(queue, currentPoint + vectorDown)
							table.insert(queue, currentPoint + vectorLeft)
							table.insert(queue, currentPoint + vectorRight)
						end
					end
				end
			end

			return ReturnPointsArray
		end

		function Canvas:FloodFillXY(Point: Vector2, Colour: Color3)
			Point = RoundPoint(Point)

			local OriginColour = self:GetPixel(Point)
			local seen = {} 

			local vectorUp = Vector2New(0, -1)
			local vectorRight = Vector2New(1, 0)
			local vectorDown = Vector2New(0, 1)
			local vectorLeft = Vector2New(-1, 0)

			local queue = { Point }

			local canvasWidth, canvasHeight = self.CurrentResX, self.CurrentResY

			while #queue > 0 do
				local currentPoint = table.remove(queue)

				local currentPointX = currentPoint.X
				local currentPointY = currentPoint.Y

				if currentPointX > 0 and currentPointY > 0 and currentPointX <= canvasWidth and currentPointY <= canvasHeight then
					local key = currentPointX + (currentPointY - 1) * canvasWidth --currentPointX .. "," .. currentPointY

					if not seen[key] then
						local pixelColour = self:GetPixelXY(currentPointX, currentPointY)
						if pixelColour == OriginColour then
							InternalCanvas:SetPixel(currentPointX, currentPointY, Colour)

							seen[key] = true

							table.insert(queue, currentPoint + vectorUp)
							table.insert(queue, currentPoint + vectorDown)
							table.insert(queue, currentPoint + vectorLeft)
							table.insert(queue, currentPoint + vectorRight)
						end
					end
				end
			end
		end

		function Canvas:DrawPixel(Point: Vector2, Colour: Color3): Vector2
			local X = RoundN(Point.X)
			local Y = RoundN(Point.Y)

			if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then	
				InternalCanvas:SetPixel(X, Y, Colour)
				return Point	
			end
		end

		function Canvas:SetPixel(X: number, Y: number, Colour: Color3) -- A raw and performant method to draw pixels (much faster than `DrawPixel()`)
			InternalCanvas:SetPixel(X, Y, Colour)
		end

		function Canvas:DrawCircle(Point: Vector2, Radius: number, Colour: Color3, Fill: boolean): {}
			local X = RoundN(Point.X)
			local Y = RoundN(Point.Y)

			local PointsArray = {}

			-- Draw the circle
			local dx, dy, err = Radius, 0, 1 - Radius

			local function CreatePixelForCircle(DrawPoint)
				self:DrawPixel(DrawPoint, Colour)
				TableInsert(PointsArray, DrawPoint)
			end

			local function CreateLineForCircle(PointB, PointA)
				local Line = self:DrawRectangle(PointA, PointB, Colour, true)

				for i, Point in pairs(Line) do
					TableInsert(PointsArray, Point)
				end
			end

			if Fill or type(Fill) == "nil" then
				while dx >= dy do -- Filled circle
					CreateLineForCircle(Vector2New(X + dx, Y + dy), Vector2New(X - dx, Y + dy))
					CreateLineForCircle(Vector2New(X + dx, Y - dy), Vector2New(X - dx, Y - dy))
					CreateLineForCircle(Vector2New(X + dy, Y + dx), Vector2New(X - dy, Y + dx))
					CreateLineForCircle(Vector2New(X + dy, Y - dx), Vector2New(X - dy, Y - dx))

					dy = dy + 1
					if err < 0 then
						err = err + 2 * dy + 1
					else
						dx, err = dx - 1, err + 2 * (dy - dx) + 1
					end
				end
			else
				while dx >= dy do -- Circle outline
					CreatePixelForCircle(Vector2New(X + dx, Y + dy))
					CreatePixelForCircle(Vector2New(X - dx, Y + dy))
					CreatePixelForCircle(Vector2New(X + dx, Y - dy))
					CreatePixelForCircle(Vector2New(X - dx, Y - dy))
					CreatePixelForCircle(Vector2New(X + dy, Y + dx))
					CreatePixelForCircle(Vector2New(X - dy, Y + dx))
					CreatePixelForCircle(Vector2New(X + dy, Y - dx))
					CreatePixelForCircle(Vector2New(X - dy, Y - dx))

					dy = dy + 1
					if err < 0 then
						err = err + 2 * dy + 1
					else
						dx, err = dx - 1, err + 2 * (dy - dx) + 1
					end
				end
			end

			return PointsArray
		end

		function Canvas:DrawCircleXY(X: number, Y: number, Radius: number, Colour: Color3, Fill: boolean)
			if X + Radius > self.CurrentResX or Y + Radius > self.CurrentResY or X - Radius < 1 or Y - Radius < 1 then
				OutputWarn("CircleXY cannot exceed bounds! Drawing cancelled.")
				return
			end

			-- Draw the circle
			local dx, dy, err = Radius, 0, 1 - Radius

			local function CreatePixelForCircle(DrawX, DrawY)
				InternalCanvas:SetPixel(DrawX, DrawY, Colour)
			end

			local function CreateLineForCircle(EndX, StartX, Y)
				for DrawX = 0, EndX - StartX do
					InternalCanvas:SetPixel(StartX + DrawX, Y, Colour)
				end
			end

			if Fill or type(Fill) == "nil" then
				while dx >= dy do -- Filled circle
					CreateLineForCircle(X + dx, X - dx, Y + dy)
					CreateLineForCircle(X + dx, X - dx, Y - dy)
					CreateLineForCircle(X + dy, X - dy, Y + dx)
					CreateLineForCircle(X + dy, X - dy, Y - dx)

					dy = dy + 1
					if err < 0 then
						err = err + 2 * dy + 1
					else
						dx, err = dx - 1, err + 2 * (dy - dx) + 1
					end
				end
			else
				while dx >= dy do -- Circle outline
					CreatePixelForCircle(X + dx, Y + dy)
					CreatePixelForCircle(X - dx, Y + dy)
					CreatePixelForCircle(X + dx, Y - dy)
					CreatePixelForCircle(X - dx, Y - dy)
					CreatePixelForCircle(X + dy, Y + dx)
					CreatePixelForCircle(X - dy, Y + dx)
					CreatePixelForCircle(X + dy, Y - dx)
					CreatePixelForCircle(X - dy, Y - dx)

					dy = dy + 1
					if err < 0 then
						err = err + 2 * dy + 1
					else
						dx, err = dx - 1, err + 2 * (dy - dx) + 1
					end
				end
			end
		end

		function Canvas:DrawRectangle(PointA: Vector2, PointB: Vector2, Colour: Color3, Fill: boolean?)
			local ReturnPoints = {}

			PointA = RoundPoint(PointA)
			PointB = RoundPoint(PointB)

			local X1, Y1 = PointA.X, PointA.Y
			local X2, Y2 = PointB.X, PointB.Y

			if Y2 < Y1 then
				Y1, Y2 = Swap(Y1, Y2)
			end

			if X2 < X1 then
				X1, X2 = Swap(X1, X2)
			end

			-- Clipped coordinates
			local StartX = math.max(X1, 1)
			local StartY = math.max(Y1, 1)

			local RangeX = math.abs(X2 - X1) + X1
			local RangeY = math.abs(Y2 - Y1) + Y1

			RangeX = math.min(RangeX, self.CurrentResX)
			RangeY = math.min(RangeY, self.CurrentResY)

			local function InsertPoints(...)
				local PointsTable = {...}
				for i, Table in ipairs(PointsTable) do
					for i, Point in ipairs(Table) do
						table.insert(ReturnPoints, Point)
					end
				end
			end

			if Fill or type(Fill) == "nil" then
				-- Fill every pixel
				for PlotX = StartX, RangeX do
					for PlotY = StartY, RangeY do
						InternalCanvas:SetPixel(PlotX, PlotY, Colour)
						table.insert(ReturnPoints, Vector2.new(PlotX, PlotY))
					end
				end
			else
				-- Just draw the outlines (using solid rectangles)
				local TopLine = Canvas:DrawRectangle(Vector2New(X1, Y1), Vector2New(X2, Y1), Colour, true)
				local BottomLine = Canvas:DrawRectangle(Vector2New(X1, Y2), Vector2New(X2, Y2), Colour, true)

				local LeftLine = Canvas:DrawRectangle(Vector2New(X1, Y1), Vector2New(X1, Y2), Colour, true)
				local RightLine = Canvas:DrawRectangle(Vector2New(X2, Y1), Vector2New(X2, Y2), Colour, true)

				InsertPoints(TopLine, BottomLine, LeftLine, RightLine)
			end

			return ReturnPoints
		end

		function Canvas:DrawRectangleXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Fill: boolean?)
			if Y2 < Y1 then
				Y1, Y2 = Swap(Y1, Y2)
			end

			if X2 < X1 then
				X1, X2 = Swap(X1, X2)
			end

			-- Clipped coordinates
			local StartX = math.max(X1, 1)
			local StartY = math.max(Y1, 1)

			local RangeX = math.abs(X2 - X1) + X1
			local RangeY = math.abs(Y2 - Y1) + Y1

			RangeX = math.min(RangeX, self.CurrentResX)
			RangeY = math.min(RangeY, self.CurrentResY)

			if Fill or type(Fill) == "nil" then
				-- Fill every pixel
				for PlotX = StartX, RangeX do
					for PlotY = StartY, RangeY do
						InternalCanvas:SetPixel(PlotX, PlotY, Colour)
					end
				end
			else
				-- Just draw the outlines (using solid rectangles)
				Canvas:DrawRectangleXY(X1, Y1, X2, Y1, Colour, true)
				Canvas:DrawRectangleXY(X1, Y2, X2, Y2, Colour, true)

				Canvas:DrawRectangleXY(X1, Y1, X1, Y2, Colour, true)
				Canvas:DrawRectangleXY(X2, Y1, X2, Y2, Colour, true)
			end
		end

		function Canvas:DrawTriangle(PointA: Vector2, PointB: Vector2, PointC: Vector2, Colour: Color3, Fill: boolean?): {}
			local ReturnPoints = {}

			if typeof(Fill) == "nil" or Fill == true then
				local X1 = PointA.X
				local X2 = PointB.X
				local X3 = PointC.X
				local Y1 = PointA.Y
				local Y2 = PointB.Y
				local Y3 = PointC.Y

				local CurrentY1 = Y1
				local CurrentY2 = Y2
				local CurrentY3 = Y3

				local CurrentX1 = X1
				local CurrentX2 = X2
				local CurrentX3 = X3

				-- Sort the vertices based on Y ascending
				if Y2 < Y1 then
					Y1, Y2 = Swap(Y1, Y2)
					X1, X2 = Swap(X1, X2)
				end

				if Y3 < Y1 then
					Y1, Y3 = Swap(Y1, Y3)
					X1, X3 = Swap(X1, X3)
				end

				if Y3 < Y2 then
					Y2, Y3 = Swap(Y2, Y3)
					X2, X3 = Swap(X2, X3)
				end

				local function PlotLine(StartX, EndX, Y)
					for X = 1, EndX - StartX do
						local Point = Vector2New(StartX + X, Y)
						self:DrawPixel(Point, Colour)

						TableInsert(ReturnPoints, Point)
					end
				end

				local function DrawBottomFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3) 
			--[[
				TriX1, TriY1 - Triangle top point
				TriX2, TriY2 - Triangle bottom left corner
				TriX3, TriY3 - Triangle bottom right corner
			]]
					local invslope1 = (TriX2 - TriX1) / (TriY2 - TriY1)
					local invslope2 = (TriX3 - TriX1) / (TriY3 - TriY1)

					local curx1 = TriX1
					local curx2 = TriX1

					for Y = 0, TriY3 - TriY1 do
						local DrawY = TriY1 + Y
						PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
						curx1 += invslope1
						curx2 += invslope2
					end
				end

				local function DrawTopFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3)	
			--[[
				TriX1, TriY1 - Triangle top left corner
				TriX2, TriY2 - Triangle top right corner
				TriX3, TriY3 - Triangle bottom point
			]]
					local invslope1 = (TriX3 - TriX1) / (TriY3 - TriY1)
					local invslope2 = (TriX3 - TriX2) / (TriY3 - TriY2)

					local curx1 = TriX3
					local curx2 = TriX3

					for Y = 0, TriY3 - TriY1 do
						local DrawY = TriY3 - Y
						PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
						curx1 -= invslope1
						curx2 -= invslope2
					end
				end

				local TriMidX = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

				if TriMidX < X2 then
					DrawBottomFlatTriangle(X1, Y1, TriMidX, Y2, X2, Y2)
					DrawTopFlatTriangle(TriMidX, Y2, X2, Y2, X3, Y3)
				else
					DrawBottomFlatTriangle(X1, Y1, X2, Y2, TriMidX, Y2)
					DrawTopFlatTriangle(X2, Y2, TriMidX, Y2, X3, Y3)
				end
			end

			local LineA = self:DrawLine(PointA, PointB, Colour)
			local LineB = self:DrawLine(PointB, PointC, Colour)
			local LineC = self:DrawLine(PointC, PointA, Colour)

			for Point in pairs(LineA) do
				TableInsert(ReturnPoints, Point)
			end
			for Point in pairs(LineB) do
				TableInsert(ReturnPoints, Point)
			end
			for Point in pairs(LineC) do
				TableInsert(ReturnPoints, Point)
			end

			return ReturnPoints
		end


		function Canvas:DrawTriangleXY(X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number, Colour: Color, Fill: boolean?)
			if Fill or typeof(Fill) == "nil" then

				local function CheckPoint(X, Y)
					if X < 1 or Y < 1 or X > self.CurrentResX or Y > self.CurrentResY then
						return true
					end
				end

				if CheckPoint(X1, Y1) or CheckPoint(X2, Y2) or CheckPoint(X3, Y3) then
					OutputWarn("DrawTriangle (XY) Error: This drawing method doesn't have clipping (Points exceed bounds) Canceling...")
					return
				end

				-- Sort the vertices based on Y ascending
				if Y2 < Y1 then
					Y1, Y2 = Swap(Y1, Y2)
					X1, X2 = Swap(X1, X2)
				end

				if Y3 < Y1 then
					Y1, Y3 = Swap(Y1, Y3)
					X1, X3 = Swap(X1, X3)
				end

				if Y3 < Y2 then
					Y2, Y3 = Swap(Y2, Y3)
					X2, X3 = Swap(X2, X3)
				end

				local function PlotLine(StartX, EndX, Y)
					for X = 1, EndX - StartX do
						InternalCanvas:SetPixel(StartX + X, Y, Colour)
					end
				end

				local function DrawBottomFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3) 
			--[[
				TriX1, TriY1 - Triangle top point
				TriX2, TriY2 - Triangle bottom left corner
				TriX3, TriY3 - Triangle bottom right corner
			]]
					local invslope1 = (TriX2 - TriX1) / (TriY2 - TriY1)
					local invslope2 = (TriX3 - TriX1) / (TriY3 - TriY1)

					local curx1 = TriX1
					local curx2 = TriX1

					for Y = 0, TriY3 - TriY1 do
						local DrawY = TriY1 + Y
						PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
						curx1 += invslope1
						curx2 += invslope2
					end
				end

				local function DrawTopFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3)	
			--[[
				TriX1, TriY1 - Triangle top left corner
				TriX2, TriY2 - Triangle top right corner
				TriX3, TriY3 - Triangle bottom point
			]]
					local invslope1 = (TriX3 - TriX1) / (TriY3 - TriY1)
					local invslope2 = (TriX3 - TriX2) / (TriY3 - TriY2)

					local curx1 = TriX3
					local curx2 = TriX3

					for Y = 0, TriY3 - TriY1 do
						local DrawY = TriY3 - Y
						PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
						curx1 -= invslope1
						curx2 -= invslope2
					end
				end

				local TriMidX = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

				if TriMidX < X2 then
					DrawBottomFlatTriangle(X1, Y1, TriMidX, Y2, X2, Y2)
					DrawTopFlatTriangle(TriMidX, Y2, X2, Y2, X3, Y3)
				else
					DrawBottomFlatTriangle(X1, Y1, X2, Y2, TriMidX, Y2)
					DrawTopFlatTriangle(X2, Y2, TriMidX, Y2, X3, Y3)
				end
			end

			self:DrawLineXY(X1, Y1, X2, Y2, Colour)
			self:DrawLineXY(X2, Y2, X3, Y3, Colour)
			self:DrawLineXY(X3, Y3, X1, Y1, Colour)
		end

		function Canvas:DrawTexturedTriangleXY(
			X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number,
			U1: number, V1: number, U2: number, V2: number, U3: number, V3: number,
			ImageData, Brightness: number?
		)
			local TexResX, TexResY = ImageData.ImageResolution.X, ImageData.ImageResolution.Y

			if Y2 < Y1 then
				Y1, Y2 = Swap(Y1, Y2)
				X1, X2 = Swap(X1, X2)
				U1, U2 = Swap(U1, U2)
				V1, V2 = Swap(V1, V2)
			end

			if Y3 < Y1 then
				Y1, Y3 = Swap(Y1, Y3)
				X1, X3 = Swap(X1, X3)
				U1, U3 = Swap(U1, U3)
				V1, V3 = Swap(V1, V3)
			end

			if Y3 < Y2 then
				Y2, Y3 = Swap(Y2, Y3)
				X2, X3 = Swap(X2, X3)
				U2, U3 = Swap(U2, U3)
				V2, V3 = Swap(V2, V3)
			end

			if Y3 == Y1 then
				Y3 += 1
			end

			local dy1 = Y2 - Y1
			local dx1 = X2 - X1
			local dv1 = V2 - V1
			local du1 = U2 - U1

			local dy2 = Y3 - Y1
			local dx2 = X3 - X1
			local dv2 = V3 - V1
			local du2 = U3 - U1

			local TexU, TexV = 0, 0

			local dax_step, dbx_step = 0, 0
			local du1_step, dv1_step = 0, 0
			local du2_step, dv2_step = 0, 0

			dax_step = dx1 / math.abs(dy1)
			dbx_step = dx2 / math.abs(dy2)

			du1_step = du1 / math.abs(dy1)
			dv1_step = dv1 / math.abs(dy1)

			du2_step = du2 / math.abs(dy2)
			dv2_step = dv2 / math.abs(dy2)

			local function Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, Y, IsBot)
				if ax > bx then
					ax, bx = Swap(ax, bx)
					tex_su, tex_eu = Swap(tex_su, tex_eu)
					tex_sv, tex_ev = Swap(tex_sv, tex_ev)
				end

				TexU, TexV = tex_su, tex_sv

				local Step = 1 / (bx - ax)
				local t = 0

				if Step > 10000 then
					Step = 10000
				end

				local ScanlineLength = math.ceil(bx - ax)

				-- Clip X right
				if bx > self.CurrentResX then
					ScanlineLength = self.CurrentResX - ax
				end

				-- Clip X left
				local StartOffsetX = 0

				if ax < 1 then	
					StartOffsetX = -(ax - 1)
					t = Step * StartOffsetX
				end

				for j = StartOffsetX, ScanlineLength do
					TexU = Lerp(tex_su, tex_eu, t)
					TexV = Lerp(tex_sv, tex_ev, t)

					local SampleX = math.min(math.floor(TexU * TexResX + 1), TexResX)
					local SampleY = math.min(math.floor(TexV * TexResY + 1), TexResY)

					local SampleColour, SampleAlpha = ImageData:GetPixelXY(SampleX, SampleY)

					if SampleColour and SampleAlpha > 1 then
						if not Brightness or Brightness == 1 then
							InternalCanvas:SetPixel(ax + j, Y, SampleColour)
						else
							local R, G, B = SampleColour.R, SampleColour.G, SampleColour.B
							R *= Brightness
							G *= Brightness
							B *= Brightness

							InternalCanvas:SetPixel(ax + j, Y, Color3.new(R, G, B))
						end
					end

					t += Step
				end

			end

			-- Clip Y top
			local YStart = 1

			if Y1 < 1 then
				YStart = 1 - Y1
			end

			-- Clip Y bottom
			local TopYDist = math.min(Y2 - Y1 - 1, self.CurrentResY - Y1)

			-- Draw top triangle
			for i = YStart, TopYDist do
				--task.wait(1)
				local ax = math.round(X1 + i * dax_step)
				local bx = math.round(X1 + i * dbx_step)

				-- Start values
				local tex_su = U1 + i * du1_step
				local tex_sv = V1 + i * dv1_step

				-- End values
				local tex_eu = U1 + i * du2_step
				local tex_ev = V1 + i * dv2_step

				-- Scan line
				Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, Y1 + i)
			end

			dy1 = Y3 - Y2
			dx1 = X3 - X2
			dv1 = V3 - V2
			du1 = U3 - U2

			dax_step = dx1 / math.abs(dy1)
			dbx_step = dx2 / math.abs(dy2)

			du1_step, dv1_step = 0, 0

			du1_step = du1 / math.abs(dy1)
			dv1_step = dv1 / math.abs(dy1)

			-- Draw bottom triangle

			-- Clip Y bottom
			local BottomYDist = math.min(Y3 - 1 - Y2, self.CurrentResY - Y2)

			local YStart = 0

			if Y2 < 1 then
				YStart = 1 - Y2
			end

			for i = YStart, BottomYDist do
				i = Y2 + i
				--task.wait(1)
				local ax = math.round(X2 + (i - Y2) * dax_step)
				local bx = math.round(X1 + (i - Y1) * dbx_step)

				-- Start values
				local tex_su = U2 + (i - Y2) * du1_step
				local tex_sv = V2 + (i - Y2) * dv1_step

				-- End values
				local tex_eu = U1 + (i - Y1) * du2_step
				local tex_ev = V1 + (i - Y1) * dv2_step

				Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, i, true)
			end
		end

		function Canvas:DrawTexturedTriangle(
			PointA: Vector2, PointB: Vector2, PointC: Vector2, 
			UV1: Vector2, UV2: Vector2, UV3: Vector2, 
			ImageData, Brightness: number?
		)

			-- Convert to intergers
			local X1, X2, X3 = math.ceil(PointA.X), math.ceil(PointB.X), math.ceil(PointC.X)
			local Y1, Y2, Y3 = math.ceil(PointA.Y), math.ceil(PointB.Y), math.ceil(PointC.Y)

			Canvas:DrawTexturedTriangleXY(
				X1, Y1, X2, Y2, X3, Y3,
				UV1.X, UV1.Y, UV2.X, UV2.Y, UV3.X, UV3.Y,
				ImageData, Brightness
			)
		end

		function Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData, Brightness: number?)
			Canvas:DrawTexturedTriangleXY(
				X1, Y1, X2, Y2, X3, Y3,
				0, 0, 0, 1, 1, 1,
				ImageData, Brightness
			)
			Canvas:DrawTexturedTriangleXY(
				X1, Y1, X4, Y4, X3, Y3,
				0, 0, 1, 0, 1, 1,
				ImageData, Brightness
			)
		end

		function Canvas:DrawDistortedImage(PointA, PointB, PointC, PointD, ImageData, Brightness: number?)
			Canvas:DrawDistortedImageXY(
				PointA.X, PointA.Y, PointB.X, PointB.Y, PointC.X, PointC.Y, PointD.X, PointD.Y,
				ImageData, Brightness
			)
		end

		function Canvas:DrawLine(PointA: Vector2, PointB: Vector2, Colour: Color3, Thickness: number?): {}
			local DrawnPointsArray = {}

			if not Thickness or Thickness < 1 then
				DrawnPointsArray = {PointA}

				local X1 = RoundN(PointA.X)
				local X2 = RoundN(PointB.X)
				local Y1 = RoundN(PointA.Y)
				local Y2 = RoundN(PointB.Y)

				local sx, sy, dx, dy

				if X1 < X2 then
					sx = 1
					dx = X2 - X1
				else
					sx = -1
					dx = X1 - X2
				end

				if Y1 < Y2 then
					sy = 1
					dy = Y2 - Y1
				else
					sy = -1
					dy = Y1 - Y2
				end

				local err, e2 = dx-dy, nil

				while not (X1 == X2 and Y1 == Y2) do
					e2 = err + err
					if e2 > -dy then
						err = err - dy
						X1  = X1 + sx
					end
					if e2 < dx then
						err = err + dx
						Y1 = Y1 + sy
					end

					local Point = Vector2New(X1, Y1)
					self:DrawPixel(Point, Colour)
					TableInsert(DrawnPointsArray, Point)
				end

				self:DrawPixel(PointA, Colour)

				return DrawnPointsArray
			else -- Custom polygon based thick line
				local X1, Y1 = PointA.X, PointA.Y
				local X2, Y2 = PointB.X, PointB.Y

				local RawRot = math.atan2(PointA.X - PointB.X, PointA.Y - PointB.Y) -- Use distances between each axis
				local Theta = RawRot

				local PiHalf = math.pi / 2

				-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
				if RawRot < 0 then
					Theta = math.pi * 2 + RawRot
				end

				local Diameter = 1 + (Thickness * 2)
				local Rounder = (math.pi * 1.5) / Diameter

				Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points

				-- Start polygon points
				local StartCornerX1 = math.floor(X1 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
				local StartCornerY1 = math.floor(Y1 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

				local StartCornerX2 = math.floor(X1 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
				local StartCornerY2 = math.floor(Y1 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

				-- End polygon points
				local EndCornerX1 = math.floor(X2 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
				local EndCornerY1 = math.floor(Y2 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

				local EndCornerX2 = math.floor(X2 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
				local EndCornerY2 = math.floor(Y2 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

				-- Draw 2 triangles at the start and end corners
				local TrianglePointsA = Canvas:DrawTriangle(Vector2New(StartCornerX1, StartCornerY1), Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Colour)
				local TrianglePointsB = Canvas:DrawTriangle(Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Vector2New(EndCornerX2, EndCornerY2), Colour)

				-- Draw rounded caps
				local CirclePointsA = Canvas:DrawCircle(PointA, Thickness, Colour)
				local CirclePointsB = Canvas:DrawCircle(PointB, Thickness, Colour)

				local function InsertContents(Table)
					for i, Item in ipairs(Table) do
						table.insert(DrawnPointsArray, Item)
					end
				end

				InsertContents(TrianglePointsA)
				InsertContents(TrianglePointsB)
				InsertContents(CirclePointsA)
				InsertContents(CirclePointsB)
			end

			return DrawnPointsArray
		end

		function Canvas:DrawLineXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Thickness: number?)
			if not Thickness or Thickness < 1 then -- Bresenham line
				local sx, sy, dx, dy

				if X1 < X2 then
					sx = 1
					dx = X2 - X1
				else
					sx = -1
					dx = X1 - X2
				end

				if Y1 < Y2 then
					sy = 1
					dy = Y2 - Y1
				else
					sy = -1
					dy = Y1 - Y2
				end

				local err, e2 = dx-dy, nil

				while not(X1 == X2 and Y1 == Y2) do
					e2 = err + err
					if e2 > -dy then
						err = err - dy
						X1  = X1 + sx
					end
					if e2 < dx then
						err = err + dx
						Y1 = Y1 + sy
					end
					InternalCanvas:SetPixel(X1, Y1, Colour)
				end
			else -- Custom polygon based thick line
				local RawRot = math.atan2(X1 - X2, Y1 - Y2) -- Use distances between each axis
				local Theta = RawRot

				local PiHalf = math.pi / 2

				-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
				if RawRot < 0 then
					Theta = math.pi * 2 + RawRot
				end

				local Diameter = 1 + (Thickness * 2)
				local Rounder = (math.pi * 1.5) / Diameter

				Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points

				-- Start polygon points
				local StartCornerX1 = math.floor(X1 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
				local StartCornerY1 = math.floor(Y1 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

				local StartCornerX2 = math.floor(X1 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
				local StartCornerY2 = math.floor(Y1 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

				-- End polygon points
				local EndCornerX1 = math.floor(X2 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
				local EndCornerY1 = math.floor(Y2 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

				local EndCornerX2 = math.floor(X2 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
				local EndCornerY2 = math.floor(Y2 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

				-- Draw 2 triangles at the start and end corners
				Canvas:DrawTriangleXY(StartCornerX1, StartCornerY1, StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, Colour)
				Canvas:DrawTriangleXY(StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, EndCornerX2, EndCornerY2, Colour)

				-- Draw rounded caps
				Canvas:DrawCircleXY(X1, Y1, Thickness, Colour)
				Canvas:DrawCircleXY(X2, Y2, Thickness, Colour)
			end

		end

		function Canvas:DrawTextXY(Text: string, X: number, Y: number, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
			if not Spacing then
				Spacing = 1
			end

			if not Scale then
				Scale = 1
			end

			Scale = math.clamp(math.round(Scale), 1, 50)

			local CharWidth = 3 * Scale
			local CharHeight = 5 * Scale

			local TextLines = string.split(Text, "\n")

			for i, TextLine in pairs(TextLines) do
				local Characters = string.split(TextLine, "")

				local OffsetX = 0
				local OffsetY = (i - 1) * (CharHeight + Spacing)

				for i, Character in pairs(Characters) do
					local TextCharacter = PixelTextCharacters[Character:lower()]

					if TextCharacter then
						local StartOffsetX = -(math.min(1, X + OffsetX) - 1) + 1
						local StartOffsetY = -(math.min(1, Y + OffsetY) - 1) + 1

						if OffsetX + CharWidth > self.CurrentResX - X + 1 then
							if Wrap or type(Wrap) == "nil" then
								OffsetY += CharHeight + Spacing
								OffsetX = 0
							else
								break -- Don't write anymore text since it's outside the canvas
							end
						end

						for SampleY = StartOffsetY, CharHeight do
							local PlacementY = Y + SampleY - 1 + OffsetY
							SampleY = math.ceil(SampleY / Scale)

							if PlacementY - 1 >= self.CurrentResY then
								break
							end

							for SampleX = StartOffsetX, CharWidth do
								local PlacementX = X + SampleX - 1 + OffsetX

								if PlacementX > self.CurrentResX or PlacementX < 1 then
									continue
								end

								SampleX = math.ceil(SampleX / Scale)

								local Fill = TextCharacter[SampleY][SampleX]
								if Fill == 1 then
									InternalCanvas:SetPixel(PlacementX, PlacementY, Colour)
								end
							end
						end
					end

					OffsetX += CharWidth + Spacing
				end
			end
		end

		function Canvas:DrawText(Text: string, Point: Vector2, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
			Point = RoundPoint(Point)
			Canvas:DrawTextXY(Text, Point.X, Point.Y, Colour, Scale, Wrap, Spacing)
		end


		return Canvas
	end


	--============================================================================================================--
	--====  <<   CanvasDraw Module ImageData API   >>   ===========================================================--
	--============================================================================================================--

	function CanvasDraw.GetImageData(SaveObject: Instance)
		local SaveDataImageColours = SaveObject:GetAttribute("ImageColours")
		local SaveDataImageAlphas = SaveObject:GetAttribute("ImageAlphas")
		local SaveDataImageResolution = SaveObject:GetAttribute("ImageResolution")

		-- Decompress the data
		local DecompressedSaveDataImageColours = StringCompressor.Decompress(SaveDataImageColours)
		local DecompressedSaveDataImageAlphas = StringCompressor.Decompress(SaveDataImageAlphas)

		-- Get a single pixel colour info form the data
		local PixelDataColoursString = string.split(DecompressedSaveDataImageColours, "S")
		local PixelDataAlphasString = string.split(DecompressedSaveDataImageAlphas, "S")

		local PixelColours = {}
		local OrigColours = {}
		local PixelAlphas = {}

		for i, PixelColourString in pairs(PixelDataColoursString) do
			local RGBValues = string.split(PixelColourString, ",")
			local PixelColour = Color3.fromRGB(table.unpack(RGBValues))

			local PixelAlpha = tonumber(PixelDataAlphasString[i])

			TableInsert(PixelColours, PixelColour)
			TableInsert(OrigColours, PixelColour)
			TableInsert(PixelAlphas, PixelAlpha)
		end

		-- Convert the SaveObject into image data
		local ImageData = {ImageColours = PixelColours, ImageAlphas = PixelAlphas, ImageResolution = SaveDataImageResolution}
		local ImageDataResX = SaveDataImageResolution.X
		local ImageDataResY = SaveDataImageResolution.Y


		--== ImageData methods ==--

		function ImageData:GetPixel(Point: Vector2): (Color3, number)
			local X, Y = math.ceil(Point.X), math.ceil(Point.Y)
			local Index = XYToPixelIndex(X, Y, ImageDataResX)

			return PixelColours[Index], PixelAlphas[Index]
		end

		function ImageData:GetPixelXY(X: number, Y: number): (Color3, number)
			local Index = XYToPixelIndex(X, Y, ImageDataResX)

			return PixelColours[Index], PixelAlphas[Index]
		end

		function ImageData:Tint(Colour: Color3, T: number)
			for i, OriginalColour in ipairs(OrigColours) do
				PixelColours[i] = OriginalColour:Lerp(Colour, T)
			end
		end

		function ImageData:SetPixel(X: number, Y: number, Colour: Color3, Alpha: number?)
			local Index = XYToPixelIndex(X, Y, ImageDataResX)

			PixelColours[Index] = Colour
			if Alpha then
				PixelAlphas[Index] = Alpha
			end
		end

		return ImageData
	end

	function CanvasDraw.CreateSaveObject(ImageData, InstantCreate: boolean?): Folder
		if ImageData.ImageResolution.X > SaveObjectResolutionLimit.X and ImageData.ImageResolution.Y > SaveObjectResolutionLimit.Y then
			warn([[Failed to create an image save object (ImageData too large). 
		Please try to keep the resolution of the image no higher than ']] .. SaveObjectResolutionLimit.X .. " x " .. SaveObjectResolutionLimit.Y .. "'.")
			return
		end

		local FastWaitCount = 0

		local function FastWait(Count) -- Avoid lag spikes
			if FastWaitCount >= Count then
				FastWaitCount = 0
				RunService.Heartbeat:Wait()
			else
				FastWaitCount += 1
			end
		end

		local function ConvertColoursToListString(Colours)
			local ColourData = {}
			local RgbStringFormat = "%d,%d,%d"

			for i, Colour in ipairs(Colours) do
				local R, G, B = RoundN(Colour.R * 255), RoundN(Colour.G * 255), RoundN(Colour.B * 255)
				TableInsert(ColourData, RgbStringFormat:format(R, G, B))

				if not InstantCreate then
					FastWait(4000)
				end
			end

			return table.concat(ColourData, "S")
		end

		local function ConvertAlphasToListString(Alphas)	
			local AlphasListString = table.concat(Alphas, "S")
			return AlphasListString
		end

		local ImageColoursString = ConvertColoursToListString(ImageData.ImageColours)
		local ImageAlphasString = ConvertAlphasToListString(ImageData.ImageAlphas)

		local CompressedImageColoursString = StringCompressor.Compress(ImageColoursString)
		local CompressedImageAlphasString = StringCompressor.Compress(ImageAlphasString)

		local NewSaveObject = Instance.new("Folder")
		NewSaveObject.Name = "NewSave"

		NewSaveObject:SetAttribute("ImageColours", CompressedImageColoursString)
		NewSaveObject:SetAttribute("ImageAlphas", CompressedImageAlphasString)
		NewSaveObject:SetAttribute("ImageResolution", ImageData.ImageResolution)

		return NewSaveObject
	end


	--== DEPRECATED FUNCTIONS/METHODS ==--

	-- (!) Use ImageData:GetPixel() instead
	function CanvasDraw.GetPixelFromImage(ImageData, Point: Vector2): (Color3, number)
		local PixelIndex = PointToPixelIndex(Point, ImageData.ImageResolution) -- Convert the point into an index for the array of colours

		local PixelColour = ImageData.ImageColours[PixelIndex]
		local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

		return PixelColour, PixelAlpha
	end

	-- (!) Use ImageData:GetPixelXY() instead
	function CanvasDraw.GetPixelFromImageXY(ImageData, X: number, Y: number): (Color3, number)
		local PixelIndex = XYToPixelIndex(X, Y, ImageData.ImageResolution.X) -- Convert the coordinates into an index for the array of colours

		local PixelColour = ImageData.ImageColours[PixelIndex]
		local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

		return PixelColour, PixelAlpha
	end

	return CanvasDraw
end)()

-- @original: https://gist.github.com/Reselim/40d62b17d138cc74335a1b0709e19ce2
local Alphabet = {}
local Indexes = {}

-- A-Z
for Index = 65, 90 do
	table.insert(Alphabet, Index)
end

-- a-z
for Index = 97, 122 do
	table.insert(Alphabet, Index)
end

-- 0-9
for Index = 48, 57 do
	table.insert(Alphabet, Index)
end

table.insert(Alphabet, 43) -- +
table.insert(Alphabet, 47) -- /

for Index, Character in ipairs(Alphabet) do
	Indexes[Character] = Index
end

local Base64 = {}

local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift
local bit32_band = bit32.band

--[[**
	Encodes a string in Base64.
	@param [t:string] Input The input string to encode.
	@returns [t:string] The string encoded in Base64.
**--]]
function Base64.Encode(Input)
	local Output = {}
	local Length = 0

	for Index = 1, #Input, 3 do
		local C1, C2, C3 = string.byte(Input, Index, Index + 2)

		local A = bit32_rshift(C1, 2)
		local B = bit32_lshift(bit32_band(C1, 3), 4) + bit32_rshift(C2 or 0, 4)
		local C = bit32_lshift(bit32_band(C2 or 0, 15), 2) + bit32_rshift(C3 or 0, 6)
		local D = bit32_band(C3 or 0, 63)

		Length = Length + 1
		Output[Length] = Alphabet[A + 1]

		Length = Length + 1
		Output[Length] = Alphabet[B + 1]

		Length = Length + 1
		Output[Length] = C2 and Alphabet[C + 1] or 61

		Length = Length + 1
		Output[Length] = C3 and Alphabet[D + 1] or 61
	end

	local NewOutput = {}
	local NewLength = 0
	local IndexAdd4096Sub1

	for Index = 1, Length, 4096 do
		NewLength = NewLength + 1
		IndexAdd4096Sub1 = Index + 4096 - 1

		NewOutput[NewLength] = string.char(table.unpack(
			Output,
			Index,
			IndexAdd4096Sub1 > Length and Length or IndexAdd4096Sub1
			))
	end

	return table.concat(NewOutput)
end

--[[**
	Decodes a string from Base64.
	@param [t:string] Input The input string to decode.
	@returns [t:string] The newly decoded string.
**--]]
function Base64.Decode(Input)
	local Output = {}
	local Length = 0

	for Index = 1, #Input, 4 do
		local C1, C2, C3, C4 = string.byte(Input, Index, Index + 3)

		local I1 = Indexes[C1] - 1
		local I2 = Indexes[C2] - 1
		local I3 = (Indexes[C3] or 1) - 1
		local I4 = (Indexes[C4] or 1) - 1

		local A = bit32_lshift(I1, 2) + bit32_rshift(I2, 4)
		local B = bit32_lshift(bit32_band(I2, 15), 4) + bit32_rshift(I3, 2)
		local C = bit32_lshift(bit32_band(I3, 3), 6) + I4

		Length = Length + 1
		Output[Length] = A

		if C3 ~= 61 then
			Length = Length + 1
			Output[Length] = B
		end

		if C4 ~= 61 then
			Length = Length + 1
			Output[Length] = C
		end
	end

	local NewOutput = {}
	local NewLength = 0
	local IndexAdd4096Sub1

	for Index = 1, Length, 4096 do
		NewLength = NewLength + 1
		IndexAdd4096Sub1 = Index + 4096 - 1

		NewOutput[NewLength] = string.char(table.unpack(
			Output,
			Index,
			IndexAdd4096Sub1 > Length and Length or IndexAdd4096Sub1
			))
	end

	return table.concat(NewOutput)
end

local Projectile = (function()
	local GravityForce = Vector3.yAxis * -workspace.Gravity
	workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
		GravityForce = Vector3.yAxis * -workspace.Gravity
	end)

	local Rendering = {}
	game:GetService("RunService").Heartbeat:Connect(function(DeltaTime)
		for _, Projectile in ipairs(Rendering) do
			Projectile.Elapsed += DeltaTime

			local LastStep = Projectile.CurrentPosition
			local NextStep = Projectile.Origin + Projectile.Velocity * Projectile.Elapsed + 0.5 * GravityForce * (Projectile.Elapsed ^ 2)
			local Diff = LastStep - NextStep

			local Part = Projectile.Part
			if Part then
				Part.Position = NextStep
			end

			Projectile.CurrentPosition = NextStep
			Projectile.CurrentVelocity = Diff

			if Projectile.Step then
				Projectile.Step(Projectile, DeltaTime)
			end
			if Projectile.Touched then
				local HitCast = workspace:Raycast(LastStep, Diff, Projectile.Params)
				if HitCast then
					Projectile.Touched(Projectile, HitCast)
				end
			end
		end
	end)

	return function(Data)
		Data.Elapsed = 0
		Data.CurrentPosition = Data.Origin
		Data.CurrentVelocity = Data.Velocity
		local ID = #Rendering + 1
		function Data:StopRender()
			Rendering[ID] = nil
		end
		function Data:Destroy()
			self:StopRender()
			if Data.Removing then
				Data.Removing(Data)
			end
			if Data.Part then
				Data.Part:Destroy()
			end
		end
		table.insert(Rendering, Data)
	end
end)()

local XML = (function()
--- @module Module providing a non-validating XML stream parser in Lua.
--
--  Features:
--  =========
--
--      * Tokenises well-formed XML (relatively robustly)
--      * Flexible handler based event API (see below)
--      * Parses all XML Infoset elements - ie.
--          - Tags
--          - Text
--          - Comments
--          - CDATA
--          - XML Decl
--          - Processing Instructions
--          - DOCTYPE declarations
--      * Provides limited well-formedness checking
--        (checks for basic syntax & balanced tags only)
--      * Flexible whitespace handling (selectable)
--      * Entity Handling (selectable)
--
--  Limitations:
--  ============
--
--      * Non-validating
--      * No charset handling
--      * No namespace support
--      * Shallow well-formedness checking only (fails
--        to detect most semantic errors)
--
--  API:
--  ====
--
--  The parser provides a partially object-oriented API with
--  functionality split into tokeniser and handler components.
--
--  The handler instance is passed to the tokeniser and receives
--  callbacks for each XML element processed (if a suitable handler
--  function is defined). The API is conceptually similar to the
--  SAX API but implemented differently.
--
--  XML data is passed to the parser instance through the 'parse'
--  method (Note: must be passed a single string currently)
--
--  License:
--  ========
--
--      This code is freely distributable under the terms of the [MIT license](LICENSE).
--
--
--@author Paul Chakravarti (paulc@passtheaardvark.com)
--@author Manoel Campos da Silva Filho
local xml2lua = { _VERSION = "1.6-1" }
local XmlParser = (function()
	--- @module Class providing the actual XML parser.
	--  Available options are:
	--      * stripWS   
	--        Strip non-significant whitespace (leading/trailing) 
	--        and do not generate events for empty text elements
	--  
	--      * expandEntities 
	--        Expand entities (standard entities + single char 
	--        numeric entities only currently - could be extended 
	--        at runtime if suitable DTD parser added elements
	--        to table (see obj._ENTITIES). May also be possible
	--        to expand multibyre entities for UTF-8 only
	--  
	--      * errorHandler
	--        Custom error handler function 
	--
	--  NOTE: Boolean options must be set to 'nil' not '0'

	---Converts the decimal code of a character to its corresponding char
	--if it's a graphical char, otherwise, returns the HTML ISO code
	--for that decimal value in the format &#code
	--@param code the decimal value to convert to its respective character
	local function decimalToHtmlChar(code)
		local num = tonumber(code)
		if num >= 0 and num < 256 then
			return string.char(num)
		end

		return "&#"..code..";"
	end

	---Converts the hexadecimal code of a character to its corresponding char
	--if it's a graphical char, otherwise, returns the HTML ISO code
	--for that hexadecimal value in the format &#xCode
	--@param code the hexadecimal value to convert to its respective character
	local function hexadecimalToHtmlChar(code)
		local num = tonumber(code, 16)
		if num >= 0 and num < 256 then
			return string.char(num)
		end

		return "&#x"..code..";"
	end

	local XmlParser = {
		-- Private attributes/functions
		_XML        = '^([^<]*)<(%/?)([^>]-)(%/?)>',
		_ATTR1      = '([%w-:_]+)%s*=%s*"(.-)"',
		_ATTR2      = '([%w-:_]+)%s*=%s*\'(.-)\'',
		_CDATA      = '<%!%[CDATA%[(.-)%]%]>',
		_PI         = '<%?(.-)%?>',
		_COMMENT    = '<!%-%-(.-)%-%->',
		_TAG        = '^(.-)%s.*',
		_LEADINGWS  = '^%s+',
		_TRAILINGWS = '%s+$',
		_WS         = '^%s*$',
		_DTD1       = '<!DOCTYPE%s+(.-)%s+(SYSTEM)%s+["\'](.-)["\']%s*(%b[])%s*>',
		_DTD2       = '<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+["\'](.-)["\']%s+["\'](.-)["\']%s*(%b[])%s*>',
		_DTD3       = '<!DOCTYPE%s+(.-)%s+%[%s+.-%]>', -- Inline DTD Schema
		_DTD4       = '<!DOCTYPE%s+(.-)%s+(SYSTEM)%s+["\'](.-)["\']%s*>',
		_DTD5       = '<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+["\'](.-)["\']%s+["\'](.-)["\']%s*>',
		_DTD6       = '<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+["\'](.-)["\']%s*>',

		--Matches an attribute with non-closing double quotes (The equal sign is matched non-greedly by using =+?)
		_ATTRERR1   = '=+?%s*"[^"]*$',
		--Matches an attribute with non-closing single quotes (The equal sign is matched non-greedly by using =+?)
		_ATTRERR2   = '=+?%s*\'[^\']*$',
		--Matches a closing tag such as </person> or the end of a openning tag such as <person>
		_TAGEXT     = '(%/?)>',

		_errstr = { 
			xmlErr = "Error Parsing XML",
			declErr = "Error Parsing XMLDecl",
			declStartErr = "XMLDecl not at start of document",
			declAttrErr = "Invalid XMLDecl attributes",
			piErr = "Error Parsing Processing Instruction",
			commentErr = "Error Parsing Comment",
			cdataErr = "Error Parsing CDATA",
			dtdErr = "Error Parsing DTD",
			endTagErr = "End Tag Attributes Invalid",
			unmatchedTagErr = "Unbalanced Tag",
			incompleteXmlErr = "Incomplete XML Document",
		},

		_ENTITIES = { 
			["&lt;"] = "<",
			["&gt;"] = ">",
			["&amp;"] = "&",
			["&quot;"] = '"',
			["&apos;"] = "'",
			["&#(%d+);"] = decimalToHtmlChar,
			["&#x(%x+);"] = hexadecimalToHtmlChar,
		},
	}

	--- Instantiates a XmlParser object.
	--@param _handler Handler module to be used to convert the XML string
	--               to another formats. See the available handlers at the handler directory.
	--               Usually you get an instance to a handler module using, for instance:
	--               local handler = require("xmlhandler/tree").
	--@param _options Options for this XmlParser instance.
	--@see XmlParser.options

	local handlers = {
		["tree"] = (function()
			local function init()
				return {
					options = {commentNode=1, piNode=1, dtdNode=1, declNode=1},
					current = { _children = {}, _type = "ROOT" },
					_stack = {}
				}
			end

			--- @module Handler to generate a DOM-like node tree structure with
			--      a single ROOT node parent - each node is a table comprising
			--      the fields below.
			--
			--      node = { _name = <ELEMENT Name>,
			--              _type = ROOT|ELEMENT|TEXT|COMMENT|PI|DECL|DTD,
			--              _text = <TEXT or COMMENT string>,
			--              _attr = { Node attributes - see callback API },
			--              _parent = <Parent Node>,
			--              _children = { List of child nodes - ROOT/ELEMENT only }
			--            }
			--      where:
			--      - PI = XML Processing Instruction tag.
			--      - DECL = XML declaration tag
			--
			--      The dom structure is capable of representing any valid XML document
			--
			-- Options
			-- =======
			--    options.(comment|pi|dtd|decl)Node = bool
			--        - Include/exclude given node types
			--
			--  License:
			--  ========
			--
			--      This code is freely distributable under the terms of the [MIT license](LICENSE).
			--
			--@author Paul Chakravarti (paulc@passtheaardvark.com)
			--@author Manoel Campos da Silva Filho
			local dom = init()

			---Instantiates a new handler object.
			--Each instance can handle a single XML.
			--By using such a constructor, you can parse
			--multiple XML files in the same application.
			--@return the handler instance
			function dom:new()
				local obj = init()

				obj.__index = self
				setmetatable(obj, self)

				return obj
			end

			---Parses a start tag.
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:starttag(tag)
				local node = { _type = 'ELEMENT',
					_name = tag.name,
					_attr = tag.attrs,
					_children = {}
				}

				if not self.root then
					self.root = node
				end

				table.insert(self._stack, node)

				table.insert(self.current._children, node)
				self.current = node
			end

			---Parses an end tag.
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:endtag(tag)
				--Table representing the containing tag of the current tag
				local prev = self._stack[#self._stack]

				if tag.name ~= prev._name then
					error("XML Error - Unmatched Tag ["..s..":"..tag.name.."]\n")
				end

				table.remove(self._stack)
				self.current = self._stack[#self._stack]
				if not self.current then
					local node = { _children = {}, _type = "ROOT" }
					if self.decl then
						table.insert(node._children, self.decl)
						self.decl = nil
					end
					if self.dtd then
						table.insert(node._children, self.dtd)
						self.dtd = nil
					end
					if self.root then
						table.insert(node._children, self.root)
						self.root = node
					end
					self.current = node
				end
			end

			---Parses a tag content.
			-- @param text text to process
			function dom:text(text)
				local node = { _type = "TEXT",
					_text = text
				}
				table.insert(self.current._children, node)
			end

			---Parses a comment tag.
			-- @param text comment text
			function dom:comment(text)
				if self.options.commentNode then
					local node = { _type = "COMMENT",
						_text = text
					}
					table.insert(self.current._children, node)
				end
			end

			--- Parses a XML processing instruction (PI) tag
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:pi(tag)
				if self.options.piNode then
					local node = { _type = "PI",
						_name = tag.name,
						_attr = tag.attrs,
					}
					table.insert(self.current._children, node)
				end
			end

			---Parse the XML declaration line (the line that indicates the XML version).
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:decl(tag)
				if self.options.declNode then
					self.decl = { _type = "DECL",
						_name = tag.name,
						_attr = tag.attrs,
					}
				end
			end

			---Parses a DTD tag.
			-- @param tag a {name, value} table
			-- where name is the name of the tag and value
			-- is a table containing the attributes of the tag
			function dom:dtd(tag)
				if self.options.dtdNode then
					self.dtd = { _type = "DTD",
						_name = tag.name,
						_text = tag.value
					}
				end
			end

			--- XML escape characters for a TEXT node.
			-- @param s a string
			-- @return @p s XML escaped.
			local function xmlEscape(s)
				s = string.gsub(s, '&', '&amp;')
				s = string.gsub(s, '<', '&lt;')
				return string.gsub(s, '>', '&gt;')
			end

			--- return a string of XML attributes
			-- @param tab table with XML attribute pairs. key and value are supposed to be strings.
			-- @return a string.
			local function attrsToStr(tab)
				if not tab then
					return ''
				end
				if type(tab) == 'table' then
					local s = ''
					for n,v in pairs(tab) do
						-- determine a safe quote character
						local val = tostring(v)
						local found_single_quote = string.find(val, "'")
						local found_double_quote = string.find(val, '"')
						local quot = '"'
						if found_single_quote and found_double_quote then
							-- XML escape both quote characters
							val = string.gsub(val, '"', '&quot;')
							val = string.gsub(val, "'", '&apos;')
						elseif found_double_quote then
							quot = "'"
						end
						s = ' ' .. tostring(n) .. '=' .. quot .. val .. quot
					end
					return s
				end
				return 'BUG:unknown type:' .. type(tab)
			end

			--- return a XML formatted string of @p node.
			-- @param node a Node object (table) of the xml2lua DOM tree structure.
			-- @return a string.
			local function toXmlStr(node, indentLevel)
				if not node then
					return 'BUG:node==nil'
				end
				if not node._type then
					return 'BUG:node._type==nil'
				end

				local indent = ''
				for i=0, indentLevel+1, 1 do
					indent = indent .. ' '
				end

				if node._type == 'ROOT' then
					local s = ''
					for i, n in pairs(node._children) do
						s = s .. toXmlStr(n, indentLevel+2)
					end
					return s
				elseif node._type == 'ELEMENT' then
					local s = indent .. '<' .. node._name .. attrsToStr(node._attr)

					-- check if ELEMENT has no children
					if not node._children or
						#node._children == 0 then
						return s .. '/>\n'
					end

					s = s .. '>\n'

					for i, n in pairs(node._children) do
						local xx = toXmlStr(n, indentLevel+2)
						if not xx then
							print('BUG:xx==nil')
						else
							s = s .. xx
						end
					end

					return s .. indent .. '</' .. node._name .. '>\n'

				elseif node._type == 'TEXT' then
					return indent .. xmlEscape(node._text) .. '\n'
				elseif node._type == 'COMMENT' then
					return indent .. '<!--' .. node._text .. '-->\n'
				elseif node._type == 'PI' then
					return indent .. '<?' .. node._name .. ' ' .. node._attr._text .. '?>\n'
				elseif node._type == 'DECL' then
					return indent .. '<?' .. node._name .. attrsToStr(node._attr) .. '?>\n'
				elseif node._type == 'DTD' then
					return indent .. '<!' .. node._name .. ' ' .. node._text .. '>\n'
				end
				return 'BUG:unknown type:' .. tostring(node._type)
			end

			---create a string in XML format from the dom root object @p node.
			-- @param node a root object, typically created with `dom` XML parser handler.
			-- @return a string, XML formatted.
			function dom:toXml(node)
				return toXmlStr(node, -4)
			end

			---Parses CDATA tag content.
			dom.cdata = dom.text
			dom.__index = dom
			return dom
		end)(),
		["dom"] = (function()
			local function init()
				return {
					options = {commentNode=1, piNode=1, dtdNode=1, declNode=1},
					current = { _children = {}, _type = "ROOT" },
					_stack = {}
				}
			end

			--- @module Handler to generate a DOM-like node tree structure with
			--      a single ROOT node parent - each node is a table comprising
			--      the fields below.
			--
			--      node = { _name = <ELEMENT Name>,
			--              _type = ROOT|ELEMENT|TEXT|COMMENT|PI|DECL|DTD,
			--              _text = <TEXT or COMMENT string>,
			--              _attr = { Node attributes - see callback API },
			--              _parent = <Parent Node>,
			--              _children = { List of child nodes - ROOT/ELEMENT only }
			--            }
			--      where:
			--      - PI = XML Processing Instruction tag.
			--      - DECL = XML declaration tag
			--
			--      The dom structure is capable of representing any valid XML document
			--
			-- Options
			-- =======
			--    options.(comment|pi|dtd|decl)Node = bool
			--        - Include/exclude given node types
			--
			--  License:
			--  ========
			--
			--      This code is freely distributable under the terms of the [MIT license](LICENSE).
			--
			--@author Paul Chakravarti (paulc@passtheaardvark.com)
			--@author Manoel Campos da Silva Filho
			local dom = init()

			---Instantiates a new handler object.
			--Each instance can handle a single XML.
			--By using such a constructor, you can parse
			--multiple XML files in the same application.
			--@return the handler instance
			function dom:new()
				local obj = init()

				obj.__index = self
				setmetatable(obj, self)

				return obj
			end

			---Parses a start tag.
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:starttag(tag)
				local node = { _type = 'ELEMENT',
					_name = tag.name,
					_attr = tag.attrs,
					_children = {}
				}

				if not self.root then
					self.root = node
				end

				table.insert(self._stack, node)

				table.insert(self.current._children, node)
				self.current = node
			end

			---Parses an end tag.
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:endtag(tag)
				--Table representing the containing tag of the current tag
				local prev = self._stack[#self._stack]

				if tag.name ~= prev._name then
					error("XML Error - Unmatched Tag ["..tag.name.."]\n")
				end

				table.remove(self._stack)
				self.current = self._stack[#self._stack]
				if not self.current then
					local node = { _children = {}, _type = "ROOT" }
					if self.decl then
						table.insert(node._children, self.decl)
						self.decl = nil
					end
					if self.dtd then
						table.insert(node._children, self.dtd)
						self.dtd = nil
					end
					if self.root then
						table.insert(node._children, self.root)
						self.root = node
					end
					self.current = node
				end
			end

			---Parses a tag content.
			-- @param text text to process
			function dom:text(text)
				local node = { _type = "TEXT",
					_text = text
				}
				table.insert(self.current._children, node)
			end

			---Parses a comment tag.
			-- @param text comment text
			function dom:comment(text)
				if self.options.commentNode then
					local node = { _type = "COMMENT",
						_text = text
					}
					table.insert(self.current._children, node)
				end
			end

			--- Parses a XML processing instruction (PI) tag
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:pi(tag)
				if self.options.piNode then
					local node = { _type = "PI",
						_name = tag.name,
						_attr = tag.attrs,
					}
					table.insert(self.current._children, node)
				end
			end

			---Parse the XML declaration line (the line that indicates the XML version).
			-- @param tag a {name, attrs} table
			-- where name is the name of the tag and attrs
			-- is a table containing the attributes of the tag
			function dom:decl(tag)
				if self.options.declNode then
					self.decl = { _type = "DECL",
						_name = tag.name,
						_attr = tag.attrs,
					}
				end
			end

			---Parses a DTD tag.
			-- @param tag a {name, value} table
			-- where name is the name of the tag and value
			-- is a table containing the attributes of the tag
			function dom:dtd(tag)
				if self.options.dtdNode then
					self.dtd = { _type = "DTD",
						_name = tag.name,
						_text = tag.value
					}
				end
			end

			--- XML escape characters for a TEXT node.
			-- @param s a string
			-- @return @p s XML escaped.
			local function xmlEscape(s)
				s = string.gsub(s, '&', '&amp;')
				s = string.gsub(s, '<', '&lt;')
				return string.gsub(s, '>', '&gt;')
			end

			--- return a string of XML attributes
			-- @param tab table with XML attribute pairs. key and value are supposed to be strings.
			-- @return a string.
			local function attrsToStr(tab)
				if not tab then
					return ''
				end
				if type(tab) == 'table' then
					local s = ''
					for n,v in pairs(tab) do
						-- determine a safe quote character
						local val = tostring(v)
						local found_single_quote = string.find(val, "'")
						local found_double_quote = string.find(val, '"')
						local quot = '"'
						if found_single_quote and found_double_quote then
							-- XML escape both quote characters
							val = string.gsub(val, '"', '&quot;')
							val = string.gsub(val, "'", '&apos;')
						elseif found_double_quote then
							quot = "'"
						end
						s = ' ' .. tostring(n) .. '=' .. quot .. val .. quot
					end
					return s
				end
				return 'BUG:unknown type:' .. type(tab)
			end

			--- return a XML formatted string of @p node.
			-- @param node a Node object (table) of the xml2lua DOM tree structure.
			-- @return a string.
			local function toXmlStr(node, indentLevel)
				if not node then
					return 'BUG:node==nil'
				end
				if not node._type then
					return 'BUG:node._type==nil'
				end

				local indent = ''
				for i=0, indentLevel+1, 1 do
					indent = indent .. ' '
				end

				if node._type == 'ROOT' then
					local s = ''
					for i, n in pairs(node._children) do
						s = s .. toXmlStr(n, indentLevel+2)
					end
					return s
				elseif node._type == 'ELEMENT' then
					local s = indent .. '<' .. node._name .. attrsToStr(node._attr)

					-- check if ELEMENT has no children
					if not node._children or
						#node._children == 0 then
						return s .. '/>\n'
					end

					s = s .. '>\n'

					for i, n in pairs(node._children) do
						local xx = toXmlStr(n, indentLevel+2)
						if not xx then
							print('BUG:xx==nil')
						else
							s = s .. xx
						end
					end

					return s .. indent .. '</' .. node._name .. '>\n'

				elseif node._type == 'TEXT' then
					return indent .. xmlEscape(node._text) .. '\n'
				elseif node._type == 'COMMENT' then
					return indent .. '<!--' .. node._text .. '-->\n'
				elseif node._type == 'PI' then
					return indent .. '<?' .. node._name .. ' ' .. node._attr._text .. '?>\n'
				elseif node._type == 'DECL' then
					return indent .. '<?' .. node._name .. attrsToStr(node._attr) .. '?>\n'
				elseif node._type == 'DTD' then
					return indent .. '<!' .. node._name .. ' ' .. node._text .. '>\n'
				end
				return 'BUG:unknown type:' .. tostring(node._type)
			end

			---create a string in XML format from the dom root object @p node.
			-- @param node a root object, typically created with `dom` XML parser handler.
			-- @return a string, XML formatted.
			function dom:toXml(node)
				return toXmlStr(node, -4)
			end

			---Parses CDATA tag content.
			dom.cdata = dom.text
			dom.__index = dom
			return dom
		end)()
	}

	function XmlParser.new(_handler, _options)
		_handler = handlers[_handler]

		if not _handler then
			error("Handler doesn't exist", 2)
		end

		local obj = {
			handler = _handler,
			options = _options,
			_stack  = {}
		}

		setmetatable(obj, XmlParser)
		obj.__index = XmlParser
		return obj;
	end

	---Checks if a function/field exists in a table or in its metatable
	--@param table the table to check if it has a given function
	--@param elementName the name of the function/field to check if exists
	--@return true if the function/field exists, false otherwise
	local function fexists(table, elementName)
		if table == nil then
			return false
		end

		if table[elementName] == nil then
			return fexists(getmetatable(table), elementName)
		else
			return true
		end
	end

	local function err(self, errMsg, pos)
		if self.options.errorHandler then
			self.options.errorHandler(errMsg,pos)
		end
	end

	--- Removes whitespaces
	local function stripWS(self, s)
		if self.options.stripWS then
			s = string.gsub(s,'^%s+','')
			s = string.gsub(s,'%s+$','')
		end
		return s
	end

	local function parseEntities(self, s) 
		if self.options.expandEntities then
			for k,v in pairs(self._ENTITIES) do
				s = string.gsub(s,k,v)
			end
		end

		return s
	end

	--- Parses a string representing a tag.
	--@param s String containing tag text
	--@return a {name, attrs} table
	-- where name is the name of the tag and attrs 
	-- is a table containing the attributes of the tag
	local function parseTag(self, s)
		local tag = {
			name = string.gsub(s, self._TAG, '%1'),
			attrs = {}
		}            

		local parseFunction = function (k, v) 
			tag.attrs[k] = parseEntities(self, v)
			tag.attrs._ = 1 
		end

		string.gsub(s, self._ATTR1, parseFunction) 
		string.gsub(s, self._ATTR2, parseFunction)

		if tag.attrs._ then
			tag.attrs._ = nil
		else 
			tag.attrs = nil
		end

		return tag
	end

	local function parseXmlDeclaration(self, xml, f)
		-- XML Declaration
		f.match, f.endMatch, f.text = string.find(xml, self._PI, f.pos)
		if not f.match then 
			err(self, self._errstr.declErr, f.pos)
		end 

		if f.match ~= 1 then
			-- Must be at start of doc if present
			err(self, self._errstr.declStartErr, f.pos)
		end

		local tag = parseTag(self, f.text) 
		-- TODO: Check if attributes are valid
		-- Check for version (mandatory)
		if tag.attrs and tag.attrs.version == nil then
			err(self, self._errstr.declAttrErr, f.pos)
		end

		if fexists(self.handler, 'decl') then 
			self.handler:decl(tag, f.match, f.endMatch)
		end    

		return tag
	end

	local function parseXmlProcessingInstruction(self, xml, f)
		local tag = {}

		-- XML Processing Instruction (PI)
		f.match, f.endMatch, f.text = string.find(xml, self._PI, f.pos)
		if not f.match then 
			err(self, self._errstr.piErr, f.pos)
		end 
		if fexists(self.handler, 'pi') then 
			-- Parse PI attributes & text
			tag = parseTag(self, f.text) 
			local pi = string.sub(f.text, string.len(tag.name)+1)
			if pi ~= "" then
				if tag.attrs then
					tag.attrs._text = pi
				else
					tag.attrs = { _text = pi }
				end
			end
			self.handler:pi(tag, f.match, f.endMatch) 
		end

		return tag
	end

	local function parseComment(self, xml, f)
		f.match, f.endMatch, f.text = string.find(xml, self._COMMENT, f.pos)
		if not f.match then 
			err(self, self._errstr.commentErr, f.pos)
		end 

		if fexists(self.handler, 'comment') then 
			f.text = parseEntities(self, stripWS(self, f.text))
			self.handler:comment(f.text, next, f.match, f.endMatch)
		end
	end

	local function _parseDtd(self, xml, pos)
		-- match,endMatch,root,type,name,uri,internal
		local dtdPatterns = {self._DTD1, self._DTD2, self._DTD3, self._DTD4, self._DTD5, self._DTD6}

		for _, dtd in pairs(dtdPatterns) do
			local m,e,r,t,n,u,i = string.find(xml, dtd, pos)
			if m then
				return m, e, {_root=r, _type=t, _name=n, _uri=u, _internal=i} 
			end
		end

		return nil
	end

	local function parseDtd(self, xml, f)
		f.match, f.endMatch, _ = _parseDtd(self, xml, f.pos)
		if not f.match then 
			err(self, self._errstr.dtdErr, f.pos)
		end 

		if fexists(self.handler, 'dtd') then
			local tag = {name="DOCTYPE", value=string.sub(xml, f.match+10, f.endMatch-1)}
			self.handler:dtd(tag, f.match, f.endMatch)
		end
	end

	local function parseCdata(self, xml, f)
		f.match, f.endMatch, f.text = string.find(xml, self._CDATA, f.pos)
		if not f.match then 
			err(self, self._errstr.cdataErr, f.pos)
		end 

		if fexists(self.handler, 'cdata') then
			self.handler:cdata(f.text, nil, f.match, f.endMatch)
		end    
	end

	--- Parse a Normal tag
	-- Need check for embedded '>' in attribute value and extend
	-- match recursively if necessary eg. <tag attr="123>456"> 
	local function parseNormalTag(self, xml, f)
		--Check for errors
		while 1 do
			--If there isn't an attribute without closing quotes (single or double quotes)
			--then breaks to follow the normal processing of the tag.
			--Otherwise, try to find where the quotes close.
			f.errStart, f.errEnd = string.find(f.tagstr, self._ATTRERR1)        

			if f.errEnd == nil then
				f.errStart, f.errEnd = string.find(f.tagstr, self._ATTRERR2)
				if f.errEnd == nil then
					break
				end
			end

			f.extStart, f.extEnd, f.endt2 = string.find(xml, self._TAGEXT, f.endMatch+1)
			f.tagstr = f.tagstr .. string.sub(xml, f.endMatch, f.extEnd-1)
			if not f.match then 
				err(self, self._errstr.xmlErr, f.pos)
			end 
			f.endMatch = f.extEnd
		end 

		-- Extract tag name and attrs
		local tag = parseTag(self, f.tagstr) 

		if (f.endt1=="/") then
			if fexists(self.handler, 'endtag') then
				if tag.attrs then
					-- Shouldn't have any attributes in endtag
					err(self, string.format("%s (/%s)", self._errstr.endTagErr, tag.name), f.pos)
				end
				if table.remove(self._stack) ~= tag.name then
					err(self, string.format("%s (/%s)", self._errstr.unmatchedTagErr, tag.name), f.pos)
				end
				self.handler:endtag(tag, f.match, f.endMatch)
			end
		else
			table.insert(self._stack, tag.name)

			if fexists(self.handler, 'starttag') then
				self.handler:starttag(tag, f.match, f.endMatch)
			end

			-- Self-Closing Tag
			if (f.endt2=="/") then
				table.remove(self._stack)
				if fexists(self.handler, 'endtag') then
					self.handler:endtag(tag, f.match, f.endMatch)
				end
			end
		end

		return tag
	end

	local function parseTagType(self, xml, f)
		-- Test for tag type
		if string.find(string.sub(f.tagstr, 1, 5), "?xml%s") then
			parseXmlDeclaration(self, xml, f)
		elseif string.sub(f.tagstr, 1, 1) == "?" then
			parseXmlProcessingInstruction(self, xml, f)
		elseif string.sub(f.tagstr, 1, 3) == "!--" then
			parseComment(self, xml, f)
		elseif string.sub(f.tagstr, 1, 8) == "!DOCTYPE" then
			parseDtd(self, xml, f)
		elseif string.sub(f.tagstr, 1, 8) == "![CDATA[" then
			parseCdata(self, xml, f)
		else
			parseNormalTag(self, xml, f)
		end
	end

	--- Get next tag (first pass - fix exceptions below).
	--@return true if the next tag could be got, false otherwise
	local function getNextTag(self, xml, f)
		f.match, f.endMatch, f.text, f.endt1, f.tagstr, f.endt2 = string.find(xml, self._XML, f.pos)
		if not f.match then 
			if string.find(xml, self._WS, f.pos) then
				-- No more text - check document complete
				if #self._stack ~= 0 then
					err(self, self._errstr.incompleteXmlErr, f.pos)
				else
					return false 
				end
			else
				-- Unparsable text
				err(self, self._errstr.xmlErr, f.pos)
			end
		end 

		f.text = f.text or ''
		f.tagstr = f.tagstr or ''
		f.match = f.match or 0

		return f.endMatch ~= nil
	end

	--Main function which starts the XML parsing process
	--@param xml the XML string to parse
	--@param parseAttributes indicates if tag attributes should be parsed or not. 
	--       If omitted, the default value is true.
	function XmlParser:parse(xml, parseAttributes)
		if type(self) ~= "table" or getmetatable(self) ~= XmlParser then
			error("You must call xmlparser:parse(parameters) instead of xmlparser.parse(parameters)")
		end

		if parseAttributes == nil then
			parseAttributes = true
		end

		self.handler.parseAttributes = parseAttributes

		--Stores string.find results and parameters
		--and other auxiliar variables
		local f = {
			--string.find return
			match = 0,
			endMatch = 0,
			-- text, end1, tagstr, end2,

			--string.find parameters and auxiliar variables
			pos = 1,
			-- startText, endText,
			-- errStart, errEnd, extStart, extEnd,
		}

		while f.match do
			if not getNextTag(self, xml, f) then
				break
			end

			-- Handle leading text
			f.startText = f.match
			f.endText = f.match + string.len(f.text) - 1
			f.match = f.match + string.len(f.text)
			f.text = parseEntities(self, stripWS(self, f.text))
			if f.text ~= "" and fexists(self.handler, 'text') then
				self.handler:text(f.text, nil, f.match, f.endText)
			end

			parseTagType(self, xml, f)
			f.pos = f.endMatch + 1
		end

		return self.handler
	end

	XmlParser.__index = XmlParser
	return XmlParser
end)()

---Recursivelly prints a table in an easy-to-ready format
--@param tb The table to be printed
--@param level the indentation level to start with
local function printableInternal(tb, level)
	if tb == nil then
		return
	end

	level = level or 1
	local spaces = string.rep(' ', level*2)
	for k,v in pairs(tb) do
		if type(v) == "table" then
			print(spaces .. k)
			printableInternal(v, level+1)
		else
			print(spaces .. k..'='..v)
		end
	end
end

---Instantiates a XmlParser object to parse a XML string
--@param handler Handler module to be used to convert the XML string
--to another formats. See the available handlers at the handler directory.
-- Usually you get an instance to a handler module using, for instance:
-- local handler = require("xmlhandler/tree").
--@return a XmlParser object used to parse the XML
--@see XmlParser
function xml2lua.parser(handler)
	if handler == xml2lua then
		error("You must call xml2lua.parse(handler) instead of xml2lua:parse(handler)")
	end

	local options = {
		--Indicates if whitespaces should be striped or not
		stripWS = 1,
		expandEntities = 1,
		errorHandler = function(errMsg, pos)
			error(string.format("%s [char=%d]\n", errMsg or "Parse Error", pos))
		end
	}

	return XmlParser.new(handler, options)
end

---Recursivelly prints a table in an easy-to-ready format
--@param tb The table to be printed
function xml2lua.printable(tb)
	printableInternal(tb)
end

---Handler to generate a string prepresentation of a table
--Convenience function for printHandler (Does not support recursive tables).
--@param t Table to be parsed
--@return a string representation of the table
function xml2lua.toString(t)
	local sep = ''
	local res = ''
	if type(t) ~= 'table' then
		return t
	end

	for k,v in pairs(t) do
		if type(v) == 'table' then
			v = xml2lua.toString(v)
		end
		res = res .. sep .. string.format("%s=%s", k, v)
		sep = ','
	end
	res = '{'..res..'}'

	return res
end

---Gets an _attr element from a table that represents the attributes of an XML tag,
--and generates a XML String representing the attibutes to be inserted
--into the openning tag of the XML
--
--@param attrTable table from where the _attr field will be got
--@return a XML String representation of the tag attributes
local function attrToXml(attrTable)
	local s = ""
	attrTable = attrTable or {}

	for k, v in pairs(attrTable) do
		s = s .. " " .. k .. "=" .. '"' .. v .. '"'
	end
	return s
end

---Gets the first key of a given table
local function getSingleChild(tb)
	local count = 0
	for _ in pairs(tb) do
		count = count + 1
	end
	if (count == 1) then
		for k, _ in pairs(tb) do
			return k
		end
	end
	return nil
end

---Gets the first value of a given table
local function getFirstValue(tb)
	if type(tb) == "table" then
		for _, v in pairs(tb) do
			return v
		end
		return nil
	end

	return tb
end

xml2lua.pretty = true

function xml2lua.getSpaces(level)
	local spaces = ''
	if (xml2lua.pretty) then
		spaces = string.rep(' ', level * 2)
	end
	return spaces
end

function xml2lua.addTagValueAttr(tagName, tagValue, attrTable, level)
	local attrStr = attrToXml(attrTable)
	local spaces = xml2lua.getSpaces(level)
	if (tagValue == '') then
		table.insert(xml2lua.xmltb, spaces .. '<' .. tagName .. attrStr .. '/>')
	else
		table.insert(xml2lua.xmltb, spaces .. '<' .. tagName .. attrStr .. '>' .. tostring(tagValue) .. '</' .. tagName .. '>')
	end
end

function xml2lua.startTag(tagName, attrTable, level)
	local attrStr = attrToXml(attrTable)
	local spaces = xml2lua.getSpaces(level)
	if (tagName ~= nil) then
		table.insert(xml2lua.xmltb, spaces .. '<' .. tagName .. attrStr .. '>')
	end
end

function xml2lua.endTag(tagName, level)
	local spaces = xml2lua.getSpaces(level)
	if (tagName ~= nil) then
		table.insert(xml2lua.xmltb, spaces .. '</' .. tagName .. '>')
	end
end

function xml2lua.isChildArray(obj)
	for tag, _ in pairs(obj) do
		if (type(tag) == 'number') then
			return true
		end
	end
	return false
end

function xml2lua.isTableEmpty(obj)
	for k, _ in pairs(obj) do
		if (k ~= '_attr') then
			return false
		end
	end
	return true
end

function xml2lua.parseTableToXml(obj, tagName, level)
	if (tagName ~= '_attr') then
		if (type(obj) == 'table') then
			if (xml2lua.isChildArray(obj)) then
				for _, value in pairs(obj) do
					xml2lua.parseTableToXml(value, tagName, level)
				end
			elseif xml2lua.isTableEmpty(obj) then
				xml2lua.addTagValueAttr(tagName, "", obj._attr, level)
			else
				xml2lua.startTag(tagName, obj._attr, level)
				for tag, value in pairs(obj) do
					xml2lua.parseTableToXml(value, tag, level + 1)
				end
				xml2lua.endTag(tagName, level)
			end
		else
			xml2lua.addTagValueAttr(tagName, obj, nil, level)
		end
	end
end

---Converts a Lua table to a XML String representation.
--@param tb Table to be converted to XML
--@param tableName Name of the table variable given to this function,
--                 to be used as the root tag. If a value is not provided
--                 no root tag will be created.
--@param level Only used internally, when the function is called recursively to print indentation
--
--@return a String representing the table content in XML
function xml2lua.toXml(tb, tableName, level)
	xml2lua.xmltb = {}
	level = level or 0
	local singleChild = getSingleChild(tb)
	tableName = tableName or singleChild

	if (singleChild) then
		xml2lua.parseTableToXml(getFirstValue(tb), tableName, level)
	else
		xml2lua.parseTableToXml(tb, tableName, level)
	end

	if (xml2lua.pretty) then
		return table.concat(xml2lua.xmltb, '\n')
	end
	return table.concat(xml2lua.xmltb)
end

return xml2lua
end)()

local util_modules = {
	projectile = {Projectile, "Created by Synarx.\n\ncant be bothered to doc"},
	xml = {XML, "XML reader cant be bothered to doc"},
	base64 = {Base64, "https://gist.github.com/Reselim/40d62b17d138cc74335a1b0709e19ce2\n\nBase64.Encode(Input: string): string\nBase64.Decode(Input: string): string"},
	canvasdraw = {CanvasDraw, "https://devforum.roblox.com/t/2017699"},
	libdeflate = {LibDeflate, "https://safeteewow.github.io/LibDeflate/source/LibDeflate.lua.html"},
	spring = {Spring, "https://quenty.github.io/NevermoreEngine/api/Spring/"},
	roact = {Roact, "https://roblox.github.io/roact/api-reference/"},
	ragdoll = {Ragdoll, "Edited roblox made ragdoll module. (edited to support R6)\n\nlocal ragdollObject = Ragdoll.new(Character: Model)\n\nragdollObject:setupJoint(jointName: string, info: {Limits: {Cone: number?, Twist: number?, Lower: number?, Upper: number?}?})\nragdollObject:setJointRagdolled(jointName: string, ragdolled: boolean)\nGroups: LeftArm, RightArm, RightLeg, LeftLeg, LowerBody, UpperBody\nragdollObject:setGroupRagdolled(groupName: string, ragdolled: boolean)\nragdollObject:setRagdolled(ragdolled: boolean, whitelist: {jointName}?)\nragdollObject:destroy()"},
	roblox = {Roblox, "Roblox made util module. (LIMITED DOCS)\n"},
	getclosest = {GetClosest, "Created by Synarx.\n\nGetClosest.Single(Position: Vector3, Distance: number, Check: ((Character: Model) => boolean)?): TargetCharacter, DistanceFromTarget, TargetRootPart, TargetHumanoid, TargetPivot\nGetClosest.Collection((Position: Vector3, Distance: number, Check: ((Character: Model) => boolean)?): {{TargetCharacter, DistanceFromTarget, TargetRootPart, TargetHumanoid, TargetPivot}...}"},
	interval = {function(Callback, Time, WaitTime)
		local Start = os.clock()
		while (os.clock() - Start) < Time do
			task.wait(WaitTime)
			Callback((os.clock() - Start) / Time)
		end
	end, "Created by Synarx.\n\ninterval(function(Alpha) print(Alpha) end, 5, nil)\nSimple clock function, first argument takes function which is given an 'alpha' value which is a value from 0 - 1 and is a factor of how close it is to its time goal, 2nd argument is the time goal, 3rd is the wait time - the number that is put into task.wait"}
}

for i, v in Roblox do
	util_modules.roblox[2] ..= "\nRoblox."..i.."()"
end

util_modules._info = function()
	print("To retrive a module, simply index util.")
	print("Example:")
	print("	local Spring = util.spring")
	print("Indexing util is not case sensitive.")
	print("You can find the documentation to a module using util._document(moduleName: string)")
	print("-----------------------------------------------------------------------------------")
	print("List of functions:")
	for i,v in util_modules do
		print(i)
	end
end

util_modules._document = function(index)
	local module = util_modules[index:lower()]
	if module then
		print(index .. " | " .. module[2])
	else
		warn("module " .. index .. " does not exist")
	end
end

return setmetatable({}, {
	__index = function(self, index)
		local module = util_modules[index:lower()]
		if module then
			return typeof(module) == "table" and module[1] or module
		else
			error("module " .. index .. " does not exist")
		end
	end,
	__newindex = function()
		error("cant set")
	end,
})