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
			elseif tonumber(value) then
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

function MP.get_player_count()
	if MP.network_state.lobby == nil then
		return 0
	end
	local count = 0
	for _, _ in pairs(MP.lobby_state.players) do
		count = count + 1
	end
	return count
end

function MP.get_player_by_index(index)
	if MP.network_state.lobby == nil then
		return
	end
	if index == 1 then
		return MP.lobby_state.players[MP.network_state.lobby]
	end
	local count = 1
	for k, v in pairs(MP.lobby_state.players) do
		if k == MP.network_state.lobby then
			goto continue
		end
		if count == index then return v end
		count = count + 1
		::continue::
	end
end

function MP.is_in_lobby()
	return MP.network_state.lobby ~= nil and MP.network_state.lobby ~= ""
end

-- Credit: https://gist.github.com/tylerneylon/81333721109155b2d244
function MP.deep_copy(obj, seen)
	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end

	-- New table; mark it as seen and copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in pairs(obj) do res[MP.deep_copy(k, s)] = MP.deep_copy(v, s) end
	return setmetatable(res, getmetatable(obj))
end