MP.FUNCS.RETURN_TO_LOBBY_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_lives(from, 0)

	return true
end

MP.ACTIONS.RETURN_TO_LOBBY = MPAPI.NetworkActionType({
	key = "return_to_lobby",
	parameters = {},
	on_receive = MP.FUNCS.RETURN_TO_LOBBY_ON_RECEIVE,
})
