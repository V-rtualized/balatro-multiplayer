local key = "lets_go_gambling"

SMODS.Atlas({
	key = key,
	path = "j_lets_go_gambling.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = key,
	atlas = key,
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { x_mult = 1, extra = { denominator = 4, extra = 0.3, extra_extra = 0.2 } },
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				G.GAME.probabilities.normal,
				card.ability.extra.denominator,
				card.ability.extra.extra,
				card.ability.extra.extra_extra,
				card.ability.x_mult,
			},
		}
	end,
	in_pool = function(self)
		return MP.is_in_lobby()
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers then
			if context.joker_main then
				return {
					message = localize({
						type = "variable",
						key = "a_xmult",
						vars = { card.ability.x_mult },
					}),
					Xmult_mod = card.ability.x_mult,
				}
			end
			if context.end_of_round and not context.blueprint and not context.repetition and G.GAME.blind.boss then
				card.ability.extra.extra = card.ability.extra.extra + card.ability.extra.extra_extra
				return {
					message = localize({
						type = "variable",
						key = "a_xmult_plus",
						vars = { card.ability.extra.extra_extra },
					}),
				}
			end
		end
		if context.selling_self and not context.blueprint then
			if pseudorandom(self.key) > G.GAME.probabilities.normal / card.ability.extra.denominator then
				local new_card = copy_card(card)
				new_card:start_materialize()
				new_card:add_to_deck()
				G.jokers:emplace(new_card)
				new_card.ability.x_mult = card.ability.x_mult + card.ability.extra.extra
				new_card.ability.extra.extra = card.ability.extra.extra
			else
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.06 * G.SETTINGS.GAMESPEED,
					blockable = false,
					blocking = false,
					func = function()
						play_sound("tarot2", 0.76, 0.4)
						return true
					end,
				}))
				play_sound("tarot2", 1, 0.4)
				attention_text({
					text = localize("k_nope_ex"),
					scale = 0.8,
					hold = 0.8,
					major = card,
					backdrop_colour = G.C.SECONDARY_SET.Tarot,
					align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and "tm" or "cm",
					offset = {
						x = 0,
						y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0,
					},
					silent = true,
				})
			end
		end
	end,
	mp_credits = {
		idea = { "Dr. Monty", "Carter" },
		art = { "Carter" },
		code = { "Virtualized" },
	},
})

table.insert(MP.cards, key)
