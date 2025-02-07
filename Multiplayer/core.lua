MP = SMODS.current_mod

MP.ACTIONS = {}
MP.FUNCS = {}
MP.EVENTS = {}

MP.lobby_state = {
	config = {
		gold_on_life_loss = true,
		no_gold_on_round_loss = false,
		death_on_round_loss = true,
		different_seeds = false,
		starting_lives = 2,
		showdown_starting_antes = 3,
		gamemode = "horde",
		custom_seed = "random",
		different_decks = false,
		horde_players_losing = 2,
	},
}

MP.game_state = {}

function MP.reset_game_state()
	MP.game_state = {
		initialized = false,
		seed = nil,
		current_hand = nil,
		round = 1,
		blinds_by_ante = {},
		end_pvp = false,
		ready_blind = false,
		ready_blind_text = localize("unready"),
		ready_blind_context = nil,
		ante_key = tostring(math.random()),
		antes_keyed = {},
		nemesis = 1,
		prevent_eval = false,
		comeback_bonus_given = true,
		comeback_bonus = 0,
		failed = false,
	}
end

MP.reset_game_state()

G.E_MANAGER:add_event(Event({
	trigger = "immediate",
	blockable = false,
	blocking = false,
	func = function()
		if SMODS.booted then
			MP.reset_game_state()
			return true
		end
		return false
	end,
}))

MP.temp_vals = {
	code = "",
}

MP.cards = {}

MP.blinds = {}

MP.networking = {}

function MP.load_file(file)
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

function MP.load_dir(directory)
	for _, filename in ipairs(NFS.getDirectoryItems(MP.path .. "/" .. directory)) do
		local file_path = directory .. "/" .. filename
		if file_path:match(".lua$") then
			MP.load_file(file_path)
		end
	end
end

SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})

MP.load_file("src/networking/player_manager.lua")
MP.load_file("src/ui/smods.lua")
MP.load_file("src/utils.lua")
MP.load_file("src/mod_hash.lua")
MP.load_file("src/networking/networking.lua")
MP.load_dir("src/networking/actions")
MP.load_file("src/misc.lua")
MP.load_file("src/game.lua")
MP.load_file("src/ui/utils.lua")
MP.load_file("src/ui/blind_select.lua")
MP.load_file("src/ui/game_hud.lua")
MP.load_file("src/ui/end_game_overlay.lua")
MP.load_file("src/ui/cards.lua")
MP.load_file("src/editions.lua")
MP.load_file("src/stickers.lua")
MP.load_file("src/tags.lua")
MP.load_dir("src/consumables")
MP.load_dir("src/jokers")
MP.load_file("src/ui/galdur_lobby_page.lua")
MP.load_dir("src/blinds")

MPAPI.server_config.url = "virtualized.dev"
MPAPI.server_config.port = 6858
MPAPI.initialize()

local event
event = Event({
	trigger = "after",
	blockable = false,
	blocking = false,
	delay = 3,
	pause_force = true,
	no_delete = true,
	timer = "REAL",
	func = function()
		MP.send_debug_message(MP.GAME_PLAYERS.BY_INDEX)

		event.start_timer = false
	end,
})
--MP.add_event(event)
