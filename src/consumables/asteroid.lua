local key = "asteroid"

SMODS.Atlas({
	key = key,
	path = "c_asteroid.png",
	px = 63,
	py = 93,
})

SMODS.Consumable({
	key = key,
	atlas = key,
	set = "Planet",
	cost = 3,
	unlocked = true,
	discovered = true,
	config = { extra = { current_nemesis = nil } },
	loc_vars = function(self, info_queue, card)
		MP.add_nemesis_info(info_queue, card.ability.extra.current_nemesis)
		return { vars = { 1 } }
	end,
	in_pool = function(self)
		return false --MPAPI.is_in_lobby()
	end,
	can_use = function(self, card)
		return true
	end,
	use = function(self, card, area, copier)
		--G.MULTIPLAYER.asteroid()
	end,
	set_card_type_badge = function(self, card, badges)
		badges[#badges + 1] = create_badge(localize("k_planetesimal"), G.C.SECONDARY_SET["Planet"], nil, 1.2)
	end,
	mp_credits = {
		idea = { "Zilver" },
		art = { "TheTrueRaven" },
		code = { "Virtualized" },
	},
})

table.insert(MP.cards, key)
