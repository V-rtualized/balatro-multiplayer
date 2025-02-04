MP.send = {}

MP.pending_messages = {}
MP.MAX_RETRIES = 5

local cached_username = nil

MP.retry_event = Event({
	trigger = "after",
	blockable = false,
	blocking = false,
	delay = 3,
	pause_force = true,
	no_delete = true,
	timer = "REAL",
	func = function(t)
		local messages_to_remove = {}

		for msg_id, pending in pairs(MP.pending_messages) do
			pending.retries = pending.retries + 1

			if pending.retries >= MP.MAX_RETRIES then
				MP.send_warn_message("Message " .. pending.action .. " failed after " .. MP.MAX_RETRIES .. " retries")
				messages_to_remove[#messages_to_remove + 1] = msg_id

				if MP.network_state.lobby then
					MP.send.leave_lobby()
				end
			else
				MP.send_trace_message(
					"Retrying message " .. pending.action .. " (attempt " .. pending.retries + 1 .. ")"
				)
				MPAPI.ui_to_network_channel:push(pending.raw_message)
			end
		end

		for _, msg_id in ipairs(messages_to_remove) do
			MP.pending_messages[msg_id] = nil
		end

		MP.retry_event.start_timer = false
	end,
})

G.E_MANAGER:add_event(MP.retry_event)

function MP.send.open_lobby()
	MPAPI.send_raw({
		action = "open_lobby",
	})
end

function MP.send.join_lobby(code, checking)
	MPAPI.send_raw({
		action = "join_lobby",
		code = code:gsub("[oO]", "0"), -- Replaces the letter O with the number 0 because Balatro has a vendetta against zeros
		checking = checking or false,
	})
end

function MP.send.leave_lobby()
	MPAPI.send_raw({
		action = "leave_lobby",
	})
	if G.STAGE == G.STAGES.RUN then
		G.FUNCS.go_to_menu()
	end
end
G.FUNCS.mp_leave_lobby = MP.send.leave_lobby

function MP.send.return_to_lobby()
	MPAPI.send_raw({
		action = "return_to_lobby",
		from = MP.network_state.code,
	})
	if G.STAGE == G.STAGES.RUN then
		G.FUNCS.go_to_menu()
	end
end
G.FUNCS.mp_return_to_lobby = MP.send.return_to_lobby

function MP.send.set_username()
	local new_username = G.PROFILES[G.SETTINGS.profile].name or "Guest"
	if cached_username == new_username then
		return
	end
	cached_username = new_username
	MPAPI.send_raw({
		action = "set_username",
		username = new_username,
	})
end

function MP.send.request_lobby_sync()
	MPAPI.send_raw({
		action = "request_lobby_sync",
		from = MP.network_state.code,
		to = MP.network_state.lobby,
	})
end

function MP.send.start_run(choices)
	MP.game_state.players = MP.lobby_state.players
	for i, _ in ipairs(MP.game_state.players) do
		MP.game_state.players[i].lives = MP.lobby_state.config.starting_lives
		MP.game_state.players[i].location = "loc_selecting"
		MP.game_state.players[i].skips = 0
		MP.game_state.players[i].score = 0
		MP.game_state.players[i].score_text = "0"
		MP.game_state.players[i].hands_left = 4
	end
	MP.game_state.lives = MP.lobby_state.config.starting_lives
	MPAPI.send_raw({
		action = "start_run",
		choices = MP.table_to_networking_message(choices),
		game_players = MP.table_to_networking_message(MP.game_state.players),
		lobby_config = MP.table_to_networking_message(MP.lobby_state.config),
	})
end

function MP.send.request_ante_info()
	MPAPI.send_raw({
		action = "request_ante_info",
		from = MP.network_state.code,
		to = MP.network_state.lobby,
		ante = G.GAME.round_resets.ante,
	})
end

function MP.send.ready_blind(e)
	MP.game_state.ready_blind_context = e
	local args = {
		action = "ready_blind",
		from = MP.network_state.code,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.ready_blind(args)
end

function MP.send.unready_blind()
	local args = {
		action = "unready_blind",
		from = MP.network_state.code,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.unready_blind(args)
end

function MP.send.play_hand(score, hands_left)
	local args = {
		action = "play_hand",
		score = MP.table_to_networking_message(score),
		hands_left = tostring(hands_left),
		from = MP.network_state.code,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.play_hand(args)
end

function MP.send.set_location(loc)
	local args = {
		action = "set_location",
		location = loc,
		from = MP.network_state.code,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.set_location(args)
end

function MP.send.set_skips(skips)
	local args = {
		action = "set_skips",
		skips = tostring(skips),
		from = MP.network_state.code,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.set_skips(args)
end

function MP.send.fail_round()
	MP.send.lose_life(MP.network_state.code)
end

function MP.send.end_pvp()
	MPAPI.send_raw({
		action = "end_pvp",
	})
	MP.networking.funcs.end_pvp()
end

function MP.send.lose_life(to)
	local args = {
		action = "lose_life",
		to = to,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.lose_life(args)
end

function MP.send.win(to)
	local args = {
		action = "win",
		to = to,
	}
	MPAPI.send_raw(args)
	MP.networking.funcs.win(args)
end
