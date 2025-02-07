MP.EVENTS.end_pvp = Event({
	trigger = "immediate",
	blockable = false,
	blocking = false,
	func = function()
		if G.STATE_COMPLETE then
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.WAITING_ON_PVP_END
			MP.game_state.end_pvp = true
			return true
		end
		return false
	end,
})

MP.FUNCS.END_PVP_ON_RECEIVE = function(self, action, parameters, from)
	MP.add_event(MP.EVENTS.end_pvp)

	return true
end

MP.ACTIONS.END_PVP = MPAPI.NetworkActionType({
	key = "end_pvp",
	parameters = {},
	on_receive = MP.FUNCS.END_PVP_ON_RECEIVE,
})
