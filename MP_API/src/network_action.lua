local MAX_INT = 9007199254740991

MPAPI.WaitingActions = {}

function MPAPI.create_netaction_event(action, msg)
	local event
	event = Event({
		trigger = "after",
		blockable = false,
		blocking = false,
		delay = 2,
		pause_force = true,
		timer = "REAL",
		func = function()
			if action.has_acked or action.has_responsed then
				return true
			end

			if action.action_type.max_retry_attempts <= action.retries then
				action.action_type:on_error(action, "Reached max retry attempts")
				return true
			end

			action.retries = action.retries + 1

			MPAPI.send_trace_message("RETRYING :: " .. action.key .. " (Attempt " .. tostring(action.retries) .. ")")

			MPAPI.send_raw(msg)

			event.start_timer = false
		end,
	})
	MPAPI.add_event(event)
end

function MPAPI.valid_parameters(given_params, action_type_params, on_error)
	if action_type_params == nil then
		MPAPI.send_warn_message("Trying to validate parameters with nil action_type_params")
		return false
	end
	for _, v in ipairs(action_type_params) do
		if type(v.key) ~= "string" or type(v.type) ~= "string" then
			on_error("Failed to send netaction: Invalid parameter configuration (" .. v.key .. ")")
			return false
		end

		if v.required and given_params[v.key] == nil then
			on_error("Failed to send netaction: Missing required parameter (" .. v.key .. ")")
			return false
		end

		if
			type(given_params[v.key]) ~= v.type
			or (v.type == "bignum" and type(given_params[v.key]) ~= "table" and type(given_params[v.key]) ~= "number")
		then
			on_error("Failed to send netaction: Given parameter has invalid type (" .. v.key .. ")")
			return false
		end
	end
	return true
end

MPAPI.NetworkAction = Object:extend()

function MPAPI.NetworkAction:init(network_action_type)
	self.key = string.format("%.0f", math.random(MAX_INT))
	self.retries = 0
	self.is_sent = false
	self.has_acked = false
	self.has_responsed = false
	self.callback_func = nil
	self.action_type = network_action_type
	self.retry_event = nil
	self.sent_params = {}
end

function MPAPI.NetworkAction:callback(callback_func)
	if type(callback_func) == "function" then
		self.callback_func = callback_func
	end
end

function MPAPI.NetworkAction:send(recipient_code, parameters)
	parameters = parameters or {}
	self.sent_params = parameters
	local action_key = self.action_type.key

	if self.is_sent then
		MPAPI.send_error_message(
			"Attempted to send " .. message_to_string(action_key) .. " action that has already been sent"
		)
		return
	end

	if type(recipient_code) ~= "string" or recipient_code == "" then
		MPAPI.send_error_message(
			"Attempted to send "
				.. message_to_string(action_key)
				.. " action with an invalid recipient: "
				.. message_to_string(recipient_code)
		)
		return
	end

	self.action_type:pre_send(self, parameters)

	local msg = MPAPI.deep_copy(parameters)

	if
		not MPAPI.valid_parameters(msg, self.action_type.parameters, function(err_msg)
			self.action_type:on_error(self, err_msg)
		end)
	then
		return
	end

	msg.action = action_key
	msg.id = self.key
	msg.to = recipient_code
	msg.from = MPAPI.self_code

	if self.callback_func then
		MPAPI.WaitingActions[self.key] = self
		MPAPI.create_netaction_event(self, msg)
	end

	MPAPI.send_raw(msg, self.action_type.parameters)

	self.action_type:post_send(self, parameters)
end

function MPAPI.NetworkAction:send_to_host(parameters)
	self:send(MPAPI.lobby_host, parameters)
end

function MPAPI.NetworkAction:send_to_server(parameters)
	self:send("SERVER", parameters)
end

function MPAPI.NetworkAction:broadcast(parameters)
	parameters = parameters or {}
	local action_key = self.action_type.key

	self.action_type:pre_send(self, parameters)

	local msg = MPAPI.deep_copy(parameters)

	if
		not MPAPI.valid_parameters(msg, self.action_type.parameters, function(err_msg)
			self.action_type:on_error(self, err_msg)
		end)
	then
		return
	end

	msg.action = action_key
	msg.id = self.key
	msg.from = MPAPI.self_code

	MPAPI.send_raw(msg, self.action_type.parameters)

	self.action_type:post_send(self, parameters)
end

function MPAPI.NetworkAction:get_status()
	return (self.has_responsed and "Responded")
		or (self.has_acked and "Acknowledged")
		or (self.is_sent and "Sent")
		or "Unsent"
end

function MPAPI.NetworkAction:complete()
	MPAPI.WaitingActions[self.key] = nil
	if self.retry_event then
		self.retry_event.completed = true
		self.retry_event = nil
	end
end
