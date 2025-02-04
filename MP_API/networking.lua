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

		waiting_action.has_responsed = true

		if waiting_action.callback_func then
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

function MPAPI.initialize(ignore_server_constants)
	if not MPAPI.NETWORKING_THREAD then
		local SOCKET = MPAPI.load_file("server.lua")
		MPAPI.NETWORKING_THREAD = love.thread.newThread(SOCKET)
		MPAPI.NETWORKING_THREAD:start(MPAPI.server_config.url, MPAPI.server_config.port)

		MPAPI.send_raw("connect")

		if not ignore_server_constants then
			MPAPI.load_file("server_constants.lua")
		end

		MPAPI.send_raw("connect")
	end
end
