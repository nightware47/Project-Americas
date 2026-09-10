--!strict

local root = script.Parent
local Bootstrap = require(root.Bootstrap)

if not Bootstrap.IsEnabled(root, "AutoStartClient") then
	return
end

local Nerve = require(root)
local controllers, controllersPath, wasConfigured =
	Bootstrap.ResolvePath(root, "ClientControllersPath", "ReplicatedStorage.Client.Controllers")

if controllers then
	if root:GetAttribute("DeepControllerDiscovery") == true then
		Nerve.AddControllersDeep(controllers)
	else
		Nerve.AddControllers(controllers)
	end
elseif wasConfigured then
	warn(`[Nerve] ClientControllersPath "{controllersPath}" could not be resolved; starting without controllers`)
end

Nerve.Start():catch(function(message)
	warn(`[Nerve] Client startup failed: {tostring(message)}`)
end)
