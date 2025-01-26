MP = {}

MP.network_state = {
	connected = false,
	code = nil,
	is_host = false,
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

MP.networking.networkToUiChannel = love.thread.getChannel("networkToUi")
MP.networking.uiToNetworkChannel = love.thread.getChannel("uiToNetwork")

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
load_mp_file("src/ui.lua")

local function initializeMultiplayer()
	if not MP.networking.NETWORKING_THREAD then
		local SOCKET = load_mp_file("src/networking/server.lua")
		MP.networking.NETWORKING_THREAD = love.thread.newThread(SOCKET)
		MP.networking.NETWORKING_THREAD:start(
			SMODS.Mods["Multiplayer"].config.server_url,
			SMODS.Mods["Multiplayer"].config.server_port
		)
		MP.networking.uiToNetworkChannel:push("connect")
		MP.networking.uiToNetworkChannel:push("action:connect,username:" .. "GUEST")
		MP.networking.uiToNetworkChannel:push("action:openLobby")
	end
end

local game_update_ref = Game.update
function Game:update(dt)
	game_update_ref(self, dt)

	repeat
		local msg = MP.networking.networkToUiChannel:pop()
		if msg then
			MP.networking.handleNetworkMessage(msg)
		end
	until not msg
end

initializeMultiplayer()
