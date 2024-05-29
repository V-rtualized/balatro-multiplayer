sendDebugMessage("Loading steam.lua", "MP_STEAM")

local st = {}

function st.init()
	sendDebugMessage("st_init called", "MP_STEAM")
	if G.STEAM then
		sendDebugMessage("Steamworks is available", "MP_STEAM")

		function G.STEAM.friends.onGameRichPresenceJoinRequested(data)
			G.LOBBY.temp_code = data.connect
			local msg = string.format("Join requested: %s", G.LOBBY.temp_code)
			sendInfoMessage(msg, "MP_STEAM")
			G.MULTIPLAYER.join_lobby(G.LOBBY.temp_code)
		end
		G.MP_STEAM_Initiated = true
	end
end

local game_update_ref = Game.update
function Game.update(self, dt)
	game_update_ref(self, dt)
	if G.MP_STEAM_Initiated then
		G.STEAM:runCallbacks()
	else
		st.init()
	end
end
