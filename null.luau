local defer = function(...)
	pcall(task.defer, ...)
end

local null = function(bind, bind2)
	bind = bind or Instance.new("BindableFunction")
	bind2 = bind2 or Instance.new("BindableEvent")

	local funcs = {}

	function funcs.hyper(func: (...any)->...any, ...)
		bind.OnInvoke = function(...)
			if pcall(bind.Invoke, bind, ...) == false then
				func()
			end
		end
		if pcall(bind.Invoke, bind, ...) == false then
			func()
		end
	end

	local task_defer = task.defer
	local task_spawn = task.spawn
	function funcs.amplify(f, ...)
		task_defer(
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 10
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 20
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 30
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 40
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 50
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 60
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 70
			task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, task_defer, -- 80
			f, ...
		)
	end

	local function msp(v, ...)
		task_spawn(function(...)
			v(...)
		end, ...)
	end

	local function fmsp(v)
		task_spawn(function()
			v()
		end)
	end

	function funcs.meta(func: (...any)->...any, ...)
		local mm
		mm = setmetatable({}, {
			__call = function(...)
				task_spawn(func, ...)
				msp(mm, ...)
			end,
		})
		msp(mm, ...)
	end

	function funcs.fastMeta(func)
		local mm
		mm = setmetatable({}, {
			__call = function()
				task_spawn(func)
				fmsp(mm)
			end,
		})
		fmsp(mm)
	end

	function funcs.super(times: number, func: (...any)->...any, ...)
		local did = 0
		local current
		current = function(...)
			did += 1 
			if did == times then 
				func(...)
			end 
			if did == times then 
				return
			end 
			defer(current, ...) 
		end
		defer(current, ...)
	end

	return funcs
end

return null()