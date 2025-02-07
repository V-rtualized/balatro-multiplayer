local key = "speedrun"

SMODS.Atlas({
	key = key,
	path = "j_speedrun.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = key,
	atlas = key,
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { current_nemesis = nil } },
	loc_vars = function(self, info_queue, card)
		MP.add_nemesis_info(info_queue, card.ability.extra.current_nemesis)
		return { vars = {} }
	end,
	in_pool = function(self) -- TODO: Convert to 1.0
		return false -- MPAPI.is_in_lobby()
	end,
	mp_credits = {
		idea = { "Dr. Monty", "Carter" },
		art = { "Aura!" },
		code = { "Virtualized" },
	},
})

table.insert(MP.cards, "j_mp_" .. key)
