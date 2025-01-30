MP.SHOW_DEBUG_MESSAGES = true

function MP.send_debug_message(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendDebugMessage(message, "MULTIPLAYER")
	end
end

function MP.send_warn_message(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendWarnMessage(message, "MULTIPLAYER")
	end
end

function MP.send_trace_message(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendTraceMessage(message, "MULTIPLAYER")
	end
end

function MP.send_info_message(message)
	sendInfoMessage(message, "MULTIPLAYER")
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
			elseif tonumber(value) and key ~= "code" then -- Prevent code like 92E011 from being turned into 9200000000000
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

function MP.get_player_by_code(code)
	if MP.network_state.lobby == nil then
		return { username = "ERROR", code = code }
	end
	if code == MP.network_state.lobby then
		return MP.lobby_state.players[1]
	end
	for i, v in ipairs(MP.lobby_state.players) do
		if v.code == code then
			return i
		end
	end
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
	MP.send_debug_message("Looking for " .. value)
	if not G.GAME or not G.GAME.blind then
		return false
	end
	for _, v in ipairs(MP.blinds) do
		MP.send_debug_message("Found " .. v)
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
