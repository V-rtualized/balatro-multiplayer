G.P_CENTER_POOLS.Gamemode = {}
MP.Gamemode = SMODS.GameObject:extend({
	obj_table = {},
	obj_buffer = {},
	required_params = {
		"key",
		"atlas",
		"blinds_by_ante",
		"is_1v1", -- If false requires "get_blind_losers"
		"has_lives", -- If true requires "starting_lives"
	},
	class_prefix = "gamemode",
	inject = function(self)
		table.insert(G.P_CENTER_POOLS.Gamemode, self)
	end,
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.descriptions["Gamemode"], self.key, self.loc_txt)
	end,
})
