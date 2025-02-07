MP.FUNCS.REQUEST_ANTE_INFO_CALLBACK = function(self, msg)
	local parsed_data = msg.data

	MP.game_state.blinds_by_ante[msg.ante] = parsed_data
end

MP.FUNCS.REQUEST_ANTE_INFO_ON_RECEIVE = function(self, action, parameters, from)
	if not MP.game_state.blinds_by_ante[parameters.ante] then
		MP.generate_blinds_by_ante(parameters.ante)
	end

	return {
		ante = parameters.ante,
		data = MP.game_state.blinds_by_ante[parameters.ante],
	}
end

MP.ACTIONS.REQUEST_ANTE_INFO = MPAPI.NetworkActionType({
	key = "request_ante_info",
	parameters = {
		{
			key = "ante",
			type = "number",
			required = true,
		},
	},
	callback_parameters = {
		{
			key = "ante",
			type = "number",
			required = true,
		},
		{
			key = "data",
			type = "table",
			required = true,
		},
	},
	on_receive = MP.FUNCS.REQUEST_ANTE_INFO_ON_RECEIVE,
})
