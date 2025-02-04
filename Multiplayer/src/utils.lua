MP.SHOW_DEBUG_MESSAGES = true

function MP.send_debug_message(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendDebugMessage(message_to_string(message), "MULTIPLAYER")
	end
end

function MP.send_warn_message(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendWarnMessage(message_to_string(message), "MULTIPLAYER")
	end
end

function MP.send_trace_message(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendTraceMessage(message_to_string(message), "MULTIPLAYER")
	end
end

function MP.send_info_message(message)
	sendInfoMessage(message_to_string(message), "MULTIPLAYER")
end

function MP.parse_networking_message(str)
	local items = {}
	for item in str:gmatch("[^,]+") do
		local key, value = item:match("([^:]+):(.+)")
		if key and value then
			key = key:gsub("^%s*(.-)%s*$", "%1") -- Why doesn't lua have string:trim()
			value = value:gsub("^%s*(.-)%s*$", "%1")

			-- Parse boolean
			if value == "true" then
				value = true
			elseif value == "false" then
				value = false

			-- Parse number
			elseif tonumber(value) and key ~= "code" and key ~= "from" and key ~= "to" and key ~= "player" then -- Prevent code like 92E011 from being turned into 9200000000000
				value = tonumber(value)
			end

			items[key] = value
		end
	end
	return items
end

function MP.serialize_networking_message(obj)
	local parts = {}
	if obj.action then
		table.insert(parts, "action:" .. obj.action)
		obj.action = nil
	end
	for key, value in pairs(obj) do
		local stringValue = type(value) == "boolean" and tostring(value) or value
		table.insert(parts, key .. ":" .. stringValue)
	end
	return table.concat(parts, ",")
end

function MP.get_lobby_player_by_code(code)
	if MP.network_state.lobby == nil then
		return 0
	end
	for i, v in ipairs(MP.lobby_state.players) do
		if v.code == code then
			return i
		end
	end
end

function MP.get_game_player_by_code(code)
	if MP.network_state.lobby == nil then
		return 0
	end
	for i, v in ipairs(MP.game_state.players) do
		if v.code == code then
			return i
		end
	end
end

function MP.get_self_lobby_player()
	MP.get_lobby_player_by_code(MP.network_state.code)
end

function MP.get_self_game_player()
	MP.get_game_player_by_code(MP.network_state.code)
end

function MP.is_in_lobby()
	return MP.network_state.lobby ~= nil and MP.network_state.lobby ~= ""
end

-- Credit: https://gist.github.com/tylerneylon/81333721109155b2d244
function MP.deep_copy(obj, seen)
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
		res[MP.deep_copy(k, s)] = MP.deep_copy(v, s)
	end
	return setmetatable(res, getmetatable(obj))
end

function MP.copy_to_clipboard(text)
	if G.F_LOCAL_CLIPBOARD then
		G.CLIPBOARD = text
	else
		love.system.setClipboardText(text)
	end
end

function MP.get_from_clipboard()
	if G.F_LOCAL_CLIPBOARD then
		return G.F_LOCAL_CLIPBOARD
	else
		return love.system.getClipboardText()
	end
end

function MP.table_to_networking_message(t)
	local function encode(val)
		if val == nil then
			return "n"
		elseif type(val) == "string" then
			return "s" .. val .. "#"
		elseif type(val) == "number" then
			return "d" .. tostring(val) .. "#"
		elseif type(val) == "boolean" then
			return "b" .. (val and "1" or "0")
		elseif type(val) == "table" then
			local parts = {}
			for k, v in pairs(val) do
				parts[#parts + 1] = encode(k)
				parts[#parts + 1] = encode(v)
			end
			return "t" .. table.concat(parts) .. "e"
		end
	end
	return encode(t)
end

function MP.networking_message_to_table(str)
	local pos = 1

	local function decode()
		local typ = str:sub(pos, pos)
		pos = pos + 1

		if typ == "n" then
			return nil
		elseif typ == "s" then
			local value = ""
			while pos <= #str and str:sub(pos, pos) ~= "#" do
				value = value .. str:sub(pos, pos)
				pos = pos + 1
			end
			pos = pos + 1 -- Skip the #
			return value
		elseif typ == "d" then
			local value = ""
			while pos <= #str and str:sub(pos, pos) ~= "#" do
				value = value .. str:sub(pos, pos)
				pos = pos + 1
			end
			pos = pos + 1 -- Skip the #
			return tonumber(value)
		elseif typ == "b" then
			local value = str:sub(pos, pos)
			pos = pos + 1
			return value == "1"
		elseif typ == "t" then
			local tbl = {}
			while pos <= #str and str:sub(pos, pos) ~= "e" do
				local key = decode()
				local value = decode()
				tbl[key] = value
			end
			pos = pos + 1 -- Skip the 'e'
			return tbl
		end
	end

	return decode()
end

function MP.is_pvp_boss()
	if not G.GAME or not G.GAME.blind then
		return false
	end
	for _, v in ipairs(MP.blinds) do
		if G.GAME.blind.config.blind.key == v then
			return true
		end
	end
	return false
end

function MP.value_is_pvp_boss(value)
	if not G.GAME or not G.GAME.blind then
		return false
	end
	for _, v in ipairs(MP.blinds) do
		if value == v then
			return true
		end
	end
	return false
end

-- Credit to Steamo (https://github.com/Steamopollys/Steamodded/blob/main/core/core.lua)
function MP.wrapText(text, maxChars)
	local wrappedText = ""
	local currentLineLength = 0

	for word in text:gmatch("%S+") do
		if currentLineLength + #word <= maxChars then
			wrappedText = wrappedText .. word .. " "
			currentLineLength = currentLineLength + #word + 1
		else
			wrappedText = wrappedText .. "\n" .. word .. " "
			currentLineLength = #word + 1
		end
	end

	return wrappedText
end

function MP.get_joker(key)
	if not G.jokers then
		return nil
	end
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i].ability.name == key then
			return G.jokers.cards[i]
		end
	end
	return nil
end

function MP.get_non_phantom_jokers()
	if not G.jokers or not G.jokers.cards then
		return {}
	end
	local jokers = {}
	for _, v in ipairs(G.jokers.cards) do
		if v.ability.set == "Joker" and (not v.edition or v.edition.type ~= "mp_phantom") then
			table.insert(jokers, v)
		end
	end
	return jokers
end

function MP.is_host()
	return MP.network_state.code == MP.network_state.lobby
end

local ease_ante_ref = ease_ante
function ease_ante(mod)
	if not MP.is_in_lobby() then
		return ease_ante_ref(mod)
	end
	-- Prevents easing multiple times at once
	if MP.game_state.antes_keyed[MP.game_state.ante_key] then
		return
	end
	MP.game_state.antes_keyed[MP.game_state.ante_key] = true
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			G.GAME.round_resets.ante = G.GAME.round_resets.ante + mod
			check_and_set_high_score("furthest_ante", G.GAME.round_resets.ante)
			return true
		end,
	}))
end

function MP.get_nemesis()
	local sorted_players_indexes = MP.get_players_by_score(true)
	local nemesis_threshold_index = MP.get_horde_required_losers(#MP.game_state.players, #sorted_players_indexes)

	local current_player_position = nil
	for i, player_index in ipairs(sorted_players_indexes) do
		if MP.game_state.players[player_index].code == MP.network_state.code then
			current_player_position = i
			break
		end
	end

	if current_player_position and current_player_position <= nemesis_threshold_index then
		return MP.game_state.players[sorted_players_indexes[nemesis_threshold_index + 1]]
	end

	return MP.game_state.players[sorted_players_indexes[nemesis_threshold_index]]
end

function MP.get_alive_players()
	local alive_players = {}
	for _, player in ipairs(MP.game_state.players) do
		if player.lives > 0 then
			table.insert(alive_players, player)
		end
	end
	return alive_players
end

function MP.get_horde_required_losers(game_player_count, alive_players)
	if alive_players == 2 then
		return 1
	end
	if game_player_count > 4 then
		return 2
	else
		return 1
	end
end

function MP.get_players_by_score(get_indexes)
	local alive_players = MP.get_alive_players()

	if get_indexes then
		local indexes = {}

		for i = 1, #alive_players do
			indexes[i] = i
		end

		table.sort(indexes, function(a, b)
			return to_big(alive_players[a].score) < to_big(alive_players[b].score)
		end)

		return indexes
	end

	table.sort(alive_players, function(a, b)
		return to_big(a.score) < to_big(b.score)
	end)

	return alive_players
end

function MP.get_horde_losers()
	local sorted_players = MP.get_players_by_score()

	local losing_players = {}
	local required_losers = MP.get_horde_required_losers(#MP.lobby_state.players, #sorted_players)

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

function MP.readd_talisman_metavalues(t)
	if type(t) ~= "table" then
		return t
	end
	if t.array then
		return Big:new(t.array)
	elseif t.m then
		return Big:new(t.m, t.e)
	end
	return t
end

function MP.get_horde_starting_lives(player_count)
	if player_count > 6 then
		return 2
	elseif player_count > 3 then
		return 3
	end
	return 4
end
