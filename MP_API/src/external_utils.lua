function MPAPI.is_in_lobby()
	return type(MPAPI.network_state.lobby) == "string" and MPAPI.network_state.lobby ~= ""
end

function MPAPI.is_host()
	return MPAPI.network_state.lobby == MPAPI.network_state.code and MPAPI.network_state.code ~= nil
end
