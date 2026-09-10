--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Dependencies = script.Parent.Dependencies
local ByteNet = require(Dependencies.ByteNet)
local ByteNetColor3 = require(Dependencies.ByteNet.dataTypes.color3)()
local Promise = require(Dependencies.Promise)
local LocalSignal = require(Dependencies.Signal)
local NetworkPolicy = require(script.Parent.NetworkPolicy)
local Schema = require(script.Parent.Schema)

local MANIFEST_NAME = "NerveManifest"
local NAMESPACE_NAME = "Nerve.ByteNet.v1"
local MAX_PACKETS = 240
local DEFAULT_TIMEOUT = 10
local DEFAULT_MAX_IN_FLIGHT = 128
local DEFAULT_METHOD_RATE_LIMIT = {
	requests = 30,
	window = 1,
}
local DEFAULT_SIGNAL_RATE_LIMIT = {
	requests = 60,
	window = 1,
}

type Descriptor = Schema.Descriptor
type Endpoint = {
	kind: "method" | "signal",
	request: Descriptor?,
	response: Descriptor?,
	arguments: Descriptor?,
	reliability: "reliable" | "unreliable"?,
	direction: "server" | "client" | "duplex"?,
	timeout: number?,
	rateLimit: {
		requests: number,
		window: number,
	}?,
}

type Manifest = {
	version: number,
	services: {
		[string]: {
			[string]: Endpoint,
		},
	},
}

local Runtime = {}
local signalMarkerTag = {}
local methodContractTag = {}
local propertyMarkerTag = {}

local clientManifest: Manifest? = nil
local clientPackets: { [string]: any }? = nil
local clientServices: { [string]: any } = {}
local clientOptions: any = nil
local requestId = 0

local function copyRateLimit(input: any)
	if input == nil or input == false then
		return nil
	end
	assert(type(input) == "table", "RateLimit must be a table")
	local requests = input.Requests or input.requests
	local window = input.Window or input.window
	assert(
		type(requests) == "number" and requests > 0 and requests % 1 == 0,
		"RateLimit.Requests must be a positive integer"
	)
	assert(type(window) == "number" and window > 0, "RateLimit.Window must be positive")
	return {
		requests = requests,
		window = window,
	}
end

function Runtime.Method(options: any?): any
	local resolved = options or {}
	assert(type(resolved) == "table", "Nerve.Method options must be a table")
	local request = resolved.Request or resolved.Arguments or Schema.Packed
	local response = resolved.Response or resolved.Returns or Schema.Packed
	Schema.Validate(request, "method request")
	Schema.Validate(response, "method response")
	local timeout = resolved.Timeout or DEFAULT_TIMEOUT
	assert(type(timeout) == "number" and timeout > 0 and timeout <= 120, "method timeout must be within 0-120 seconds")
	return table.freeze({
		_tag = methodContractTag,
		request = request,
		response = response,
		timeout = timeout,
		rateLimit = copyRateLimit(if resolved.RateLimit == nil then DEFAULT_METHOD_RATE_LIMIT else resolved.RateLimit),
	})
end

function Runtime.Signal(arguments: Descriptor?, options: any?): any
	local resolved = options or {}
	assert(type(resolved) == "table", "Nerve.Signal options must be a table")
	local schema = arguments or Schema.Packed
	Schema.Validate(schema, "signal arguments")
	local reliability = resolved.Reliability or "reliable"
	local direction = resolved.Direction or "server"
	assert(
		reliability == "reliable" or reliability == "unreliable",
		"signal reliability must be reliable or unreliable"
	)
	assert(
		direction == "server" or direction == "client" or direction == "duplex",
		"signal direction must be server, client, or duplex"
	)
	return table.freeze({
		_tag = signalMarkerTag,
		arguments = schema,
		reliability = reliability,
		direction = direction,
		rateLimit = copyRateLimit(if resolved.RateLimit == nil then DEFAULT_SIGNAL_RATE_LIMIT else resolved.RateLimit),
	})
end

function Runtime.Property(initialValue: any): any
	return table.freeze({
		_tag = propertyMarkerTag,
		initialValue = initialValue,
	})
