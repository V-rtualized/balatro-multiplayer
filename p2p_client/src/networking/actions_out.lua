MP.send = {}

MP.pending_messages = {}
MP.MAX_RETRIES = 5

local cached_username = nil

function MP.networking.initialize()
	if not MP.networking.NETWORKING_THREAD then
		local SOCKET = load_mp_file("src/networking/server.lua")
		MP.networking.NETWORKING_THREAD = love.thread.newThread(SOCKET)
		MP.networking.NETWORKING_THREAD:start(
			SMODS.Mods["Multiplayer"].config.server_url,
			SMODS.Mods["Multiplayer"].config.server_port
		)

		MP.send.connect()
	end
end

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
				MP.networking.ui_to_network_channel:push(pending.raw_message)
			end
		end

		for _, msg_id in ipairs(messages_to_remove) do
			MP.pending_messages[msg_id] = nil
		end

		MP.retry_event.start_timer = false
	end,
})

G.E_MANAGER:add_event(MP.retry_event)

function MP.send.raw(msg)
	local raw_msg
	if type(msg) == "table" then
		if MP.EXPECTED_RESPONSES[msg.action] then
			local msg_id = os.time() .. "_" .. msg.action
			MP.pending_messages[msg_id] = {
				action = msg.action,
				retries = 0,
				expected_response = MP.EXPECTED_RESPONSES[msg.action],
				raw_message = MP.serialize_networking_message(msg),
			}
		end
		raw_msg = MP.serialize_networking_message(msg)
	else
		raw_msg = msg
	end

	MP.send_trace_message("Sending message: " .. raw_msg)
	MP.networking.ui_to_network_channel:push(raw_msg)
end

function MP.send.connect()
	MP.send.raw("connect")

	cached_username = G.PROFILES[G.SETTINGS.profile].name or "Guest"
	MP.send.raw({
		action = "connect",
		username = cached_username,
	})
end

function MP.send.open_lobby()
	MP.send.raw({
		action = "open_lobby",
	})
end

function MP.send.join_lobby(code, checking)
	MP.send.raw({
		action = "join_lobby",
		code = code:gsub("[oO]", "0"), -- Replaces the letter O with the number 0 because Balatro has a vendetta against zeros
		checking = checking or false,
	})
end

function MP.send.leave_lobby()
	MP.send.raw({
		action = "leave_lobby",
	})
end

function MP.send.set_username()
	local new_username = G.PROFILES[G.SETTINGS.profile].name or "Guest"
	if cached_username == new_username then
		return
	end
	cached_username = new_username
	MP.send.raw({
		action = "set_username",
		username = new_username,
	})
end

function MP.send.request_lobby_sync()
	MP.send.raw({
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
	MP.send.raw({
		action = "start_run",
		choices = MP.table_to_networking_message(choices),
		game_players = MP.table_to_networking_message(MP.game_state.players),
	})
end

function MP.send.request_ante_info()
	MP.send.raw({
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
	MP.send.raw(args)
	MP.networking.funcs.ready_blind(args)
end

function MP.send.unready_blind()
	local args = {
		action = "unready_blind",
		from = MP.network_state.code,
	}
	MP.send.raw(args)
	MP.networking.funcs.unready_blind(args)
end

function MP.send.play_hand(score, hands_left)
	local args = {
		action = "play_hand",
		score = MP.table_to_networking_message(score),
		hands_left = tostring(hands_left),
		from = MP.network_state.code,
	}
	MP.send.raw(args)
	MP.networking.funcs.play_hand(args)
end

function MP.send.set_location(loc)
	local args = {
		action = "set_location",
		location = loc,
		from = MP.network_state.code,
	}
	MP.send.raw(args)
	MP.networking.funcs.set_location(args)
end

function MP.send.set_skips(skips)
	local args = {
		action = "set_skips",
		skips = tostring(skips),
		from = MP.network_state.code,
	}
	MP.send.raw(args)
	MP.networking.funcs.set_skips(args)
end

function MP.send.fail_round()
	MP.send.lose_life(MP.network_state.code)
end

function MP.send.end_pvp()
	MP.send.raw({
		action = "end_pvp",
	})
	MP.networking.funcs.end_pvp()
end

function MP.send.lose_life(to)
	local args = {
		action = "lose_life",
		to = to,
	}
	MP.send.raw(args)
	MP.networking.funcs.lose_life(args)
end

function MP.send.win(to)
	local args = {
		action = "win",
		to = to,
	}
	MP.send.raw(args)
	MP.networking.funcs.win(args)
end
