MP.Gamemode({
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
