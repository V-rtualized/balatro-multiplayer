function MPAPI.send_raw(msg, param_config)
	local raw_msg
	if type(msg) == "table" then
		raw_msg = MPAPI.serialize_networking_message(msg, param_config)
	else
		raw_msg = msg
	end

	MPAPI.send_trace_message("SENDING :: " .. raw_msg)
	MPAPI.ui_to_network_channel:push(raw_msg)
end

function MPAPI.handle_network_message(msg_str)
	if msg_str == "action:keep_alive_ack" then
		return
	end

	MPAPI.send_trace_message("RECEIVED :: " .. msg_str)

	local msg = MPAPI.parse_networking_message(msg_str)

	if not msg.action then
		MPAPI.send_error_message("Received message with no action type")
		return
	end

	if not msg.from then
		MPAPI.send_error_message("Received message with no sender")
		return
	end

	if msg.id and MPAPI.WaitingActions[msg.id] then
		local waiting_action = MPAPI.WaitingActions[msg.id]

		waiting_action.has_acked = true

		if MPAPI.ACTIONS and MPAPI.ACTIONS.ERROR_ACTION_TYPE and msg.action == MPAPI.ACTIONS.ERROR_ACTION_TYPE.key then
			waiting_action.action_type.on_error(waiting_action.action_type, waiting_action, msg)
			MPAPI.WaitingActions[msg.id] = nil
			return
		end

		if
			waiting_action.callback_func
			and MPAPI.valid_parameters(msg, waiting_action.action_type.callback_parameters, function(err_msg)
				MPAPI.send_error_message("Invalid callback parameters in response message: " .. err_msg)
			end)
		then
			waiting_action.has_responsed = true
			waiting_action.callback_func(waiting_action, msg)
		end

		MPAPI.WaitingActions[msg.id] = nil
		return
	end

	local action_type = MPAPI.NetworkActionTypes[msg.action]
	if not action_type then
		MPAPI.send_error_message("Received message with unknown action type: " .. msg.action)
		return
	end

	local received_action = MPAPI.NetworkAction(action_type)
	received_action.key = msg.id or received_action.key
	received_action.is_sent = true
	received_action.has_responsed = true

	local parameters = MPAPI.deep_copy(msg)
	parameters.action = nil
	parameters.id = nil
	parameters.from = nil
	parameters.to = nil

	if
		not MPAPI.valid_parameters(parameters, action_type.parameters, function(err_msg)
			MPAPI.send_error_message("Invalid parameters in received message: " .. err_msg)
		end)
	then
		return
	end

	local result = action_type:on_receive(received_action, parameters, msg.from)

	if not msg.to then
		return
	end

	if result == true then
		local ack_msg = {
			action = msg.action .. "_ack",
			id = msg.id,
			to = msg.from,
			from = MPAPI.self_code,
		}
		MPAPI.send_raw(ack_msg)
	elseif type(result) == "table" then
		local response_msg = MPAPI.deep_copy(result)
		response_msg.id = msg.id
		response_msg.to = msg.from
		response_msg.from = MPAPI.self_code
		MPAPI.send_raw(response_msg)
	end
end

MPAPI.EVENTS.handles_messages = Event({
	trigger = "immediate",
	blockable = false,
	blocking = false,
	no_delete = true,
	func = function()
		repeat
			local msg = MPAPI.network_to_ui_channel:pop()
			if msg then
				local success, error = pcall(function()
					MPAPI.handle_network_message(msg)
				end)

				if not success then
					MPAPI.send_error_message("Error processing message: " .. tostring(error))
				end
			end
		until not msg
	end,
})

G.E_MANAGER:add_event(MPAPI.EVENTS.handles_messages)

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

function MPAPI.reconnect_to_server()
	MPAPI.send_raw("connect")
end

function MPAPI.initialize(ignore_server_constants, disable_ui)
	if not MPAPI.server_config.url or not MPAPI.server_config.port then
		MPAPI.send_error_message("Attempted to initialize MultiplayerAPI without setting a url and port")
		return
	end
	if not MPAPI.NETWORKING_THREAD then
		local SOCKET = MPAPI.load_file("src/server.lua")
		MPAPI.NETWORKING_THREAD = love.thread.newThread(SOCKET)
		MPAPI.NETWORKING_THREAD:start(MPAPI.server_config.url, MPAPI.server_config.port)

		if not ignore_server_constants then
			MPAPI.load_file("src/server_constants.lua")
			if not disable_ui then
				MPAPI.load_file("src/ui.lua")
			end
		end
	end

	if MPAPI.FUNCS.reconnect then
		MPAPI.FUNCS.reconnect()
	else
		MPAPI.reconnect_to_server()
	end
end
