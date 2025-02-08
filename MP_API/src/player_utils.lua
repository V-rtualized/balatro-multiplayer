MPAPI.LOBBY_PLAYERS = {
	BY_CODE = {},
	BY_INDEX = {},
}

function MPAPI.LOBBY_PLAYERS.reset_players()
	MPAPI.LOBBY_PLAYERS.BY_CODE = {}
	MPAPI.LOBBY_PLAYERS.BY_INDEX = {}
end

function MPAPI.LOBBY_PLAYERS.add_player(player)
	if MPAPI.LOBBY_PLAYERS.BY_CODE[player.code] then
		MPAPI.LOBBY_PLAYERS.remove_player(player.code)
	end
	local next_index = #MPAPI.LOBBY_PLAYERS.BY_INDEX + 1
	player.index = next_index
	MPAPI.LOBBY_PLAYERS.BY_CODE[player.code] = player
	MPAPI.LOBBY_PLAYERS.BY_INDEX[next_index] = player
	MPAPI.LOBBY_PLAYERS.set_username(player.code, player.username or "Guest")
end

function MPAPI.LOBBY_PLAYERS.remove_player(code)
	local player = MPAPI.LOBBY_PLAYERS.BY_CODE[code]
	if MPAPI.LOBBY_PLAYERS.BY_INDEX[player.index] then
		table.remove(MPAPI.LOBBY_PLAYERS.BY_INDEX, player.index)
	end
	MPAPI.LOBBY_PLAYERS.BY_CODE[code] = nil
end

function MPAPI.LOBBY_PLAYERS.set_username(code, username)
	if MPAPI.LOBBY_PLAYERS.BY_CODE[code] and MPAPI.LOBBY_PLAYERS.BY_INDEX[MPAPI.LOBBY_PLAYERS.BY_CODE[code].index] then
		MPAPI.LOBBY_PLAYERS.BY_CODE[code].username = username
		MPAPI.LOBBY_PLAYERS.BY_INDEX[MPAPI.LOBBY_PLAYERS.BY_CODE[code].index].username = username
	end
end

function MPAPI.get_code()
	return MPAPI.NETWORK_STATE.code
end

function MPAPI.get_lobby()
	return MPAPI.NETWORK_STATE.lobby
end

function MPAPI.get_username()
	return MPAPI.NETWORK_STATE.username
end

function MPAPI.LOBBY_PLAYERS.is_player_host(code)
	return MPAPI.get_lobby() == code and code ~= nil
end

function MPAPI.is_in_lobby()
	return type(MPAPI.get_lobby()) == "string" and MPAPI.get_lobby() ~= ""
end

function MPAPI.is_host()
	return MPAPI.LOBBY_PLAYERS.is_player_host(MPAPI.get_code())
end

function MPAPI.is_connected()
	return MPAPI.NETWORK_STATE.connected
end
