--!strict

local Bootstrap = {}

function Bootstrap.IsEnabled(root: Instance, realmAttribute: string): boolean
	return root:GetAttribute("AutoStart") ~= false and root:GetAttribute(realmAttribute) ~= false
end

function Bootstrap.ResolvePath(root: Instance, attributeName: string, defaultPath: string): (Instance?, string, boolean)
	local configuredPath = root:GetAttribute(attributeName)
	local isConfigured = type(configuredPath) == "string" and configuredPath ~= ""
	local path = if isConfigured then configuredPath :: string else defaultPath
	local current: Instance = game

	for segment in string.gmatch(path, "[^%.]+") do
		if current == game and segment == "game" then
			continue
		end

		local child = current:FindFirstChild(segment)
		if not child then
			return nil, path, isConfigured
		end
		current = child
	end

	return current, path, isConfigured
end

return table.freeze(Bootstrap)
