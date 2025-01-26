function MP.networking.handleNetworkMessage(message)
	MP.sendTraceMessage("Received SERVER message: " .. message)
	if message:find("^action:connect_ack,code:") then
		MP.network_state.connected = true
		MP.network_state.code = message:match("code:(%w+)")
	elseif message:find("^action:error") then
		local error_msg = message:match("message:(.+)")
		MP.sendTraceMessage("Error: " .. error_msg)
	elseif message:find("^action:disconnected") then
		MP.network_state.connected = false
		MP.network_state.code = nil
		MP.sendTraceMessage("Disconnected from server")
	end
end
