--[=[
	@interface Middleware
	.Inbound ServerMiddleware?
	.Outbound ServerMiddleware?
	@within NerveServer

	Server middleware applied to client-originated requests/signals and
	server-originated responses/signals.
]=]
type Middleware = {
	Inbound: ServerMiddleware?,
	Outbound: ServerMiddleware?,
}

--[=[
	@type ServerMiddlewareFn (player: Player, args: {any}) -> (shouldContinue: boolean, ...: any)
	@within NerveServer

	Return `true` to preserve the current arguments, `true, ...` to replace
	them, or `false` to reject the method traffic or drop the signal.
]=]
type ServerMiddlewareFn = (player: Player, args: { any }) -> (boolean, ...any)

--[=[
	@type ServerMiddleware {ServerMiddlewareFn}
	@within NerveServer
	An array of server middleware functions.
]=]
type ServerMiddleware = { ServerMiddlewareFn }

--[=[
	@interface ServiceDef
	.Name string
	.Client table?
	.Middleware Middleware?
	.[any] any
	@within NerveServer
	Used to define a service when creating it in `CreateService`.
	Service middleware replaces Nerve-level server middleware for this service.
]=]
type ServiceDef = {
	Name: string,
	Client: { [any]: any }?,
	Middleware: Middleware?,
	[any]: any,
}

--[=[
	@interface Service
	.Name string
	.Client ServiceClient
	.[any] any
	@within NerveServer
]=]
type Service = {
	Name: string,
	Client: ServiceClient,
	[any]: any,
}

--[=[
	@interface ServiceClient
	.Server Service
	.[any] any
	@within NerveServer
]=]
type ServiceClient = {
	Server: Service,
	[any]: any,
}

--[=[
	@interface NerveServerOptions
	.Middleware Middleware?
	@within NerveServer

	Global server middleware used by services without their own middleware.
]=]
type NerveServerOptions = {
	Middleware: Middleware?,
}

local defaultOptions: NerveServerOptions = {
	Middleware = nil,
}

local selectedOptions = nil

--[=[
	@class NerveServer
	@server

	The server API creates services, runs their lifecycle, and exposes typed
	ByteNet methods and signals to clients.

	```lua
	local Nerve = require(somewhere.Nerve)

	-- Load service modules within some folder:
	Nerve.AddServices(somewhere.Services)

	-- Start Nerve:
	Nerve.Start():andThen(function()
		print("Nerve started")
	end):catch(warn)
	```
]=]
local NerveServer = {}

--[=[
	@prop Version string
	@within NerveServer
	@readonly

	The installed Nerve version.
]=]
NerveServer.Version = "1.3.0"

--[=[
	@prop Dependencies Folder
	@within NerveServer
	@readonly

	The folder containing Nerve's bundled runtime dependencies. Prefer
	[NerveServer:GetDependency] when the ModuleScript instance is not required.
]=]
NerveServer.Dependencies = script.Parent.Dependencies

--[=[
	@prop Util Folder
	@within NerveServer
	@readonly
	@deprecated 1.0.0 -- Use `Dependencies` or `GetDependency`.

	Compatibility alias for [NerveServer.Dependencies].
]=]
NerveServer.Util = NerveServer.Dependencies

local Promise = require(NerveServer.Dependencies.Promise)
local ByteNetRuntime = require(script.Parent.Runtime)
local Lifecycle = require(script.Parent.Lifecycle)
local Schema = require(script.Parent.Schema)

NerveServer.Schema = Schema
NerveServer.ByteNet = require(NerveServer.Dependencies.ByteNet)
NerveServer.Promise = Promise
NerveServer.SignalClass = require(NerveServer.Dependencies.Signal)

--[=[
	Lazily requires one of Nerve's bundled utilities by name.

	@param name string -- For example, `"ProfileStore"` or `"Trove"`.
	@return any
	@tag dependencies
]=]
function NerveServer.GetDependency(name: string): any
	assert(type(name) == "string" and name ~= "", "dependency name must be a non-empty string")
	local dependency = NerveServer.Dependencies:FindFirstChild(name)
	assert(dependency and dependency:IsA("ModuleScript"), `Unknown Nerve dependency "{name}"`)
	return require(dependency)
