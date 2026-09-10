--!strict

local root = script.Parent
local Bootstrap = require(root.Bootstrap)

if not Bootstrap.IsEnabled(root, "AutoStartServer") then
	return
end

local Nerve = require(root)
local services, servicesPath, wasConfigured =
	Bootstrap.ResolvePath(root, "ServerServicesPath", "ServerScriptService.Services")

if services then
	if root:GetAttribute("DeepServiceDiscovery") == true then
		Nerve.AddServicesDeep(services)
	else
		Nerve.AddServices(services)
	end
elseif wasConfigured then
	warn(`[Nerve] ServerServicesPath "{servicesPath}" could not be resolved; starting without services`)
end

Nerve.Start():catch(function(message)
	warn(`[Nerve] Server startup failed: {tostring(message)}`)
end)
