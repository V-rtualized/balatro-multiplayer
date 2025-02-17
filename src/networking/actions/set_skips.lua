MP.FUNCS.SET_SKIPS_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_skips(from, parameters.skips)

	return true
end

MP.ACTIONS.SET_SKIPS = MPAPI.NetworkActionType({
	key = "set_skips",
	parameters = {
		{
			key = "skips",
			type = "number",
			required = true,
		},
	},
	on_receive = MP.FUNCS.SET_SKIPS_ON_RECEIVE,
})
