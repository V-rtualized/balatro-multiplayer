MP.Gamemode({
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
