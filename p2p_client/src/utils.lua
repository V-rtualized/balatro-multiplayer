MP.SHOW_DEBUG_MESSAGES = true

function MP.sendDebugMessage(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendDebugMessage(message, "MULTIPLAYER")
	end
end

function MP.sendWarnMessage(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendWarnMessage(message, "MULTIPLAYER")
	end
end

function MP.sendTraceMessage(message)
	if MP.SHOW_DEBUG_MESSAGES then
		sendTraceMessage(message, "MULTIPLAYER")
	end
end
