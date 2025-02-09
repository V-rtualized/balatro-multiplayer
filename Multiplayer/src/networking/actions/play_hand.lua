MP.FUNCS.PLAY_HAND_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_score(from, parameters.score)
	MP.GAME_PLAYERS.set_hands_left(from, parameters.hands_left)

	MP.game_state.ranking_position = tostring(
		(#MP.GAME_PLAYERS.BY_INDEX - MP.get_br_current_player_score_position()) + 1
	) .. "/" .. tostring(#MP.GAME_PLAYERS.BY_INDEX)
	G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:update_text()
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
