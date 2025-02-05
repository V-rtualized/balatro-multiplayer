-- We set the url and port for the server
MPAPI.server_config.url = "localhost"
MPAPI.server_config.port = 6858
-- And then initialize the connection to it
MPAPI.initialize()

-- We override create_lobby_version so that we can insert our mod's version on the lobby UI
-- (Must be after initialization)
create_lobby_version_ref = MPAPI.UI.create_lobby_version
function MPAPI.UI.create_lobby_version(additional_versions)
	additional_versions = additional_versions or {}
	table.insert(additional_versions, "RACE_1.0.0")
	return create_lobby_version_ref(additional_versions)
end

RACE = {
	ACTIONS = {},
	FUNCS = {},
}

-- We want this function to run when someone wins the game
RACE.FUNCS.ON_RECEIVE_WIN_GAME = function(self, action, parameters, from)
	-- Checkes if the given code is our code (because we broadcast to the whole lobby when we win)
	if parameters.code == MPAPI.network_state.code then
		return
	end
	-- Forces game over screen
	G.STATE_COMPLETE = false
	Game:update_game_over()
end

-- We create an action type, this defines the behaviour when someone sends this action
-- This must have a key and parameters, but has many other things we can define about it for more advanced functionality
RACE.ACTIONS.WIN_GAME_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "win_game",
	parameters = {
		{
			key = "code",
			type = "string",
			required = true,
		},
	},
	on_receive = RACE.FUNCS.ON_RECEIVE_WIN_GAME,
})

-- Overrides win_game so we can send the win_game action when this function is called
local win_game_ref = win_game
function win_game()
	win_game_ref()

	-- We create an action using the action type we created
	local action = MPAPI.NetworkAction(RACE.ACTIONS.WIN_GAME_ACTION_TYPE)
	-- We set the code parameter to our code, parameters must match the parameters set in the action type
	local parameters = {
		code = MPAPI.network_state.code,
	}
	-- We broadcast the action to the whole lobby, which will run the defined on_receive function for everyone including ourselves
	action:broadcast(parameters)
end
