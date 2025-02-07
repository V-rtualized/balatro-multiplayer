MPAPI.FUNCS.ERROR_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.send_error_message("Received error message from " .. from .. ": " .. parameters.message)
end

-- NOT INTENDED TO BE SENT
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
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
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
	callback_parameters = {
		{
			key = "username",
			type = "string",
			required = true,
		},
		{
			key = "code",
			type = "string",
			required = true,
		},
	},
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.CONNECT_CALLBACK = function(self, msg)
	MPAPI.network_state.connected = true
	MPAPI.network_state.code = msg.code
	MPAPI.network_state.username = msg.username

	if MPAPI.FUNCS.draw_lobby_ui then
		MPAPI.FUNCS.draw_lobby_ui()
	end
end

MPAPI.ACTIONS.SET_USERNAME_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "set_username",
	parameters = {
		{
			key = "username",
			type = "string",
			required = true,
		},
	},
	callback_parameters = {
		{
			key = "username",
			type = "string",
			required = true,
		},
	},
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.SET_USERNAME_CALLBACK = function(self, msg)
	MPAPI.network_state.username = msg.username
end

MPAPI.ACTIONS.OPEN_LOBBY_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "open_lobby",
	parameters = {},
	callback_parameters = {},
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.OPEN_LOBBY_CALLBACK = function(self, msg)
	MPAPI.network_state.lobby = MPAPI.network_state.code
	MPAPI.network_state.players_by_code[MPAPI.network_state.code] = {
		code = MPAPI.network_state.code,
		username = MPAPI.network_state.username,
	}
	MPAPI.network_state.players_by_index[1] = MPAPI.network_state.players_by_code[MPAPI.network_state.code] -- Assigns pointer, not value

	if MPAPI.FUNCS.draw_lobby_ui then
		MPAPI.FUNCS.draw_lobby_ui()
	end
end

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
	callback_parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
		{
			key = "players",
			type = "table",
			required = true,
		},
	},
	on_error = function(self, action, err)
		if action.sent_params and action.sent_params.checking and MPAPI.UI then
			MPAPI.UI.create_join_lobby_overlay()
		elseif err and err.message then
			MPAPI.send_error_message("ERROR :: " .. err.message)
		end
	end,
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.JOIN_LOBBY_CALLBACK = function(self, msg)
	MPAPI.network_state.lobby = msg.code

	for _, v in pairs(msg.players) do
		MPAPI.add_player(v)
	end

	if MPAPI.FUNCS.draw_lobby_ui then
		MPAPI.FUNCS.draw_lobby_ui()
	end
end

MPAPI.ACTIONS.LEAVE_LOBBY_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "leave_lobby",
	parameters = {},
	callback_parameters = {},
	prefix_config = { key = { mod = false } },
})

MPAPI.FUNCS.LEAVE_LOBBY_CALLBACK = function(self, msg)
	MPAPI.network_state.lobby = nil
	MPAPI.network_state.players_by_code = {}
	MPAPI.network_state.players_by_index = {}

	if MPAPI.FUNCS.draw_lobby_ui then
		MPAPI.FUNCS.draw_lobby_ui()
	end
end

MPAPI.FUNCS.PLAYER_JOINED_ON_RECEIVE = function(self, action, parameters, from)
	if not MPAPI.is_in_lobby() then
		return
	end
	local player = {
		code = parameters.code,
		username = parameters.username,
	}
	MPAPI.add_player(player)
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
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.PLAYER_LEFT_ON_RECEIVE = function(self, action, parameters, from)
	local player = {
		code = parameters.code,
	}
	MPAPI.remove_player(player)
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
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.HOST_MIGRATION_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.network_state.lobby = parameters.code
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
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})

MPAPI.FUNCS.DISCONNECTED_ON_RECEIVE = function(self, action, parameters, from)
	MPAPI.network_state.connected = false
	MPAPI.network_state.code = nil
	MPAPI.network_state.lobby = nil
	MPAPI.network_state.players_by_code = {}
	MPAPI.network_state.players_by_index = {}
	MPAPI.network_state.username = ""
	MPAPI.send_info_message("Disconnected")

	if MPAPI.FUNCS.draw_lobby_ui then
		MPAPI.FUNCS.draw_lobby_ui()
	end
end

-- NOT INTENDED TO BE SENT
MPAPI.ACTIONS.HOST_MIGRATION_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "disconnected",
	parameters = {},
	on_receive = MPAPI.FUNCS.DISCONNECTED_ON_RECEIVE,
	prefix_config = { key = { mod = false } }, -- Don't do this, this is so the server recongizes the command, you don't need the server to recognize your command
})
