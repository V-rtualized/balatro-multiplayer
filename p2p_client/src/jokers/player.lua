SMODS.Joker({
	key = "player",
	loc_txt = {
		name = "#1#",
		text = {
			"#2#",
			"#3#",
		},
	},
	config = {
		extra = {
			username = "Unknown",
			text1 = "",
			text2 = "",
		},
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.username, card.ability.extra.text1, card.ability.extra.text2 } }
	end,
	no_collection = true,
	unlocked = true,
	discovered = true,
	in_pool = function(self)
		return false
	end,
})
