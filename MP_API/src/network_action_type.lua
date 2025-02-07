MPAPI.NetworkActionTypes = {}
MPAPI.NetworkActionType = SMODS.GameObject:extend({
	obj_table = MPAPI.NetworkActionTypes,
	obj_buffer = {},
	required_params = {
		"key",
	},
	callback_parameters = {},
	class_prefix = "netaction",
	parameters = {},
	pre_send = function(self, action, parameters) end,
	post_send = function(self, action, parameters) end,
	on_receive = function(self, action, parameters, from)
		return true
	end,
	on_error = function(self, action, err)
		if err and err.message then
			MPAPI.send_error_message("ERROR :: " .. err.message)
		else
			MPAPI.send_error_message("ERROR :: " .. message_to_string(err))
		end
	end,
	max_retry_attempts = 5,
})

function MPAPI.NetworkActionType:inject() end

function MPAPI.NetworkActionType:process_loc_text() end
