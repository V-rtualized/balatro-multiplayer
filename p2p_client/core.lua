MP = {
	id = SMODS.current_mod["id"],
	name = SMODS.current_mod["name"],
	display_name = SMODS.current_mod["display_name"],
	author = SMODS.current_mod["author"],
	description = SMODS.current_mod["description"],
	prefix = SMODS.current_mod["prefix"],
	priority = SMODS.current_mod["priority"],
	badge_colour = SMODS.current_mod["badge_colour"],
	badge_text_colour = SMODS.current_mod["badge_text_colour"],
	version = SMODS.current_mod["version"],
	dependencies = SMODS.current_mod["dependencies"],
	conflicts = SMODS.current_mod["conflicts"],
} -- I do this instead of `MP = SMODS.current_mod` for IDE autofill

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

SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})

load_mp_file("src/ui/smods.lua")
load_mp_file("src/utils.lua")
load_mp_file("src/mod_hash.lua")
load_mp_file("src/networking/actions_in.lua")
load_mp_file("src/networking/actions_out.lua")
load_mp_file("src/misc.lua")
load_mp_file("src/game.lua")
load_mp_file("src/ui/utils.lua")
load_mp_file("src/ui/lobby_buttons.lua")
load_mp_file("src/ui/blind_select.lua")
load_mp_file("src/ui/game_hud.lua")
load_mp_file("src/ui/end_game_overlay.lua")
load_mp_file("src/ui/cards.lua")
load_mp_file("src/editions.lua")
load_mp_file("src/stickers.lua")
load_mp_file("src/tags.lua")
load_mp_file("src/consumables/asteroid.lua")
load_mp_file("src/jokers/player.lua")
load_mp_file("src/jokers/defensive_joker.lua")
load_mp_file("src/jokers/hanging_bad.lua")
load_mp_file("src/jokers/lets_go_gambling.lua")
load_mp_file("src/jokers/skip_off.lua")
load_mp_file("src/jokers/speedrun.lua")
load_mp_file("src/ui/galdur_lobby_page.lua")
load_mp_file("src/blinds/horde.lua")
load_mp_file("src/blinds/nemesis.lua")
load_mp_file("src/blinds/truce.lua")

G.E_MANAGER:add_event(Event({
	trigger = "immediate",
	blockable = false,
	blocking = false,
	no_delete = true,
	func = function()
		repeat
			local msg = MP.networking.network_to_ui_channel:pop()
			if msg then
				MP.networking.handle_network_message(msg)
			end
		until not msg
		return false
	end,
}))

MP.networking.initialize()