end

local function sortedKeys(input: { [string]: any }): { string }
	local keys = {}
	for key in input do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function endpointKey(serviceName: string, endpointName: string, suffix: string): string
	return `{serviceName}.{endpointName}.{suffix}`
end

local function dataType(descriptor: Descriptor): any
	local kind = descriptor.kind
	if kind == "packed" or kind == "unknown" then
		return ByteNet.unknown
	elseif kind == "nothing" then
		return ByteNet.nothing
	elseif kind == "bool" then
		return ByteNet.bool
	elseif kind == "string" then
		return ByteNet.string
	elseif kind == "buffer" then
		return ByteNet.buff
	elseif kind == "uint8" then
		return ByteNet.uint8
	elseif kind == "uint16" then
		return ByteNet.uint16
	elseif kind == "uint32" then
		return ByteNet.uint32
	elseif kind == "int8" then
		return ByteNet.int8
	elseif kind == "int16" then
		return ByteNet.int16
	elseif kind == "int32" then
		return ByteNet.int32
	elseif kind == "float32" then
		return ByteNet.float32
	elseif kind == "float64" then
		return ByteNet.float64
	elseif kind == "vec2" then
		return ByteNet.vec2
	elseif kind == "vec3" then
		return ByteNet.vec3
	elseif kind == "cframe" then
		return ByteNet.cframe
	elseif kind == "color3" then
		return ByteNetColor3
	elseif kind == "instance" then
		return ByteNet.inst
	elseif kind == "optional" then
		return ByteNet.optional(dataType(descriptor.value))
	elseif kind == "array" then
		return ByteNet.array(dataType(descriptor.value))
	elseif kind == "map" then
		return ByteNet.map(dataType(descriptor.key), dataType(descriptor.value))
	elseif kind == "struct" then
		local fields = {}
		for _, name in sortedKeys(descriptor.fields) do
			local fieldDescriptor = descriptor.fields[name]
			fields[name] = dataType(fieldDescriptor)
		end
		return ByteNet.struct(fields)
	elseif kind == "tuple" then
		if #descriptor.items == 0 then
			return ByteNet.nothing
		end
		local fields = {}
		for index, itemDescriptor in descriptor.items do
			fields[`v{index}`] = dataType(itemDescriptor)
		end
		return ByteNet.struct(fields)
	end
	error(`Unsupported schema kind "{kind}"`)
end

local function encode(descriptor: Descriptor, values: { [any]: any }): any
	if descriptor.kind == "packed" then
		return values
	elseif descriptor.kind == "nothing" then
		return nil
	elseif descriptor.kind == "tuple" then
		if #descriptor.items == 0 then
			return nil
		end
		local result = {}
		for index = 1, #descriptor.items do
			result[`v{index}`] = values[index]
		end
		return result
	end
	return values[1]
end

