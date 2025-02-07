local ready_up_event_started = false

MP.EVENTS.ready_up = Event({
	trigger = "immediate",
	blockable = false,
	blocking = false,
	func = function()
		if not MP.GAME_PLAYERS.is_all_ready() then
			return false
		end
		local action = MPAPI.NetworkAction(MP.ACTIONS.START_BLIND)
		action:broadcast({})
		ready_up_event_started = false
		return true
	end,
})

MP.FUNCS.READY_UP_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_ready(from, true)
	if MPAPI.is_host() and not ready_up_event_started then
		ready_up_event_started = true
		MP.add_event(MP.EVENTS.ready_up)
	end
	return true
end

MP.ACTIONS.READY_UP = MPAPI.NetworkActionType({
	key = "ready_up",
	parameters = {},
	on_receive = MP.FUNCS.READY_UP_ON_RECEIVE,
})

MP.FUNCS.READY_DOWN_ON_RECEIVE = function(self, action, parameters, from)
	MP.GAME_PLAYERS.set_ready(from, false)
	return true
end

MP.ACTIONS.READY_DOWN = MPAPI.NetworkActionType({
	key = "ready_down",
	parameters = {},
	on_receive = MP.FUNCS.READY_DOWN_ON_RECEIVE,
})
