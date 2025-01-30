MP.networking.funcs = {}

function MP.networking.handle_network_message(message)
	if message == "action:keep_alive_ack" then
		return
	end
	MP.send_trace_message("Received message: " .. message)
	msg_obj = MP.parse_networking_message(message)
	if msg_obj.action and MP.networking.funcs[msg_obj.action] then
		MP.networking.funcs[msg_obj.action](msg_obj)
	else
		MP.send_warn_message("Received message with unknown action: " .. msg_obj.action)
	end
end

function MP.networking.funcs.connect_ack(args)
	if not args or not args.code then
		MP.send_warn_message("Got connect_ack with invalid args")
		return
	end

	MP.network_state.username = args.username or "Guest"
	MP.network_state.connected = true
	MP.network_state.code = args.code

	MP.draw_lobby_ui()
end

function MP.networking.funcs.set_username_ack(args)
	if not args or not args.username then
		MP.send_warn_message("Got set_username_ack with invalid args")
		return
	end

	MP.network_state.username = args.username
end

function MP.networking.funcs.error(args)
	if not args or not args.message then
		MP.send_warn_message("Got error with no message")
		return
	end

	MP.UI.show_mp_overlay_message(args.message)
	MP.send_warn_message(args.message)
end

function MP.networking.funcs.disconnected(args)
	MP.network_state.connected = false
	MP.network_state.code = nil

	MP.networking.funcs.leave_lobby_ack()

	MP.send_warn_message("Disconnected from server")
end

function MP.networking.funcs.open_lobby_ack(args)
	MP.network_state.lobby = MP.network_state.code

	MP.lobby_state.players[1] = {
		username = MP.network_state.username,
		code = MP.network_state.code,
	}

	MP.draw_lobby_ui()
end

function MP.networking.funcs.leave_lobby_ack(args)
	MP.network_state.lobby = nil

	MP.draw_lobby_ui()
end

function MP.networking.funcs.join_lobby_ack(args)
	if not args then
		MP.send_warn_message("Got join_lobby_ack with invalid args")
		return
	end

	if not args.code then
		MP.UI.create_join_lobby_overlay()
		return
	end

	MP.network_state.lobby = args.code

	MP.send.request_lobby_sync()

	MP.draw_lobby_ui()
end

function MP.networking.funcs.player_joined(args)
	if not args or not args.code or not args.username then
		MP.send_warn_message("Got player_joined with invalid args")
		return
	end

	MP.lobby_state.players[#MP.lobby_state.players + 1] = {
		username = args.username,
		code = args.code,
	}
end

function MP.networking.funcs.player_left(args)
	if not args or not args.code then
		MP.send_warn_message("Got player_joined with invalid args")
		return
	end

	local player_index = MP.get_player_by_code(args.code)

	if player_index ~= nil then
		table.remove(MP.lobby_state.players, player_index)
	end
end

function MP.networking.funcs.request_lobby_sync(args)
	if not args or not args.from then
		MP.send_warn_message("Got request_lobby_sync with invalid args")
		return
	end

	local data = MP.deep_copy(MP.lobby_state)

	MP.send.raw({
		action = "request_lobby_sync_ack",
		from = MP.network_state.code,
		to = args.from,
		data = MP.table_to_networking_message(data),
	})
end

function MP.networking.funcs.request_lobby_sync_ack(args)
	if not args or not args.data then
		MP.send_warn_message("Got request_lobby_sync_ack with invalid args")
		return
	end

	local parsed_data = MP.networking_message_to_table(args.data)
	MP.lobby_state = parsed_data
end

function MP.networking.funcs.start_run(args)
	if not args or not args.choices then
		MP.send_warn_message("Got start_run with invalid args")
		return
	end

	local parsed_choices = MP.networking_message_to_table(args.choices)
	G.FUNCS.start_run(nil, parsed_choices)
end

function MP.networking.funcs.request_ante_info(args)
	if not args or not args.ante or not args.from then
		MP.send_warn_message("Got request_ante_info with invalid args")
		return
	end

	local ante_num = tonumber(args.ante)

	if ante_num == nil then
		MP.send_warn_message("Got request_ante_info with non-number ante")
		return
	end

	if not MP.game_state.blinds_by_ante[ante_num] then
		MP.generate_blinds_by_ante(ante_num)
	end

	MP.send.raw({
		action = "request_ante_info_ack",
		from = MP.network_state.code,
		to = args.from,
		data = MP.table_to_networking_message(MP.game_state.blinds_by_ante[ante_num]),
		ante = args.ante,
	})
end

function MP.networking.funcs.request_ante_info_ack(args)
	if not args or not args.data or not args.ante then
		MP.send_warn_message("Got request_ante_info_ack with invalid args")
		return
	end

	local ante_num = tonumber(args.ante)

	if ante_num == nil then
		MP.send_warn_message("Got request_ante_info_ack with non-number ante")
		return
	end

	local parsed_data = MP.networking_message_to_table(args.data)

	MP.game_state.blinds_by_ante[ante_num] = parsed_data
end

function MP.networking.funcs.ready_blind(args)
	MP.game_state.players_ready = MP.game_state.players_ready + 1
	if MP.network_state.code == MP.network_state.lobby and MP.game_state.players_ready >= #MP.lobby_state.players then
		MP.send.raw({
			action = "start_blind",
		})
		MP.networking.funcs.start_blind()
		MP.game_state.players_ready = 0
	end
end

function MP.networking.funcs.unready_blind(args)
	MP.game_state.players_ready = MP.game_state.players_ready - 1
end

function MP.networking.funcs.start_blind(args)
	if MP.game_state.ready_blind_context then
		G.FUNCS.select_blind(MP.game_state.ready_blind_context)
	end
end

function MP.networking.funcs.host_migration(args)
	if not args or not args.code then
		MP.send_warn_message("Got host_migration with invalid args")
		return
	end

	MP.network_state.lobby = args.code

	if MP.is_host() then
		MP.UI.show_mp_overlay_message(localize("new_host"))
	end
end
