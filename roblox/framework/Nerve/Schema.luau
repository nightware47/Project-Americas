--!strict

--[=[
	@class Schema

	Builds immutable descriptors for Nerve method and signal payloads.

	Schema descriptors are plain tables. The server serializes them into the
	network manifest, and clients reconstruct identical ByteNet data types without
	receiving server-only service modules.

	```lua
	local S = Nerve.Schema
	local Contract = S.Tuple({
		S.String,
		S.Optional(S.UInt16),
	})
	```
]=]

--[=[
	@type Descriptor {kind: string, [any]: any}
	@within Schema

	An immutable description of a value encoded by Nerve.
]=]
export type Descriptor = {
	kind: string,
	[any]: any,
}

local Schema = {}

local function primitive(kind: string): Descriptor
	return table.freeze({ kind = kind })
end

--[=[
	@prop Packed Descriptor
	@within Schema
	@readonly

	A dynamically encoded tuple. Prefer explicit [Schema:Tuple] descriptors for
	new endpoints.
]=]
Schema.Packed = primitive("packed")

--[=[
	@prop Nothing Descriptor
	@within Schema
	@readonly

	An endpoint with no encoded value.
]=]
Schema.Nothing = primitive("nothing")

--[=[
	@prop Unknown Descriptor
	@within Schema
	@readonly

	A dynamically encoded supported value.
]=]
Schema.Unknown = primitive("unknown")

--[=[
	@prop Boolean Descriptor
	@within Schema
	@readonly
]=]
Schema.Boolean = primitive("bool")

--[=[
	@prop String Descriptor
	@within Schema
	@readonly
]=]
Schema.String = primitive("string")

--[=[
	@prop Buffer Descriptor
	@within Schema
	@readonly
]=]
Schema.Buffer = primitive("buffer")

--[=[
	@prop UInt8 Descriptor
	@within Schema
	@readonly
]=]
Schema.UInt8 = primitive("uint8")

--[=[
	@prop UInt16 Descriptor
	@within Schema
	@readonly
]=]
Schema.UInt16 = primitive("uint16")

--[=[
	@prop UInt32 Descriptor
	@within Schema
	@readonly
]=]
Schema.UInt32 = primitive("uint32")

--[=[
	@prop Int8 Descriptor
	@within Schema
	@readonly
]=]
Schema.Int8 = primitive("int8")

--[=[
	@prop Int16 Descriptor
	@within Schema
	@readonly
]=]
Schema.Int16 = primitive("int16")

--[=[
	@prop Int32 Descriptor
	@within Schema
	@readonly
]=]
Schema.Int32 = primitive("int32")

--[=[
	@prop Float32 Descriptor
	@within Schema
	@readonly
]=]
Schema.Float32 = primitive("float32")

--[=[
	@prop Float64 Descriptor
	@within Schema
	@readonly
]=]
Schema.Float64 = primitive("float64")

--[=[
	@prop Vector2 Descriptor
	@within Schema
	@readonly
]=]
Schema.Vector2 = primitive("vec2")

--[=[
	@prop Vector3 Descriptor
	@within Schema
	@readonly
]=]
Schema.Vector3 = primitive("vec3")

--[=[
	@prop CFrame Descriptor
	@within Schema
	@readonly
]=]
Schema.CFrame = primitive("cframe")

--[=[
	@prop Color3 Descriptor
	@within Schema
	@readonly
]=]
Schema.Color3 = primitive("color3")

--[=[
	@prop Instance Descriptor
	@within Schema
	@readonly
]=]
Schema.Instance = primitive("instance")

local primitives = table.freeze({
	packed = true,
	nothing = true,
	unknown = true,
	bool = true,
	string = true,
	buffer = true,
	uint8 = true,
	uint16 = true,
	uint32 = true,
	int8 = true,
	int16 = true,
	int32 = true,
	float32 = true,
	float64 = true,
	vec2 = true,
	vec3 = true,
	cframe = true,
	color3 = true,
	instance = true,
})

