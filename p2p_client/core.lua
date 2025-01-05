local NETWORKING_THREAD = nil

local networkToUiChannel = love.thread.getChannel("networkToUi")
local uiToNetworkChannel = love.thread.getChannel("uiToNetwork")

MP = {
	connected = false,
	code = nil,
	is_host = false,
	peer_connected = false,
	game_state = {
		initialized = false,
		seed = nil,
		current_hand = nil,
		round = 1,
		waiting_for_peer = false,
	},
	temp_code = "",
}

function load_mp_file(file)
	local chunk, err = SMODS.load_file(file, "VirtualizedMultiplayer")
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

load_mp_file("ui.lua")

local function initializeMultiplayer()
	if not NETWORKING_THREAD then
		local SOCKET = load_mp_file("server.lua")
		NETWORKING_THREAD = love.thread.newThread(SOCKET)
		NETWORKING_THREAD:start(
			SMODS.Mods["VirtualizedMultiplayer"].config.server_url,
			SMODS.Mods["VirtualizedMultiplayer"].config.server_port
		)
		uiToNetworkChannel:push("connect")
	end
end

function MP.connectToPeer(code)
	uiToNetworkChannel:push("action:connect,code:" .. code)
end

local function handleNetworkMessage(message)
	sendTraceMessage("Received SERVER message: " .. message, "MULTIPLAYER")
	if message:find("^action:connected,code:") then
		MP.connected = true
		MP.code = message:match("code:(%w+)")
	elseif message:find("^action:error") then
		local error_msg = message:match("message:(.+)")
		sendTraceMessage("Error: " .. error_msg, "MULTIPLAYER")
	elseif message:find("^action:disconnected") then
		MP.connected = false
		MP.code = nil
		sendTraceMessage("Disconnected from server", "MULTIPLAYER")
	end
end

local game_update_ref = Game.update
function Game:update(dt)
	game_update_ref(self, dt)

	repeat
		local msg = networkToUiChannel:pop()
		if msg then
			handleNetworkMessage(msg)
		end
	until not msg
end

initializeMultiplayer()
