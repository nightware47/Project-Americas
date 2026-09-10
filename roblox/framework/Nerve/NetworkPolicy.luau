--!strict

type RateLimit = {
	requests: number,
	window: number,
}

local NetworkPolicy = {}

function NetworkPolicy.ValidateMiddleware(middleware: any, label: string): ()
	if middleware == nil then
		return
	end

	assert(type(middleware) == "table", `{label} must be a table`)

	for _, direction in { "Inbound", "Outbound" } do
		local callbacks = middleware[direction]
		if callbacks == nil then
			continue
		end

		assert(type(callbacks) == "table", `{label}.{direction} must be an array`)
		for index, callback in callbacks do
			assert(type(callback) == "function", `{label}.{direction}[{index}] must be a function`)
		end
	end
end

function NetworkPolicy.ResolveMiddleware(globalMiddleware: any, endpointMiddleware: any): any
	if type(endpointMiddleware) == "table" then
		return endpointMiddleware
	end

	if type(globalMiddleware) == "table" then
		return globalMiddleware
	end

	return nil
end

function NetworkPolicy.RunMiddleware(middleware: any, player: Player?, args: { [any]: any }): (boolean, { [any]: any })
	if type(middleware) ~= "table" then
		return true, args
	end

	local currentArgs = args

	for index, callback in middleware do
		assert(type(callback) == "function", `Middleware entry {index} must be a function`)

		local results = if player then table.pack(callback(player, currentArgs)) else table.pack(callback(currentArgs))

		if results[1] ~= true then
			return false, currentArgs
		end

		if results.n > 1 then
			local replacement = table.create(results.n - 1)
			replacement.n = results.n - 1
			for resultIndex = 2, results.n do
				replacement[resultIndex - 1] = results[resultIndex]
			end
			currentArgs = replacement
		end
	end

	return true, currentArgs
end

function NetworkPolicy.CheckRate(bucket: { [any]: any }, key: any, limit: RateLimit?, now: number): boolean
	if not limit then
		return true
	end

	local state = bucket[key]
	if not state or now - state.started >= limit.window then
		state = {
			started = now,
			count = 0,
		}
		bucket[key] = state
	end

	state.count += 1
	return state.count <= limit.requests
end

return table.freeze(NetworkPolicy)
