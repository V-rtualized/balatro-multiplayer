MP.FUNCS.START_RUN_ON_RECEIVE = function(self, action, parameters, from)
	local parsed_choices = parameters.choices
	local parsed_players = parameters.game_players
	local parsed_lobby_config = parameters.lobby_config
	MP.lobby_state.config = parsed_lobby_config
	MP.GAME_PLAYERS.copy_players(parsed_players)
	G.FUNCS.start_run(nil, parsed_choices)

	return true
end

MP.ACTIONS.START_RUN = MPAPI.NetworkActionType({
	key = "start_run",
	parameters = {
		{
			key = "choices",
			type = "table",
			required = true,
		},
		{
			key = "game_players",
			type = "table",
			required = true,
		},
		{
			key = "lobby_config",
			type = "table",
			required = true,
		},
	},
	on_receive = MP.FUNCS.START_RUN_ON_RECEIVE,
})
