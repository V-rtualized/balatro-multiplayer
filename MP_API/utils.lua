MPAPI.SHOW_DEBUG_MESSAGES = true

function message_to_string(message)
	if type(message) == "table" or type(message) == "function" then
		message = serialize(message)
	end
	if type(message) == "number" or type(message) == "boolean" then
		message = tostring(message)
	end
	return message
end

function MPAPI.send_debug_message(message)
	if MPAPI.SHOW_DEBUG_MESSAGES then
		sendDebugMessage(message_to_string(message), "MultiplayerAPI")
	end
end

function MPAPI.send_warn_message(message)
	if MPAPI.SHOW_DEBUG_MESSAGES then
		sendWarnMessage(message_to_string(message), "MultiplayerAPI")
	end
end

function MPAPI.send_error_message(message)
	sendErrorMessage(message_to_string(message), "MultiplayerAPI")
end

function MPAPI.send_trace_message(message)
	if MPAPI.SHOW_DEBUG_MESSAGES then
		sendTraceMessage(message_to_string(message), "MultiplayerAPI")
	end
end

function MPAPI.send_info_message(message)
	sendInfoMessage(message_to_string(message), "MultiplayerAPI")
end

-- Credit: https://gist.github.com/tylerneylon/81333721109155b2d244
function MPAPI.deep_copy(obj, seen)
	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end

	-- New table; mark it as seen and copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in pairs(obj) do
		res[MPAPI.deep_copy(k, s)] = MPAPI.deep_copy(v, s)
	end
	return setmetatable(res, getmetatable(obj))
end

function MPAPI.add_event(event)
	G.E_MANAGER:add_event(event)
end

MPAPI.RESERVED_KEYS = {
	id = "string",
	action = "string",
	code = "string",
	to = "string",
	from = "string",
}

local function encode_value(val, param_type)
	if val == nil then
		return "n"
	elseif param_type == "bignum" then
		if type(val) == "number" then
			return "d" .. tostring(val) .. "#"
		else
			local parts = {}
			for k, v in pairs(val) do
				parts[#parts + 1] = encode_value(k)
				parts[#parts + 1] = encode_value(v)
			end
			return "g" .. table.concat(parts) .. "e"
		end
	elseif type(val) == "string" then
		return "s" .. val .. "#"
	elseif type(val) == "number" then
		return "d" .. tostring(val) .. "#"
	elseif type(val) == "boolean" then
		return "b" .. (val and "1" or "0")
	elseif type(val) == "table" then
		local parts = {}
		for k, v in pairs(val) do
			parts[#parts + 1] = encode_value(k)
			parts[#parts + 1] = encode_value(v)
		end
		return "t" .. table.concat(parts) .. "e"
	end
end

local function decode_value(str)
	local pos = 1

	local function decode()
		local typ = str:sub(pos, pos)
		pos = pos + 1

		if typ == "n" then
			return nil
		elseif typ == "s" then
			local value = ""
			while pos <= #str and str:sub(pos, pos) ~= "#" do
				value = value .. str:sub(pos, pos)
				pos = pos + 1
			end
			pos = pos + 1 -- Skip the #
			return value
		elseif typ == "d" then
			local value = ""
			while pos <= #str and str:sub(pos, pos) ~= "#" do
				value = value .. str:sub(pos, pos)
				pos = pos + 1
			end
			pos = pos + 1 -- Skip the #
			return tonumber(value)
		elseif typ == "b" then
			local value = str:sub(pos, pos)
			pos = pos + 1
			return value == "1"
		elseif typ == "t" then
			local tbl = {}
			while pos <= #str and str:sub(pos, pos) ~= "e" do
				local key = decode()
				local value = decode()
				tbl[key] = value
			end
			pos = pos + 1 -- Skip the 'e'
			return tbl
		elseif typ == "g" then
			local tbl = {}
			while pos <= #str and str:sub(pos, pos) ~= "e" do
				local key = decode()
				local value = decode()
				tbl[key] = value
			end
			pos = pos + 1 -- Skip the 'e'
			setmetatable(tbl, BigMeta or OmegaMeta)
			return tbl
		end
	end

	return decode()
end

function MPAPI.serialize_networking_message(obj, param_config)
	param_config = param_config or {}
	local parts = {}

	local config_lookup = {}
	for _, conf in ipairs(param_config) do
		config_lookup[conf.key] = conf.type
	end

	local reserved_order = { "action", "id", "code", "to", "from" }
	for _, key in ipairs(reserved_order) do
		if obj[key] then
			table.insert(parts, key .. ":" .. encode_value(obj[key]))
		end
	end

	local sorted_keys = {}
	for key, _ in pairs(obj) do
		if not MPAPI.RESERVED_KEYS[key] then
			table.insert(sorted_keys, key)
		end
	end
	table.sort(sorted_keys)

	for _, key in ipairs(sorted_keys) do
		local value = obj[key]
		local param_type = config_lookup[key]

		if param_type then
			table.insert(parts, key .. ":" .. encode_value(value, param_type))
		end
	end

	return table.concat(parts, ",")
end

function MPAPI.parse_networking_message(str)
	local items = {}

	for item in str:gmatch("[^,]+") do
		local key, value = item:match("([^:]+):(.+)")
		if key and value then
			key = key:gsub("^%s*(.-)%s*$", "%1")
			value = value:gsub("^%s*(.-)%s*$", "%1")

			items[key] = decode_value(value)
		end
	end

	return items
end