local function assertDescriptor(value: any, label: string): Descriptor
	assert(type(value) == "table" and type(value.kind) == "string", `{label} must be a Nerve schema descriptor`)
	return value
end

--[=[
	Wraps a descriptor so the value may be absent.

	@param value Descriptor -- Descriptor for a present value.
	@return Descriptor
	@tag schema
]=]
function Schema.Optional(value: Descriptor): Descriptor
	return table.freeze({
		kind = "optional",
		value = assertDescriptor(value, "optional value"),
	})
end

--[=[
	Describes a dense array whose elements share one descriptor.

	@param value Descriptor -- Element descriptor.
	@return Descriptor
	@tag schema
]=]
function Schema.Array(value: Descriptor): Descriptor
	return table.freeze({
		kind = "array",
		value = assertDescriptor(value, "array value"),
	})
end

--[=[
	Describes a key/value map.

	@param key Descriptor -- Key descriptor.
	@param value Descriptor -- Value descriptor.
	@return Descriptor
	@tag schema
]=]
function Schema.Map(key: Descriptor, value: Descriptor): Descriptor
	return table.freeze({
		kind = "map",
		key = assertDescriptor(key, "map key"),
		value = assertDescriptor(value, "map value"),
	})
end

--[=[
	Describes a string-keyed record.

	@param fields {[string]: Descriptor} -- Descriptor for each field.
	@return Descriptor
	@tag schema
]=]
function Schema.Struct(fields: { [string]: Descriptor }): Descriptor
	assert(type(fields) == "table", "struct fields must be a table")
	local copy = {}
	for name, descriptor in fields do
		assert(type(name) == "string" and #name > 0, "struct field names must be non-empty strings")
		copy[name] = assertDescriptor(descriptor, `struct field {name}`)
	end
	return table.freeze({
		kind = "struct",
		fields = table.freeze(copy),
	})
end

--[=[
	Describes ordered arguments or return values.

	@param items {Descriptor} -- Dense array of descriptors.
	@return Descriptor
	@tag schema
]=]
function Schema.Tuple(items: { Descriptor }): Descriptor
	assert(type(items) == "table", "tuple items must be an array")
	local copy = {}
	for index, descriptor in items do
		assert(type(index) == "number" and index % 1 == 0 and index >= 1, "tuple items must be a dense array")
		copy[index] = assertDescriptor(descriptor, `tuple item {index}`)
	end
	assert(#copy == #items, "tuple items must be a dense array")
	return table.freeze({
		kind = "tuple",
		items = table.freeze(copy),
	})
end

--[=[
	Recursively validates a descriptor and throws when it is malformed.
	`Nerve.Method` and `Nerve.Signal` call this automatically.

	@param descriptor Descriptor
	@param path string? -- Optional label used in validation errors.
	@tag schema
]=]
function Schema.Validate(descriptor: Descriptor, path: string?): ()
	local currentPath = path or "schema"
	assertDescriptor(descriptor, currentPath)
	local kind = descriptor.kind
	if primitives[kind] then
		return
	end
	if kind == "optional" or kind == "array" then
		Schema.Validate(descriptor.value, `{currentPath}.value`)
		return
	end
	if kind == "map" then
		Schema.Validate(descriptor.key, `{currentPath}.key`)
		Schema.Validate(descriptor.value, `{currentPath}.value`)
		return
	end
	if kind == "struct" then
		assert(type(descriptor.fields) == "table", `{currentPath}.fields must be a table`)
		for name, value in descriptor.fields do
			assert(type(name) == "string", `{currentPath} contains a non-string field name`)
			Schema.Validate(value, `{currentPath}.{name}`)
		end
		return
	end
	if kind == "tuple" then
		assert(type(descriptor.items) == "table", `{currentPath}.items must be an array`)
		for index, value in descriptor.items do
			Schema.Validate(value, `{currentPath}[{index}]`)
		end
		return
	end
	error(`Unsupported Nerve schema kind "{tostring(kind)}" at {currentPath}`, 2)
end

return table.freeze(Schema)
