G.STATES.WAITING_ON_ANTE_INFO = 20
G.STATES.WAITING_ON_PVP_END = 21

function MP.update_waiting_on_ante_info(dt)
	if not G.STATE_COMPLETE then
		if not MP.game_state.blinds_by_ante[G.GAME.round_resets.ante] then
			if MP.lobby_state.is_host then
				MP.generate_blinds_by_ante(G.GAME.round_resets.ante)
			else
				MP.send.request_ante_info()
			end
		end
		G.STATE_COMPLETE = true
	end
	if MP.game_state.blinds_by_ante[G.GAME.round_resets.ante] then
		local choices = MP.game_state.blinds_by_ante[G.GAME.round_resets.ante]
		G.GAME.round_resets.blind_choices.Small = choices[1]
		G.GAME.round_resets.blind_choices.Big = choices[2]
		G.GAME.round_resets.blind_choices.Boss = choices[3]
		G.STATE = G.STATES.BLIND_SELECT
		G.STATE_COMPLETE = false
	end
end

function MP.update_waiting_on_pvp_end(dt)
	if not G.STATE_COMPLETE then
		G.STATE_COMPLETE = true
	end
	if MP.game_state.end_pvp then
		G.STATE = G.STATES.END_ROUND
		G.STATE_COMPLETE = false
	end
end

function MP.generate_blinds_by_ante(ante)
	MP.game_state.blinds_by_ante[ante] = {
		"bl_small",
		"bl_big",
		"bl_mp_horde",
	}
end
