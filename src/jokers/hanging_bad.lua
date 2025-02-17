local key = "hanging_bad"

SMODS.Atlas({
	key = key,
	path = "j_hanging_bad.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = key,
	atlas = key,
	rarity = 1,
	cost = 4,
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
	add_to_deck = function(self, card, from_debuff) -- TODO: Convert to 1.0
		if card.edition and card.edition.type ~= "e_mp_phantom" then
			return
		end
		--G.MULTIPLAYER.send_phantom("j_mp_hanging_bad")
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and MP.is_pvp_boss() then
			if context.before and context.scoring_hand then
				context.scoring_hand[1]:set_debuff(true)
			end
			if context.after and context.scoring_hand then
				context.scoring_hand[1]:set_debuff(false)
			end
		end
	end,
	remove_from_deck = function(self, card, from_debuff) -- TODO: Convert to 1.0
		if card.edition and card.edition.type ~= "e_mp_phantom" then
			return
		end
		--G.MULTIPLAYER.remove_phantom("j_mp_hanging_bad")
	end,
	in_pool = function(self)
		return false -- MPAPI.is_in_lobby()
	end,
	mp_credits = {
		idea = { "Dr. Monty", "Carter" },
		art = { "TheTrueRaven" },
		code = { "Virtualized" },
	},
})

table.insert(MP.cards, "j_mp_" .. key)
