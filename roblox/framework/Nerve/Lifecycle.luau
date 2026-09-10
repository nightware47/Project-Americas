--!strict

type LifecycleObject = {
	Name: string,
	[any]: any,
}

local Lifecycle = {}

local function getSortedObjects(objects: { [string]: LifecycleObject }): { LifecycleObject }
	local names = {}

	for name in objects do
		table.insert(names, name)
	end

	table.sort(names)

	local sortedObjects = table.create(#names)
	for _, name in names do
		table.insert(sortedObjects, objects[name])
	end

	return sortedObjects
end

function Lifecycle.Run(
	objects: { [string]: LifecycleObject },
	methodName: string,
	objectKind: string,
	Promise: any
): any
	local phasePromises = {}

	for _, object in getSortedObjects(objects) do
		local lifecycleMethod = object[methodName]
		if type(lifecycleMethod) ~= "function" then
			continue
		end

		table.insert(
			phasePromises,
			Promise.try(function()
				debug.setmemorycategory(object.Name)
				return lifecycleMethod(object)
			end):catch(function(reason)
				return Promise.reject(
					`[Nerve] {objectKind} "{object.Name}" failed during {methodName}: {tostring(reason)}`
				)
			end)
		)
	end

	return Promise.all(phasePromises)
end

return table.freeze(Lifecycle)
