MPAPI.NetworkActionTypes = {}
MPAPI.NetworkActionType = SMODS.GameObject:extend({
	obj_table = MPAPI.NetworkActionTypes,
	obj_buffer = {},
	required_params = {
		"key",
		"parameters",
	},
	class_prefix = "netaction",
	parameters = {},
	pre_send = function(self, action, parameters) end,
	post_send = function(self, action, parameters) end,
	on_receive = function(self, action, parameters, from) end,
	on_error = function(self, action, err) end,
	max_retry_attempts = 5,
})

function MPAPI.NetworkActionType:inject() end

function MPAPI.NetworkActionType:process_loc_text() end

MPAPI.ACTIONS.JOIN_LOBBY_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "join_lobby",
	parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
	},
})
