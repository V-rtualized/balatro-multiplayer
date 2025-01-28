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
	MP.lobby_state.is_host = true

	MP.lobby_state.players[MP.network_state.code] = {
		username = MP.network_state.username,
		code = MP.network_state.code,
	}

	MP.draw_lobby_ui()
end

function MP.networking.funcs.leave_lobby_ack(args)
	MP.network_state.lobby = nil
	MP.lobby_state.is_host = false

	MP.draw_lobby_ui()
end

function MP.networking.funcs.join_lobby_ack(args)
	if not args then
		MP.send_warn_message("Got join_lobby_ack with invalid args")
		return
	end

	if not args.code then
		MP.UI.join_lobby_overlay()
		return
	end

	MP.network_state.lobby = args.code

	MP.draw_lobby_ui()
end

function MP.networking.funcs.player_joined(args)
	if not args or not args.code or not args.username then
		MP.send_warn_message("Got player_joined with invalid args")
		return
	end

	MP.lobby_state.players[args.code] = {
		username = args.username,
		code = args.code,
	}
end
