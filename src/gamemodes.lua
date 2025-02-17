MP.GAMEMODES = {}
MP.Gamemode = SMODS.GameObject:extend({
	obj_table = MP.GAMEMODES,
	obj_buffer = {},
	required_params = {
		"key",
		"atlas",
		"blinds_by_ante",
		"is_1v1", -- If false requires "get_blind_losers"
		"has_lives", -- If true requires "starting_lives"
	},
	class_prefix = "gamemode",
	inject = function() end,
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.descriptions["Gamemode"], self.key, self.loc_txt)
	end,
})

MP.GAMEMODES.ATTRITION = MP.Gamemode({
	key = "attrition",
	atlas = "nemesis",
	is_1v1 = true,
	has_lives = true,
	loc_vars = function(self, nemesis)
		return {
			vars = {
				MP.GAME_PLAYERS.BY_CODE[nemesis] and MP.GAME_PLAYERS.BY_CODE[nemesis].hands_left or 0,
			},
		}
	end,
	blinds_by_ante = function(self, ante)
		return {
			nil,
			nil,
			"bl_mp_nemesis",
		}
	end,
	current_enemy = function(self, nemesis)
		return MP.GAME_PLAYERS.BY_CODE[nemesis]
	end,
	starting_lives = function(self, players)
		return 4
	end,
})

MP.GAMEMODES.BATTLE_ROYALE = MP.Gamemode({
	key = "battle_royale",
	atlas = "horde",
	is_1v1 = false,
	has_lives = true,
	loc_vars = function(self, nemesis)
		return {
			vars = {
				MP.get_br_current_player_score_position(),
				#MP.GAME_PLAYERS.get_alive(),
			},
		}
	end,
	blinds_by_ante = function(self, ante)
		return {
			nil,
			nil,
			"bl_mp_horde",
		}
	end,
	current_enemy = function(self, nemesis)
		return MP.get_br_shown_player()
	end,
	starting_lives = function(self, players)
		if players > 6 then
			return 2
		elseif players > 3 then
			return 3
		end
		return 4
	end,
})

MP.GAMEMODES.PRECISION = MP.Gamemode({
	key = "precision",
	atlas = "precision",
	is_1v1 = false,
	has_lives = true,
	loc_vars = function(self, nemesis)
		return {
			vars = {
				MP.get_br_current_player_score_position(),
				#MP.GAME_PLAYERS.get_alive(),
			},
		}
	end,
	blinds_by_ante = function(self, ante)
		return {
			nil,
			nil,
			"bl_mp_precision",
		}
	end,
	starting_lives = function(self, players)
		if players > 6 then
			return 2
		elseif players > 3 then
			return 3
		end
		return 4
	end,
})

--[[
MP.GAMEMODES.SPEEDRUN = MP.Gamemode({
	key = "speedrun",
	atlas = "attrition",
	is_1v1 = false,
	has_lives = false,
	loc_vars = function(self, nemesis)
		return {
			vars = {},
		}
	end,
	blinds_by_ante = function(self, ante)
		return {
			nil,
			nil,
			nil,
		}
	end,
	current_enemy = function(self, nemesis)
		return nil
	end,
})
]]
