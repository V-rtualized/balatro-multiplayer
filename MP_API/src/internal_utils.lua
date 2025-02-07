MPAPI.SHOW_DEBUG_MESSAGES = true

function message_to_string(message)
	if type(message) == "table" or type(message) == "function" then
		message = serialize(message)
	end
	if type(message) == "number" or type(message) == "boolean" or type(message) == "nil" then
		message = tostring(message)
	end
	return message
end

function MPAPI.send_debug_message(message)
	if MPAPI.SHOW_DEBUG_MESSAGES then
		sendDebugMessage(message_to_string(message), "MultiplayerAPI")
	end
end

function MPAPI.send_warn_message(message)
	if MPAPI.SHOW_DEBUG_MESSAGES then
		sendWarnMessage(message_to_string(message), "MultiplayerAPI")
	end
end

function MPAPI.send_error_message(message)
	sendErrorMessage(message_to_string(message), "MultiplayerAPI")
end

function MPAPI.send_trace_message(message)
	if MPAPI.SHOW_DEBUG_MESSAGES then
		sendTraceMessage(message_to_string(message), "MultiplayerAPI")
	end
end

function MPAPI.send_info_message(message)
	sendInfoMessage(message_to_string(message), "MultiplayerAPI")
end

-- Credit: https://gist.github.com/tylerneylon/81333721109155b2d244
function MPAPI.deep_copy(obj, seen)
	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end

	-- New table; mark it as seen and copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in pairs(obj) do
		res[MPAPI.deep_copy(k, s)] = MPAPI.deep_copy(v, s)
	end
	return setmetatable(res, getmetatable(obj))
end

function MPAPI.add_event(event)
	G.E_MANAGER:add_event(event)
end

function MPAPI.copy_to_clipboard(text)
	if G.F_LOCAL_CLIPBOARD then
		G.CLIPBOARD = text
	else
		love.system.setClipboardText(text)
	end
end

function MPAPI.get_from_clipboard()
	if G.F_LOCAL_CLIPBOARD then
		return G.F_LOCAL_CLIPBOARD
	else
		return love.system.getClipboardText()
	end
end

function MPAPI.add_player(player)
	MPAPI.network_state.players_by_code[player.code] = {
		username = player.username,
		code = player.code,
		index = #MPAPI.network_state.players_by_index + 1,
	}
	MPAPI.network_state.players_by_index[MPAPI.network_state.players_by_code[player.code].index] =
		MPAPI.network_state.players_by_code[player.code]
end

function MPAPI.remove_player(player)
	table.remove(MPAPI.network_state.players_by_index, MPAPI.network_state.players_by_code[player.code].index)
	MPAPI.network_state.players_by_code[player.code] = nil
end