local function decode(descriptor: Descriptor, payload: any): { [any]: any }
	if descriptor.kind == "packed" then
		if type(payload) == "table" and type(payload.n) == "number" then
			return payload
		end
		return table.pack(payload)
	elseif descriptor.kind == "nothing" then
		return { n = 0 }
	elseif descriptor.kind == "tuple" then
		local values = table.create(#descriptor.items)
		for index = 1, #descriptor.items do
			values[index] = payload and payload[`v{index}`] or nil
		end
		values.n = #descriptor.items
		return values
	end
	return table.pack(payload)
end

local function definePackets(manifest: Manifest): { [string]: any }
	local packetCount = 0
	return ByteNet.defineNamespace(NAMESPACE_NAME, function()
		local definitions = {}
		for _, serviceName in sortedKeys(manifest.services) do
			local endpoints = manifest.services[serviceName]
			for _, name in sortedKeys(endpoints) do
				local endpoint = endpoints[name]
				if endpoint.kind == "method" then
					local requestType = dataType(endpoint.request :: Descriptor)
					local responseType = dataType(endpoint.response :: Descriptor)
					definitions[endpointKey(serviceName, name, "request")] = ByteNet.definePacket({
						value = ByteNet.struct({
							id = ByteNet.uint32,
							payload = requestType,
						}),
						reliabilityType = "reliable",
					})
					definitions[endpointKey(serviceName, name, "success")] = ByteNet.definePacket({
						value = ByteNet.struct({
							id = ByteNet.uint32,
							payload = responseType,
						}),
						reliabilityType = "reliable",
					})
					definitions[endpointKey(serviceName, name, "error")] = ByteNet.definePacket({
						value = ByteNet.struct({
							id = ByteNet.uint32,
							code = ByteNet.string,
							message = ByteNet.string,
						}),
						reliabilityType = "reliable",
					})
					packetCount += 3
				else
					local direction = endpoint.direction or "server"
					local argumentsType = dataType(endpoint.arguments :: Descriptor)
					if direction == "server" or direction == "duplex" then
						definitions[endpointKey(serviceName, name, "server")] = ByteNet.definePacket({
							value = argumentsType,
							reliabilityType = endpoint.reliability or "reliable",
						})
						packetCount += 1
					end
					if direction == "client" or direction == "duplex" then
						definitions[endpointKey(serviceName, name, "client")] = ByteNet.definePacket({
							value = argumentsType,
							reliabilityType = endpoint.reliability or "reliable",
						})
						packetCount += 1
					end
				end
			end
		end
		assert(
			packetCount <= MAX_PACKETS,
			`Nerve network uses {packetCount} packets; ByteNet v0.4 supports at most {MAX_PACKETS} safely`
		)
		return definitions
	end)
end

local function descriptorFromMethod(value: any): Endpoint
	local contract = if type(value) == "table" and value._tag == methodContractTag then value else Runtime.Method()
	return {
		kind = "method",
		request = contract.request,
		response = contract.response,
		timeout = contract.timeout,
		rateLimit = contract.rateLimit,
	}
end

local function descriptorFromSignal(value: any): Endpoint
	return {
		kind = "signal",
		arguments = value.arguments,
		reliability = value.reliability,
		direction = value.direction,
		rateLimit = value.rateLimit,
	}
end

local function buildManifest(services: { [string]: any }): Manifest
	local manifest: Manifest = {
		version = 1,
		services = {},
	}
	for _, serviceName in sortedKeys(services) do
		local service = services[serviceName]
		local endpoints = {}
		local contracts = if type(service.Network) == "table" then service.Network else {}
		for name, value in service.Client do
			if name == "Server" then
				continue
			elseif type(value) == "function" then
				endpoints[name] = descriptorFromMethod(contracts[name])
			elseif type(value) == "table" and value._tag == signalMarkerTag then
				endpoints[name] = descriptorFromSignal(value)
			elseif type(value) == "table" and value._tag == propertyMarkerTag then
				error(
					`Nerve.CreateProperty is not available in the ByteNet runtime yet ({serviceName}.{name}); use a typed server signal and client cache`
				)
			end
		end
		for name, contract in contracts do
			assert(
				endpoints[name] ~= nil,
				`Network contract {serviceName}.{name} has no matching Client method or signal`
			)
			if type(service.Client[name]) == "function" then
				endpoints[name] = descriptorFromMethod(contract)
			end
		end
		if next(endpoints) ~= nil then
			manifest.services[serviceName] = endpoints
		end
	end
	return manifest
end

local function publishManifest(manifest: Manifest)
	local previous = ReplicatedStorage:FindFirstChild(MANIFEST_NAME)
	if previous then
		previous:Destroy()
	end
	local value = Instance.new("StringValue")
	value.Name = MANIFEST_NAME
	value.Value = HttpService:JSONEncode(manifest)
	value.Parent = ReplicatedStorage
end

local function safeError(message: any): string
	local text = tostring(message):gsub("[%c]", " ")
	return if #text > 240 then text:sub(1, 240) .. "..." else text
end

local function makeServerSignal(
	service: any,
	endpoint: Endpoint,
	packets: { [string]: any },
	name: string,
	options: any,
	rateState: { [string]: { [Player]: any } }
)
	local serviceName = service.Name
	local endpointName = `{serviceName}.{name}`
	local descriptor = endpoint.arguments :: Descriptor
	local outbound = packets[endpointKey(serviceName, name, "server")]
	local inbound = packets[endpointKey(serviceName, name, "client")]
	local localSignal = if inbound then LocalSignal.new() else nil
	local middleware = NetworkPolicy.ResolveMiddleware(options and options.Middleware, service.Middleware)
	local inboundMiddleware = if middleware then middleware.Inbound else nil
	local outboundMiddleware = if middleware then middleware.Outbound else nil
	local signalRateState = setmetatable({}, { __mode = "k" })
	rateState[endpointName] = signalRateState

	local function filterOutbound(player: Player, args: { [any]: any }): (boolean, { [any]: any })
		local succeeded, allowed, filteredArgs = pcall(NetworkPolicy.RunMiddleware, outboundMiddleware, player, args)
		if not succeeded then
			warn(`[Nerve/ByteNet] {endpointName} outbound middleware failed: {tostring(allowed)}`)
			return false, args
		end
		return allowed, filteredArgs
	end

	if inbound then
		inbound.listen(function(payload, player)
			if not player or player.Parent ~= Players then
				return
			end
			if not NetworkPolicy.CheckRate(signalRateState, player, endpoint.rateLimit, os.clock()) then
				return
			end

			local args = decode(descriptor, payload)
			local succeeded, allowed, filteredArgs = pcall(NetworkPolicy.RunMiddleware, inboundMiddleware, player, args)
			if not succeeded then
				warn(`[Nerve/ByteNet] {endpointName} inbound middleware failed: {tostring(allowed)}`)
				return
			end
			if allowed then
				local signal = localSignal :: any
				signal:Fire(player, table.unpack(filteredArgs, 1, filteredArgs.n))
			end
		end)
	end
	local wrapper = {}
	function wrapper:Connect(callback)
		assert(localSignal, `{serviceName}.{name} does not accept client traffic`)
		return (localSignal :: any):Connect(callback)
	end
	function wrapper:Fire(player: Player, ...)
		assert(outbound, `{serviceName}.{name} cannot send server traffic`)
		local allowed, args = filterOutbound(player, table.pack(...))
		if allowed then
			outbound.sendTo(encode(descriptor, args), player)
		end
	end
	function wrapper:FireAll(...)
		assert(outbound, `{serviceName}.{name} cannot send server traffic`)
		local args = table.pack(...)
		if not outboundMiddleware then
			outbound.sendToAll(encode(descriptor, args))
			return
		end
		for _, player in Players:GetPlayers() do
			local allowed, filteredArgs = filterOutbound(player, args)
			if allowed then
				outbound.sendTo(encode(descriptor, filteredArgs), player)
			end
		end
	end
	function wrapper:FireExcept(player: Player, ...)
		assert(outbound, `{serviceName}.{name} cannot send server traffic`)
		local args = table.pack(...)
		if not outboundMiddleware then
			outbound.sendToAllExcept(encode(descriptor, args), player)
			return
		end
		for _, recipient in Players:GetPlayers() do
			if recipient ~= player then
				local allowed, filteredArgs = filterOutbound(recipient, args)
				if allowed then
					outbound.sendTo(encode(descriptor, filteredArgs), recipient)
				end
			end
		end
	end
	function wrapper:FireList(players: { Player }, ...)
		assert(outbound, `{serviceName}.{name} cannot send server traffic`)
		local args = table.pack(...)
		if not outboundMiddleware then
			outbound.sendToList(encode(descriptor, args), players)
			return
		end
		for _, player in players do
			local allowed, filteredArgs = filterOutbound(player, args)
			if allowed then
				outbound.sendTo(encode(descriptor, filteredArgs), player)
			end
		end
	end
	function wrapper:Destroy()
		if localSignal then
			(localSignal :: any):Destroy()
		end
	end
	return wrapper
end

local function bindServerMethod(
	service: any,
	name: string,
	endpoint: Endpoint,
	packets: { [string]: any },
	rateState: { [string]: { [Player]: any } },
	options: any,
	activeRequests: { [Player]: { [any]: boolean } }
)
	local requestPacket = packets[endpointKey(service.Name, name, "request")]
	local successPacket = packets[endpointKey(service.Name, name, "success")]
	local errorPacket = packets[endpointKey(service.Name, name, "error")]
	local requestDescriptor = endpoint.request :: Descriptor
	local responseDescriptor = endpoint.response :: Descriptor
	local endpointName = `{service.Name}.{name}`
	rateState[endpointName] = setmetatable({}, { __mode = "k" })
	local middleware = NetworkPolicy.ResolveMiddleware(options and options.Middleware, service.Middleware)
	local inboundMiddleware = if middleware then middleware.Inbound else nil
	local outboundMiddleware = if middleware then middleware.Outbound else nil

	requestPacket.listen(function(request, player)
		if not player or player.Parent ~= Players then
			return
		end
		if not NetworkPolicy.CheckRate(rateState[endpointName], player, endpoint.rateLimit, os.clock()) then
			errorPacket.sendTo({
				id = request.id,
				code = "RATE_LIMITED",
				message = "Too many requests",
			}, player)
			return
		end

		local args = decode(requestDescriptor, request.payload)
		local middlewareSucceeded, allowed, filteredArgs =
			pcall(NetworkPolicy.RunMiddleware, inboundMiddleware, player, args)
		if not middlewareSucceeded then
			warn(`[Nerve/ByteNet] {endpointName} inbound middleware failed: {tostring(allowed)}`)
			errorPacket.sendTo({
				id = request.id,
				code = "SERVER_ERROR",
				message = "The server could not complete the request",
			}, player)
			return
		end
		if not allowed then
			errorPacket.sendTo({
				id = request.id,
				code = "MIDDLEWARE_REJECTED",
				message = "The request was rejected",
			}, player)
			return
		end

		local operation = Promise.try(function()
			return service.Client[name](service.Client, player, table.unpack(filteredArgs, 1, filteredArgs.n))
		end)
			:andThen(function(...)
				if player.Parent ~= Players then
					return
				end

				local values = table.pack(...)
				local outboundSucceeded, outboundAllowed, outboundValues =
					pcall(NetworkPolicy.RunMiddleware, outboundMiddleware, player, values)
				if not outboundSucceeded then
					error(`outbound middleware failed: {tostring(outboundAllowed)}`)
				end
				if not outboundAllowed then
					errorPacket.sendTo({
						id = request.id,
						code = "MIDDLEWARE_REJECTED",
						message = "The response was rejected",
					}, player)
					return
				end

				successPacket.sendTo({
					id = request.id,
					payload = encode(responseDescriptor, outboundValues),
				}, player)
			end)
			:catch(function(reason)
				if player.Parent == Players then
					warn(`[Nerve/ByteNet] {endpointName} failed: {tostring(reason)}`)
					errorPacket.sendTo({
						id = request.id,
						code = "SERVER_ERROR",
						message = "The server could not complete the request",
					}, player)
				end
			end)

		local playerRequests = activeRequests[player]
		if not playerRequests then
			playerRequests = {}
			activeRequests[player] = playerRequests
		end
		playerRequests[operation] = true
		operation:finally(function()
			playerRequests[operation] = nil
		end)
	end)
end

function Runtime.StartServer(services: { [string]: any }, options: any?): ()
	assert(RunService:IsServer(), "StartServer can only run on the server")
	NetworkPolicy.ValidateMiddleware(options and options.Middleware, "Nerve server middleware")
	for serviceName, service in services do
		NetworkPolicy.ValidateMiddleware(service.Middleware, `Service "{serviceName}" middleware`)
	end

	local manifest = buildManifest(services)
	local packets = definePackets(manifest)
	-- Publish last. Waiting for the manifest must guarantee that ByteNet has
	-- already replicated its namespace metadata to every client.
	publishManifest(manifest)
	local rateState = {}
	local activeRequests = setmetatable({}, { __mode = "k" })
	Players.PlayerRemoving:Connect(function(player)
		local playerRequests = activeRequests[player]
		if not playerRequests then
			return
		end

		activeRequests[player] = nil
		for operation in playerRequests do
			operation:cancel()
		end
	end)

	for serviceName, endpoints in manifest.services do
		local service = services[serviceName]
		for name, endpoint in endpoints do
			if endpoint.kind == "method" then
				bindServerMethod(service, name, endpoint, packets, rateState, options, activeRequests)
			else
				service.Client[name] = makeServerSignal(service, endpoint, packets, name, options, rateState)
			end
		end
	end
end

local function makeClientSignal(
	endpoint: Endpoint,
	packets: { [string]: any },
	serviceName: string,
	name: string,
	middleware: any
)
	local descriptor = endpoint.arguments :: Descriptor
	local inbound = packets[endpointKey(serviceName, name, "server")]
	local outbound = packets[endpointKey(serviceName, name, "client")]
	local localSignal = if inbound then LocalSignal.new() else nil
	local inboundMiddleware = if middleware then middleware.Inbound else nil
	local outboundMiddleware = if middleware then middleware.Outbound else nil
	if inbound then
		inbound.listen(function(payload)
			local args = decode(descriptor, payload)
			local succeeded, allowed, filteredArgs = pcall(NetworkPolicy.RunMiddleware, inboundMiddleware, nil, args)
			if not succeeded then
				warn(`[Nerve/ByteNet] {serviceName}.{name} inbound middleware failed: {tostring(allowed)}`)
				return
			end
			if allowed then
				local signal = localSignal :: any
				signal:Fire(table.unpack(filteredArgs, 1, filteredArgs.n))
			end
		end)
	end
	local wrapper = {}
	function wrapper:Connect(callback)
		assert(localSignal, `{serviceName}.{name} does not receive server traffic`)
		return (localSignal :: any):Connect(callback)
	end
	function wrapper:Once(callback)
		assert(localSignal, `{serviceName}.{name} does not receive server traffic`)
		return (localSignal :: any):Once(callback)
	end
	function wrapper:Wait()
		assert(localSignal, `{serviceName}.{name} does not receive server traffic`)
		return (localSignal :: any):Wait()
	end
	function wrapper:Fire(...)
		assert(outbound, `{serviceName}.{name} cannot send client traffic`)
		local allowed, args = NetworkPolicy.RunMiddleware(outboundMiddleware, nil, table.pack(...))
		if allowed then
			outbound.send(encode(descriptor, args))
		end
		return allowed
	end
	function wrapper:Destroy()
		if localSignal then
			(localSignal :: any):Destroy()
		end
	end
	return wrapper
end

local function nextRequestId(): number
	requestId = (requestId + 1) % 4294967296
	if requestId == 0 then
		requestId = 1
	end
	return requestId
end

local function makeClientMethod(
	endpoint: Endpoint,
	packets: { [string]: any },
	serviceName: string,
	name: string,
	middleware: any
)
	local requestPacket = packets[endpointKey(serviceName, name, "request")]
	local successPacket = packets[endpointKey(serviceName, name, "success")]
	local errorPacket = packets[endpointKey(serviceName, name, "error")]
	local requestDescriptor = endpoint.request :: Descriptor
	local responseDescriptor = endpoint.response :: Descriptor
	local pending: { [number]: any } = {}
	local inFlight = 0
	local inboundMiddleware = if middleware then middleware.Inbound else nil
	local outboundMiddleware = if middleware then middleware.Outbound else nil

	local function takePending(id: number, cancelTimeout: boolean): any
		local request = pending[id]
		if not request then
			return nil
		end

		pending[id] = nil
		inFlight -= 1

		if cancelTimeout and request.timeoutThread then
			task.cancel(request.timeoutThread)
		end

		return request
	end

	successPacket.listen(function(response)
		local request = takePending(response.id, true)
		if not request then
			return
		end

		local values = decode(responseDescriptor, response.payload)
		local succeeded, allowed, filteredValues = pcall(NetworkPolicy.RunMiddleware, inboundMiddleware, nil, values)
		if not succeeded then
			request.reject(`[MIDDLEWARE_ERROR] {safeError(allowed)}`)
		elseif not allowed then
			request.reject(`[MIDDLEWARE_REJECTED] {serviceName}.{name} response was rejected`)
		else
			request.resolve(table.unpack(filteredValues, 1, filteredValues.n))
		end
	end)
	errorPacket.listen(function(response)
		local request = takePending(response.id, true)
		if not request then
			return
		end
		request.reject(`[{safeError(response.code)}] {safeError(response.message)}`)
	end)

	return function(_service, ...)
		if inFlight >= DEFAULT_MAX_IN_FLIGHT then
			return Promise.reject(`[OVERLOADED] {serviceName}.{name} has too many requests in flight`)
		end
		local id = nextRequestId()
		local middlewareSucceeded, allowed, args =
			pcall(NetworkPolicy.RunMiddleware, outboundMiddleware, nil, table.pack(...))
		if not middlewareSucceeded then
			return Promise.reject(`[MIDDLEWARE_ERROR] {safeError(allowed)}`)
		elseif not allowed then
			return Promise.reject(`[MIDDLEWARE_REJECTED] {serviceName}.{name} request was rejected`)
		end

		local timeout = endpoint.timeout or DEFAULT_TIMEOUT
		return Promise.new(function(resolve, reject, onCancel)
			inFlight += 1
			pending[id] = {
				resolve = resolve,
				reject = reject,
				timeoutThread = nil,
			}
			onCancel(function()
				takePending(id, true)
			end)

			local timeoutThread = task.delay(timeout, function()
				local request = takePending(id, false)
				if request then
					reject(`[TIMEOUT] {serviceName}.{name} exceeded {timeout} seconds`)
				end
			end)
			local request = pending[id]
			if request then
				request.timeoutThread = timeoutThread
			else
				task.cancel(timeoutThread)
			end

			requestPacket.send({
				id = id,
				payload = encode(requestDescriptor, args),
			})
		end)
	end
end

function Runtime.StartClient(options: any?): ()
	assert(RunService:IsClient(), "StartClient can only run on the client")
	NetworkPolicy.ValidateMiddleware(options and options.Middleware, "Nerve client middleware")
	if options and type(options.PerServiceMiddleware) == "table" then
		for serviceName, middleware in options.PerServiceMiddleware do
			NetworkPolicy.ValidateMiddleware(middleware, `Service "{serviceName}" client middleware`)
		end
	end

	local manifestValue = ReplicatedStorage:WaitForChild(MANIFEST_NAME, 30)
	assert(manifestValue and manifestValue:IsA("StringValue"), "Nerve ByteNet manifest was not published by the server")
	local decoded = HttpService:JSONDecode(manifestValue.Value)
	assert(
		type(decoded) == "table" and decoded.version == 1 and type(decoded.services) == "table",
		"Nerve ByteNet manifest is invalid"
	)
	clientManifest = decoded :: Manifest
	clientPackets = definePackets(clientManifest :: Manifest)
	clientOptions = options
end

function Runtime.GetClientService(serviceName: string): any
	local existing = clientServices[serviceName]
	if existing then
		return existing
	end
	assert(clientManifest and clientPackets, "Nerve ByteNet client runtime has not started")
	local endpoints = (clientManifest :: Manifest).services[serviceName]
	assert(endpoints, `Could not find networked service "{serviceName}"`)
	local service = {}
	local perServiceMiddleware = if clientOptions and type(clientOptions.PerServiceMiddleware) == "table"
		then clientOptions.PerServiceMiddleware[serviceName]
		else nil
	local middleware = NetworkPolicy.ResolveMiddleware(clientOptions and clientOptions.Middleware, perServiceMiddleware)
	for name, endpoint in endpoints do
		if endpoint.kind == "method" then
			service[name] =
				makeClientMethod(endpoint, clientPackets :: { [string]: any }, serviceName, name, middleware)
		else
			service[name] =
				makeClientSignal(endpoint, clientPackets :: { [string]: any }, serviceName, name, middleware)
		end
	end
	clientServices[serviceName] = service
	return service
end

return Runtime
