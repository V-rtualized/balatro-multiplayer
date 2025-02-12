--[[MP.Gamemode({
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