end

--[=[
	@function Method
	@within NerveServer
	@server

	Defines a typed client-to-server request/response contract. Place the result
	in a service's `Network` table using the same name as its `Client` method.

	@param options {Request: Descriptor?, Response: Descriptor?, Timeout: number?, RateLimit: ({Requests: number, Window: number} | false)?}?
	@return any
	@tag networking
]=]
NerveServer.Method = ByteNetRuntime.Method

--[=[
	@function Signal
	@within NerveServer
	@server

	Defines a typed ByteNet signal. Signals are reliable and server-to-client by
	default. Place the marker directly in the service's `Client` table. Set
	`Direction` to `"client"` or `"duplex"` only when needed.

	@param arguments Descriptor? -- Tuple descriptor for signal arguments.
	@param options {Direction: string?, Reliability: string?, RateLimit: ({Requests: number, Window: number} | false)?}?
	@return any
	@tag networking
]=]
NerveServer.Signal = ByteNetRuntime.Signal

local services: { [string]: Service } = {}
local started = false
local startedComplete = false
local startFailed = false
local startFailure = nil
local startPromise = nil
local startWaiters = {}

local function settleStartWaiters(succeeded: boolean, reason: any?)
	for _, waiter in startWaiters do
		if succeeded then
			waiter.Resolve()
		else
			waiter.Reject(reason)
		end
	end

	table.clear(startWaiters)
end

local function DoesServiceExist(serviceName: string): boolean
	local service: Service? = services[serviceName]

	return service ~= nil
end

