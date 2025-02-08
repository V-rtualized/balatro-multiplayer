SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})

MPAPI = {
	SERVER_CONFIG = {
		url = nil,
		port = nil,
	},
	NETWORK_STATE = {
		connected = false,
		code = nil,
		username = "Guest",
		lobby = nil,
	},
	FUNCS = {},
	EVENTS = {},
	ACTIONS = {},
	NETWORKING_THREAD = nil,
	VERSION = SMODS.current_mod.version,
	BADGE_COLOUR = SMODS.current_mod.badge_colour,
	network_to_ui_channel = love.thread.getChannel("networkToUi"),
	ui_to_network_channel = love.thread.getChannel("uiToNetwork"),
}

function MPAPI.load_file(file)
	local chunk, err = SMODS.load_file(file, "MultiplayerAPI")
	if chunk then
		local ok, func = pcall(chunk)
		if ok then
			return func
		else
			sendWarnMessage("Failed to process file: " .. func, "MultiplayerAPI")
		end
	else
		sendWarnMessage("Failed to find or compile file: " .. tostring(err), "MultiplayerAPI")
	end
	return nil
end

MPAPI.load_file("src/internal_utils.lua")
MPAPI.load_file("src/player_utils.lua")
MPAPI.load_file("src/network_action_type.lua")
MPAPI.load_file("src/network_action.lua")
MPAPI.load_file("src/networking.lua")
