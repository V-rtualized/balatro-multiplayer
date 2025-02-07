MP.GAME_PLAYERS = {
	BY_CODE = {},
	BY_INDEX = {},
}

function MP.GAME_PLAYERS.reset_players()
	MP.GAME_PLAYERS.BY_CODE = {}
	MP.GAME_PLAYERS.BY_INDEX = {}
end

function MP.GAME_PLAYERS.copy_players(players)
	MP.GAME_PLAYERS.reset_players()
	for _, player in pairs(players) do
		MP.GAME_PLAYERS.add_player(player)
	end
end

function MP.GAME_PLAYERS.add_player(player)
	if MP.GAME_PLAYERS.BY_CODE[player.code] then
		MP.GAME_PLAYERS.remove_player(player.code)
	end
	local next_index = #MP.GAME_PLAYERS.BY_INDEX + 1
	player.index = next_index
	MP.GAME_PLAYERS.BY_CODE[player.code] = player
	MP.GAME_PLAYERS.BY_INDEX[next_index] = player
	MP.GAME_PLAYERS.set_score(player.code, 0)
	MP.GAME_PLAYERS.set_score_text(player.code, "0")
	MP.GAME_PLAYERS.set_skips(player.code, 0)
	MP.GAME_PLAYERS.set_lives(player.code, MP.lobby_state.config.starting_lives)
	MP.GAME_PLAYERS.set_hands_left(player.code, 4)
	MP.GAME_PLAYERS.set_ready(player.code, false)
end

function MP.GAME_PLAYERS.remove_player(code)
	local player = MP.GAME_PLAYERS.BY_CODE[code]
	if MP.GAME_PLAYERS.BY_INDEX[player.index] then
		table.remove(MP.GAME_PLAYERS.BY_INDEX, player.index)
	end
	MP.GAME_PLAYERS.BY_CODE[code] = nil
end

function MP.GAME_PLAYERS.set_score(code, score)
	if MP.GAME_PLAYERS.BY_CODE[code] and MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index] then
		MP.GAME_PLAYERS.BY_CODE[code].score = score
		MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index].score = score
	end
end

function MP.GAME_PLAYERS.set_score_text(code, score_text)
	if MP.GAME_PLAYERS.BY_CODE[code] and MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index] then
		MP.GAME_PLAYERS.BY_CODE[code].score_text = score_text
		MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index].score_text = score_text
	end
end

function MP.GAME_PLAYERS.set_hands_left(code, hands_left)
	if MP.GAME_PLAYERS.BY_CODE[code] and MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index] then
		MP.GAME_PLAYERS.BY_CODE[code].hands_left = hands_left
		MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index].hands_left = hands_left
	end
end

function MP.GAME_PLAYERS.set_lives(code, lives)
	if MP.GAME_PLAYERS.BY_CODE[code] and MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index] then
		MP.GAME_PLAYERS.BY_CODE[code].lives = lives
		MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index].lives = lives
	end
end

function MP.GAME_PLAYERS.set_skips(code, skips)
	if MP.GAME_PLAYERS.BY_CODE[code] and MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index] then
		MP.GAME_PLAYERS.BY_CODE[code].skips = skips
		MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index].skips = skips
	end
end

function MP.GAME_PLAYERS.set_ready(code, is_ready)
	if MP.GAME_PLAYERS.BY_CODE[code] and MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index] then
		MP.GAME_PLAYERS.BY_CODE[code].ready = is_ready
		MP.GAME_PLAYERS.BY_INDEX[MP.GAME_PLAYERS.BY_CODE[code].index].ready = is_ready
	end
end

function MP.GAME_PLAYERS.get_alive()
	local alive_players = {}
	for _, player in ipairs(MP.GAME_PLAYERS.BY_INDEX) do
		if player.lives > 0 then
			table.insert(alive_players, player)
		end
	end
	return alive_players
end

local function sort_table_by_score(t, get_score_func)
	local t2 = table
	table.sort(t2, function(a, b)
		return MP.to_big(get_score_func(a)) < MP.to_big(get_score_func(b))
	end)
	return t2
end

local function get_indexes_by_score()
	local alive_players = MP.GAME_PLAYERS.get_alive()

	local indexes = {}

	for i = 1, #alive_players do
		indexes[i] = i
	end

	sort_table_by_score(indexes, function(element)
		return alive_players[element].score
	end)

	return indexes
end

local function get_players_by_score()
	local alive_players = MP.GAME_PLAYERS.get_alive()

	sort_table_by_score(alive_players, function(element)
		return element.score
	end)

	return alive_players
end

function MP.GAME_PLAYERS.get_by_score(get_indexes)
	return get_indexes and get_indexes_by_score() or get_players_by_score()
end

function MP.GAME_PLAYERS.is_all_ready()
	local alive_players = MP.GAME_PLAYERS.get_alive()
	for _, player in ipairs(alive_players) do
		if not player.ready then
			return false
		end
	end

	return true
end

function MP.GAME_PLAYERS.all_unready()
	for code, _ in pairs(MP.GAME_PLAYERS.BY_CODE) do
		MP.GAME_PLAYERS.set_ready(code, false)
	end
end
