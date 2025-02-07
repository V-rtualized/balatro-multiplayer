MP.FUNCS.START_BLIND_ON_RECEIVE = function(self, action, parameters, from)
	if MP.game_state.ready_blind_context then
		G.FUNCS.select_blind(MP.game_state.ready_blind_context)
	end

	MP.GAME_PLAYERS.all_unready()

	return true
end

MP.ACTIONS.START_BLIND = MPAPI.NetworkActionType({
	key = "start_blind",
	parameters = {},
	on_receive = MP.FUNCS.START_BLIND_ON_RECEIVE,
})
