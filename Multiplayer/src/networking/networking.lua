MP.send = {}

function MP.send.return_to_lobby()
	local action = MPAPI.NetworkAction(MP.ACTIONS.RETURN_TO_LOBBY)
	action:broadcast({})
end

function MP.send.start_run(choices)
	MP.GAME_PLAYERS.copy_players(MPAPI.LOBBY_PLAYERS.BY_CODE)
	local action = MPAPI.NetworkAction(MP.ACTIONS.START_RUN)
	action:broadcast({
		choices = choices,
		game_players = MP.GAME_PLAYERS.BY_CODE,
		lobby_config = MP.lobby_state.config,
	})
end

function MP.send.request_ante_info()
	local action = MPAPI.NetworkAction(MP.ACTIONS.REQUEST_ANTE_INFO)
	action:callback(MP.FUNCS.REQUEST_ANTE_INFO_CALLBACK)
	action:send_to_host({
		ante = G.GAME.round_resets.ante,
	})
end

function MP.send.ready_blind(e)
	MP.game_state.ready_blind_context = e
	local action = MPAPI.NetworkAction(MP.ACTIONS.READY_UP)
	action:broadcast({})
end

function MP.send.unready_blind()
	local action = MPAPI.NetworkAction(MP.ACTIONS.READY_DOWN)
	action:broadcast({})
end

function MP.send.play_hand(score, hands_left)
	local action = MPAPI.NetworkAction(MP.ACTIONS.PLAY_HAND)
	action:broadcast({
		score = score,
		hands_left = hands_left,
	})
end

function MP.send.set_skips(skips)
	local action = MPAPI.NetworkAction(MP.ACTIONS.SET_SKIPS)
	action:broadcast({
		skips = skips,
	})
end

function MP.send.fail_round()
	MP.send.lose_life(MPAPI.get_code())
end

function MP.send.end_pvp()
	local action = MPAPI.NetworkAction(MP.ACTIONS.END_PVP)
	action:broadcast({})
end

function MP.send.lose_life(to)
	local action = MPAPI.NetworkAction(MP.ACTIONS.LOSE_LIFE)
	action:broadcast({
		player = to,
	})
end

function MP.send.win(to)
	local action = MPAPI.NetworkAction(MP.ACTIONS.WIN)
	action:send(to, {})
end
