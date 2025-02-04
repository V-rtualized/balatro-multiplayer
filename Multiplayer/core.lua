MP = SMODS.current_mod

MP.network_state = {
	connected = false,
	code = nil,
	username = "Guest",
	lobby = nil,
}

MP.lobby_state = {
	players = {},
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
		players_ready = 0,
		lives = 2,
		ante_key = tostring(math.random()),
		antes_keyed = {},
		players = {},
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

SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})

MP.load_file("src/ui/smods.lua")
MP.load_file("src/utils.lua")
MP.load_file("src/mod_hash.lua")
MP.load_file("src/networking/actions_in.lua")
MP.load_file("src/networking/actions_out.lua")
MP.load_file("src/misc.lua")
MP.load_file("src/game.lua")
MP.load_file("src/ui/utils.lua")
MP.load_file("src/ui/lobby_buttons.lua")
MP.load_file("src/ui/blind_select.lua")
MP.load_file("src/ui/game_hud.lua")
MP.load_file("src/ui/end_game_overlay.lua")
MP.load_file("src/ui/cards.lua")
MP.load_file("src/editions.lua")
MP.load_file("src/stickers.lua")
MP.load_file("src/tags.lua")
MP.load_file("src/consumables/asteroid.lua")
MP.load_file("src/jokers/player.lua")
MP.load_file("src/jokers/defensive_joker.lua")
MP.load_file("src/jokers/hanging_bad.lua")
MP.load_file("src/jokers/lets_go_gambling.lua")
MP.load_file("src/jokers/skip_off.lua")
MP.load_file("src/jokers/speedrun.lua")
MP.load_file("src/ui/galdur_lobby_page.lua")
MP.load_file("src/blinds/horde.lua")
MP.load_file("src/blinds/nemesis.lua")
MP.load_file("src/blinds/truce.lua")

MPAPI.server_config.url = "virtualized.dev"
MPAPI.server_config.port = 6858
MPAPI.initialize()
