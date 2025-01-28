MP = SMODS.current_mod

MP.network_state = {
	connected = false,
	code = nil,
	username = "Guest",
	lobby = nil,
}

MP.lobby_state = {
	is_host = false,
	players = {},
}

MP.game_state = {
	initialized = false,
	seed = nil,
	current_hand = nil,
	round = 1,
}

MP.temp_vals = {
	code = "",
}

MP.networking = {}

MP.networking.NETWORKING_THREAD = nil

MP.networking.network_to_ui_channel = love.thread.getChannel("networkToUi")
MP.networking.ui_to_network_channel = love.thread.getChannel("uiToNetwork")

function load_mp_file(file)
	local chunk, err = SMODS.load_file(file, "Multiplayer")
	if chunk then
		local ok, func = pcall(chunk)
		if ok then
			return func
		else
			sendWarnMessage("Failed to process file: " .. func, "MULTIPLAYER")
		end
	else
		sendWarnMessage("Failed to find or compile file: " .. tostring(err), "MULTIPLAYER")
	end
	return nil
end

load_mp_file("src/utils.lua")
load_mp_file("src/networking/actions_in.lua")
load_mp_file("src/networking/actions_out.lua")
load_mp_file("src/misc.lua")
load_mp_file("src/ui.lua")
load_mp_file("src/jokers.lua")
load_mp_file("src/galdur.lua")

local game_update_ref = Game.update
function Game:update(dt)
	game_update_ref(self, dt)

	repeat
		local msg = MP.networking.network_to_ui_channel:pop()
		if msg then
			MP.networking.handle_network_message(msg)
		end
	until not msg
end

MP.networking.initialize()