--[=[
	Constructs a new service.

	:::caution
	Services must be created _before_ calling `Nerve.Start()`.
	:::
	```lua
	-- Create a service
	local MyService = Nerve.CreateService {
		Name = "MyService",
		Client = {},
	}

	-- Expose a ToAllCaps remote function to the clients
	function MyService.Client:ToAllCaps(player, msg)
		return msg:upper()
	end

	-- Nerve will call NerveStart after all services have been initialized
	function MyService:NerveStart()
		print("MyService started")
	end

	-- Nerve will call NerveInit when Nerve is first started
	function MyService:NerveInit()
		print("MyService initialize")
	end
	```
	@tag lifecycle
]=]
function NerveServer.CreateService(serviceDef: ServiceDef): Service
	assert(type(serviceDef) == "table", `Service must be a table; got {type(serviceDef)}`)
	assert(type(serviceDef.Name) == "string", `Service.Name must be a string; got {type(serviceDef.Name)}`)
	assert(#serviceDef.Name > 0, "Service.Name must be a non-empty string")
	assert(not DoesServiceExist(serviceDef.Name), `Service "{serviceDef.Name}" already exists`)
	assert(not started, `Services cannot be created after calling "Nerve.Start()"`)

	local service = serviceDef

	if type(service.Client) ~= "table" then
		service.Client = { Server = service }
	else
		if service.Client.Server ~= service then
			service.Client.Server = service
		end
	end

	services[service.Name] = service

	return service
end

--[=[
	Requires all the modules that are children of the given parent. This is an easy
	way to quickly load all services that might be in a folder.
	```lua
	Nerve.AddServices(somewhere.Services)
	```
	@tag discovery
]=]
function NerveServer.AddServices(parent: Instance): { Service }
	assert(not started, `Services cannot be added after calling "Nerve.Start()"`)

	local addedServices = {}
	for _, v in parent:GetChildren() do
		if not v:IsA("ModuleScript") then
			continue
		end

		table.insert(addedServices, require(v))
	end

	return addedServices
end

--[=[
	Requires all the modules that are descendants of the given parent.
	@tag discovery
]=]
function NerveServer.AddServicesDeep(parent: Instance): { Service }
	assert(not started, `Services cannot be added after calling "Nerve.Start()"`)

	local addedServices = {}
	for _, v in parent:GetDescendants() do
		if not v:IsA("ModuleScript") then
			continue
		end

		table.insert(addedServices, require(v))
	end

	return addedServices
end

--[=[
	Gets the service by name. Throws an error if the service is not found.
	@tag discovery
]=]
function NerveServer.GetService(serviceName: string): Service
	assert(started, "Cannot call GetService until Nerve has been started")
	assert(type(serviceName) == "string", `ServiceName must be a string; got {type(serviceName)}`)

	return assert(services[serviceName], `Could not find service "{serviceName}"`) :: Service
end

--[=[
	Gets a table of all services.
	@tag discovery
]=]
function NerveServer.GetServices(): { [string]: Service }
	assert(started, "Cannot call GetServices until Nerve has been started")

	return services
end

--[=[
	Compatibility alias for [NerveServer.Signal]. Define signals directly in the
	service's `Client` table.

	@param arguments Descriptor?
	@param options table?
	@return any
	@tag networking
	```lua
	local MyService = Nerve.CreateService {
		Name = "MyService",
		Client = {
			MySignal = Nerve.CreateSignal(Nerve.Schema.Tuple({Nerve.Schema.String})),
		},
	}

	function MyService:NerveInit()
		self.Client.MySignal:FireAll("Ready")
	end
	```
]=]
function NerveServer.CreateSignal(arguments, options)
	return ByteNetRuntime.Signal(arguments, options)
end

--[=[
	Defines a signal using unreliable, unordered transport. Use this for
	frequently replaced state such as aim or cosmetic transforms, never for
	critical gameplay events.

	@param arguments Descriptor?
	@param options table?
	@return any
	@tag networking
]=]
function NerveServer.CreateUnreliableSignal(arguments, options)
	local resolved = if type(options) == "table" then table.clone(options) else {}
	resolved.Reliability = "unreliable"
	return ByteNetRuntime.Signal(arguments, resolved)
end

--[=[
	Reserved compatibility marker. Nerve 1.0 does not expose property markers in
	the ByteNet manifest; use a typed method for initial state and a typed signal
	for subsequent changes.

	@param initialValue any
	@return any
	@tag networking
]=]
function NerveServer.CreateProperty(initialValue: any)
	return ByteNetRuntime.Property(initialValue)
end

--[=[
	@return Promise
	Starts Nerve. Should only be called once.

	:::caution
	Be sure that all services have been created _before_
	calling `Start`. Services cannot be added later.
	:::

	```lua
	Nerve.Start():andThen(function()
		print("Nerve started!")
	end):catch(warn)
	```
	@tag lifecycle
]=]
function NerveServer.Start(options: NerveServerOptions?)
	if started then
		return Promise.reject("Nerve already started")
	end

	started = true

	table.freeze(services)

	if options == nil then
		selectedOptions = defaultOptions
	else
		assert(typeof(options) == "table", `NerveOptions should be a table or nil; got {typeof(options)}`)
		selectedOptions = options
		for k, v in defaultOptions do
			if selectedOptions[k] == nil then
				selectedOptions[k] = v
			end
		end
	end

	startPromise = Promise.try(function()
		ByteNetRuntime.StartServer(services, selectedOptions)
	end)
		:andThen(function()
			return Lifecycle.Run(services, "NerveInit", "service", Promise)
		end)
		:andThen(function()
			return Lifecycle.Run(services, "NerveStart", "service", Promise)
		end)
		:andThen(function()
			startedComplete = true
			settleStartWaiters(true)
		end)
		:catch(function(reason)
			startFailed = true
			startFailure = reason
			settleStartWaiters(false, reason)
			return Promise.reject(reason)
		end)

	return startPromise
end

--[=[
	@return Promise
	Returns a promise that is resolved once Nerve has started. This is useful
	for any code that needs to tie into Nerve services but is not the script
	that called `Start`.
	```lua
	Nerve.OnStart():andThen(function()
		local MyService = Nerve.Services.MyService
		MyService:DoSomething()
	end):catch(warn)
	```
	@tag lifecycle
]=]
function NerveServer.OnStart()
	if startedComplete then
		return Promise.resolve()
	elseif startFailed then
		return Promise.reject(startFailure)
	else
		return Promise.new(function(resolve, reject, onCancel)
			local waiter = {
				Resolve = resolve,
				Reject = reject,
			}
			table.insert(startWaiters, waiter)

			onCancel(function()
				local index = table.find(startWaiters, waiter)
				if index then
					table.remove(startWaiters, index)
				end
			end)
		end)
	end
end

return NerveServer
