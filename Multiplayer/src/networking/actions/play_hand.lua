MP.FUNCS.PLAY_HAND_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_score(from, parameters.score)
	MP.GAME_PLAYERS.set_hands_left(from, parameters.hands_left)

	MP.UI.update_blind_HUD(false)

	return true
end

MP.ACTIONS.PLAY_HAND = MPAPI.NetworkActionType({
	key = "play_hand",
	parameters = {
		{
			key = "score",
			type = "bignum",
			required = true,
		},
		{
			key = "hands_left",
			type = "number",
			required = true,
		},
	},
	on_receive = MP.FUNCS.PLAY_HAND_ON_RECEIVE,
})
