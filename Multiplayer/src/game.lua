G.STATES.WAITING_ON_ANTE_INFO = 20
G.STATES.WAITING_ON_PVP_END = 21

function MP.update_waiting_on_ante_info(dt)
	if not G.STATE_COMPLETE then
		if not MP.game_state.blinds_by_ante[G.GAME.round_resets.ante] then
			if MPAPI.is_host() then
				MP.generate_blinds_by_ante(G.GAME.round_resets.ante)
			else
				MP.send.request_ante_info()
			end
		end
		G.STATE_COMPLETE = true
	end
	if MP.game_state.blinds_by_ante[G.GAME.round_resets.ante] then
		local choices = MP.game_state.blinds_by_ante[G.GAME.round_resets.ante]
		G.GAME.round_resets.blind_choices.Small = choices[1] and choices[1] or G.GAME.round_resets.blind_choices.Small
		G.GAME.round_resets.blind_choices.Big = choices[2] and choices[2] or G.GAME.round_resets.blind_choices.Big
		G.GAME.round_resets.blind_choices.Boss = choices[3] and choices[3] or G.GAME.round_resets.blind_choices.Boss
		G.STATE = G.STATES.BLIND_SELECT
		G.STATE_COMPLETE = false
	end
end

function MP.update_waiting_on_pvp_end(dt)
	if not G.STATE_COMPLETE then
		G.STATE_COMPLETE = true
	end

	if MP.game_state.end_pvp then
		MP.game_state.end_pvp = false
		G.hand:unhighlight_all()
		G.FUNCS.draw_from_hand_to_deck()
		G.FUNCS.draw_from_discard_to_deck()
		G.STATE = G.STATES.NEW_ROUND
		G.STATE_COMPLETE = false
	end
end

function MP.generate_blinds_by_ante(ante)
	MP.game_state.blinds_by_ante[ante] = MP.GAMEMODES[MP.lobby_state.config.gamemode]:blinds_by_ante(ante)
end

function MP.game_over()
	G.STATE_COMPLETE = false
	Game:update_game_over()
end

function MP.get_br_required_losers(alive_players)
	if #alive_players == 2 then
		return 1
	elseif #MP.GAME_PLAYERS.BY_INDEX > 4 then
		return 2
	else
		return 1
	end
end

function MP.get_br_current_player_score_position(sorted_players_indexes)
	sorted_players_indexes = sorted_players_indexes or MP.GAME_PLAYERS.get_by_score(true)

	local current_player_position = 1
	for i, player_index in ipairs(sorted_players_indexes) do
		if MP.GAME_PLAYERS.BY_INDEX[player_index].code == MPAPI.get_code() then
			current_player_position = i
			break
		end
	end
	return current_player_position
end

function MP.get_br_shown_player()
	local sorted_players_indexes = MP.GAME_PLAYERS.get_by_score(true)
	local nemesis_threshold_index = MP.get_br_required_losers(sorted_players_indexes)

	local current_player_position = MP.get_br_current_player_score_position(sorted_players_indexes)

	if current_player_position and current_player_position <= nemesis_threshold_index then
		return MP.GAME_PLAYERS.BY_INDEX[sorted_players_indexes[nemesis_threshold_index + 1]]
	end

	return MP.GAME_PLAYERS.BY_INDEX[sorted_players_indexes[nemesis_threshold_index]]
end

function MP.get_br_losers()
	local sorted_players = MP.GAME_PLAYERS.get_by_score()

	local losing_players = {}
	local required_losers = MP.get_br_required_losers(sorted_players)

	for i = 1, #sorted_players do
		if sorted_players[i].hands_left < 1 then
			table.insert(losing_players, sorted_players[i])
			if #losing_players >= required_losers then
				return losing_players
			end
		else
			return nil
		end
	end

	return nil
end

function MP.get_1v1_loser()
	local nemesis = MP.GAME_PLAYERS.BY_CODE[MP.game_state.nemesis]
	local self_player = MP.GAME_PLAYERS.BY_CODE[MPAPI.get_code()]

	if
		nemesis.hands_left < 1
		and self_player.hands_left < 1
		and MP.to_big(nemesis.score) == MP.to_big(self_player.score)
	then
		return {}
	end

	if nemesis.hands_left < 1 or self_player.hands_left < 1 then
		local is_nemesis_losing = MP.to_big(nemesis.score) < MP.to_big(self_player.score)
		if is_nemesis_losing and nemesis.hands_left < 1 then
			return { nemesis }
		elseif not is_nemesis_losing and self_player.hands_left < 1 then
			return { self_player }
		end
	end

	return nil
end
