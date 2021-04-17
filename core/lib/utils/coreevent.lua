if core then
	core:module("CoreEvent")
	core:import("CoreDebug")
end

-- Lines 18-41
function callback(o, base_callback_class, base_callback_func_name, base_callback_param)
	if base_callback_class and base_callback_func_name and base_callback_class[base_callback_func_name] then
		if base_callback_param ~= nil then
			if o then
				return function (...)
					return base_callback_class[base_callback_func_name](o, base_callback_param, ...)
				end
			else
				return function (...)
					return base_callback_class[base_callback_func_name](base_callback_param, ...)
				end
			end
		elseif o then
			return function (...)
				return base_callback_class[base_callback_func_name](o, ...)
			end
		else
			return function (...)
				return base_callback_class[base_callback_func_name](...)
			end
		end
	elseif base_callback_class then
		local class_name = base_callback_class and CoreDebug.class_name(getmetatable(base_callback_class) or base_callback_class)

		error("Callback on class \"" .. tostring(class_name) .. "\" refers to a non-existing function \"" .. tostring(base_callback_func_name) .. "\".")
	elseif base_callback_func_name then
		error("Callback to function \"" .. tostring(base_callback_func_name) .. "\" is on a nil class.")
	else
		error("Callback class and function was nil.")
	end
end

local tc = 0

-- Lines 49-51
function get_ticket(delay)
	return {
		delay,
		math.random(delay - 1)
	}
end

-- Lines 53-55
function valid_ticket(ticket)
	return tc % ticket[1] == ticket[2]
end

-- Lines 57-62
function update_tickets()
	tc = tc + 1

	if tc > 30 then
		tc = 0
	end
end

BasicEventHandling = {
	connect = function (self, event_name, callback_func, data)
		self._event_callbacks = self._event_callbacks or {}
		self._event_callbacks[event_name] = self._event_callbacks[event_name] or {}

		-- Lines 76-76
		local function wrapped_func(...)
			callback_func(data, ...)
		end

		table.insert(self._event_callbacks[event_name], wrapped_func)

		return wrapped_func
	end,
	disconnect = function (self, event_name, wrapped_func)
		if self._event_callbacks and self._event_callbacks[event_name] then
			table.delete(self._event_callbacks[event_name], wrapped_func)

			if table.empty(self._event_callbacks[event_name]) then
				self._event_callbacks[event_name] = nil

				if table.empty(self._event_callbacks) then
					self._event_callbacks = nil
				end
			end
		end
	end,
	_has_callbacks_for_event = function (self, event_name)
		return self._event_callbacks ~= nil and self._event_callbacks[event_name] ~= nil
	end,
	_send_event = function (self, event_name, ...)
		if self._event_callbacks then
			for _, wrapped_func in ipairs(self._event_callbacks[event_name] or {}) do
				wrapped_func(...)
			end
		end
	end
}
CallbackHandler = CallbackHandler or class()

-- Lines 113-115
function CallbackHandler:init()
	self:clear()
end

-- Lines 117-120
function CallbackHandler:clear()
	self._t = 0
	self._sorted = {}
end

-- Lines 122-128
function CallbackHandler:__insert_sorted(cb)
	local i = 1

	while self._sorted[i] and (self._sorted[i].next == nil or self._sorted[i].next < cb.next) do
		i = i + 1
	end

	table.insert(self._sorted, i, cb)
end

-- Lines 130-143
function CallbackHandler:add(f, interval, times)
	times = times or -1
	local cb = {
		f = f,
		interval = interval,
		times = times,
		next = self._t + interval
	}

	self:__insert_sorted(cb)

	return cb
end

-- Lines 145-149
function CallbackHandler:remove(cb)
	if cb then
		cb.next = nil
	end
end

-- Lines 151-177
function CallbackHandler:update(dt)
	self._t = self._t + dt

	while true do
		local cb = self._sorted[1]

		if cb == nil then
			return
		elseif cb.next == nil then
			table.remove(self._sorted, 1)
		elseif self._t < cb.next then
			return
		else
			table.remove(self._sorted, 1)
			cb:f(self._t)

			if cb.times >= 0 then
				cb.times = cb.times - 1

				if cb.times <= 0 then
					cb.next = nil
				end
			end

			if cb.next then
				cb.next = cb.next + cb.interval

				self:__insert_sorted(cb)
			end
		end
	end
end

CallbackEventHandler = CallbackEventHandler or class()

-- Lines 184-189
function CallbackEventHandler:init()
end

-- Lines 191-193
function CallbackEventHandler:clear()
	self._callback_map = nil
end

-- Lines 195-198
function CallbackEventHandler:add(func)
	self._callback_map = self._callback_map or {}
	self._callback_map[func] = true
end

-- Lines 200-214
function CallbackEventHandler:remove(func)
	if not self._callback_map or not self._callback_map[func] then
		return
	end

	if self._next_callback == func then
		self._next_callback = next(self._callback_map, self._next_callback)
	end

	self._callback_map[func] = nil

	if not next(self._callback_map) then
		self._callback_map = nil
	end
end

-- Lines 216-229
function CallbackEventHandler:dispatch(...)
	if self._callback_map then
		self._next_callback = next(self._callback_map)

		self._next_callback(...)

		while self._next_callback do
			self._next_callback = next(self._callback_map, self._next_callback)

			if self._next_callback then
				self._next_callback(...)
			end
		end
	end
end

-- Lines 244-253
function over(seconds, f, fixed_dt)
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + (fixed_dt and 0.03333333333333333 or dt)

		if seconds <= t then
			break
		end

		f(t / seconds, t)
	end

	f(1, seconds)
end

-- Lines 259-270
function seconds(s, t)
	if not t then
		return seconds, s, 0
	end

	if s and s <= t then
		return nil
	end

	local dt = coroutine.yield()
	t = t + dt

	if s and s < t then
		t = s
	end

	if s then
		return t, t / s, dt
	else
		return t, t, dt
	end
end

-- Lines 273-279
function wait(seconds, fixed_dt)
	local t = 0

	while seconds > t do
		local dt = coroutine.yield()
		t = t + (fixed_dt and 0.03333333333333333 or dt)
	end
end
