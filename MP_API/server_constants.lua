MPAPI.FUNCS.ERROR_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.send_error_message("Received error message from " .. from .. ": " .. parameters.message)
end

MPAPI.ACTIONS.ERROR_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "error",
	parameters = {
		{
			key = "message",
			type = "string",
			required = true,
		},
	},
	on_receive = MPAPI.FUNCS.ERROR_ON_RECEIVE,
	prefix_config = { key = { mod = false } },
})

MPAPI.ACTIONS.CONNECT_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "connect",
	parameters = {
		{
			key = "username",
			type = "string",
			required = true,
		},
	},
	prefix_config = { key = { mod = false } },
})

MPAPI.ACTIONS.SET_USERNAME_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "set_username",
	parameters = {
		{
			key = "username",
			type = "string",
			required = true,
		},
	},
	prefix_config = { key = { mod = false } },
})

MPAPI.ACTIONS.OPEN_LOBBY_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "open_lobby",
	parameters = {},
})

MPAPI.ACTIONS.JOIN_LOBBY_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "join_lobby",
	parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
		{
			key = "checking",
			type = "boolean",
		},
	},
	prefix_config = { key = { mod = false } },
})

MPAPI.ACTIONS.LEAVE_LOBBY_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "leave_lobby",
	parameters = {},
	prefix_config = { key = { mod = false } },
})

MPAPI.FUNCS.PLAYER_JOINED_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.send_info_message("Player joined: " .. parameters.username .. " (" .. parameters.code .. ")")
end

-- NOT INTENDED TO BE SENT
MPAPI.ACTIONS.PLAYER_JOINED_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "player_joined",
	parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
		{
			key = "username",
			type = "string",
			required = true,
		},
	},
	on_receive = MPAPI.FUNCS.PLAYER_JOINED_ON_RECEIVE,
	prefix_config = { key = { mod = false } },
})

MPAPI.FUNCS.PLAYER_LEFT_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.send_info_message("Player left: " .. parameters.code)
end

-- NOT INTENDED TO BE SENT
MPAPI.ACTIONS.PLAYER_LEFT_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "player_left",
	parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
	},
	on_receive = MPAPI.FUNCS.PLAYER_LEFT_ON_RECEIVE,
	prefix_config = { key = { mod = false } },
})

MPAPI.FUNCS.HOST_MIGRATION_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.send_info_message("Host Migrated to " .. parameters.code)
end

-- NOT INTENDED TO BE SENT
MPAPI.ACTIONS.HOST_MIGRATION_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "host_migration",
	parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
	},
	on_receive = MPAPI.FUNCS.HOST_MIGRATION_ON_RECEIVE,
	prefix_config = { key = { mod = false } },
})

MPAPI.FUNCS.DISCONNECTED_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.send_info_message("Disconnected")
end

-- NOT INTENDED TO BE SENT
MPAPI.ACTIONS.HOST_MIGRATION_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "disconnected",
	parameters = {},
	on_receive = MPAPI.FUNCS.DISCONNECTED_ON_RECEIVE,
	prefix_config = { key = { mod = false } },
})
