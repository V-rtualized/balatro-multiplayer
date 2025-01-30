local key = "defensive_joker"

SMODS.Atlas({
	key = key,
	path = "j_defensive_joker.png",
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
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { t_chips = 0, extra = { extra = 60 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.extra, card.ability.t_chips } }
	end,
	in_pool = function(self)
		return false -- MP.is_in_lobby()
	end,
	update = function(self, card, dt) -- TODO: Convert to 1.0
		if MP.is_in_lobby() then
			if G.STAGE == G.STAGES.RUN then
				--card.ability.t_chips = (G.LOBBY.config.starting_lives - G.MULTIPLAYER_GAME.lives) * card.ability.extra.extra
			end
		else
			card.ability.t_chips = 0
		end
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.joker_main then
			return {
				message = localize({
					type = "variable",
					key = "a_chips",
					vars = { card.ability.t_chips },
				}),
				chip_mod = card.ability.t_chips,
			}
		end
	end,
	mp_credits = {
		idea = { "didon't" },
		art = { "TheTrueRaven" },
		code = { "Virtualized" },
	},
})

table.insert(MP.cards, "j_mp_" .. key)
