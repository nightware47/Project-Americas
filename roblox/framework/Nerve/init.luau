local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.NerveServer)
else
	return require(script.NerveClient)
end
