MP.FUNCS.LOSE_LIFE_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_lives(parameters.player, MP.GAME_PLAYERS.BY_CODE[parameters.player].lives - 1)

	if MPAPI.get_code() == parameters.player then
		MP.game_state.comeback_bonus_given = false
		MP.game_state.comeback_bonus = MP.game_state.comeback_bonus + 1
		ease_lives(-1)
		MP.game_state.failed = true
		if MP.GAME_PLAYERS.BY_CODE[MPAPI.get_code()].lives == 0 then
			MP.game_over()
		end
	end

	if MPAPI.is_host() then
		local alive_players = MP.GAME_PLAYERS.get_alive()
		if #alive_players == 1 then
			local action = MPAPI.NetworkAction(MP.ACTIONS.WIN)
			action:send(alive_players[1].code, {})
		end
	end

	return true
end

MP.ACTIONS.LOSE_LIFE = MPAPI.NetworkActionType({
	key = "lose_life",
	parameters = {
		{
			key = "player",
			type = "string",
			required = true,
		},
	},
	on_receive = MP.FUNCS.LOSE_LIFE_ON_RECEIVE,
})
