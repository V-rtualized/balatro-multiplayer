MP.FUNCS.WIN_ON_RECEIVE = function(self, action, parameters, from)
	win_game()
	G.GAME.won = true

	return true
end

MP.ACTIONS.WIN = MPAPI.NetworkActionType({
	key = "win",
	parameters = {},
	on_receive = MP.FUNCS.WIN_ON_RECEIVE,
})
