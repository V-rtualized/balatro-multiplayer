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
