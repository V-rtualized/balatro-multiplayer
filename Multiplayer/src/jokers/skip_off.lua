local key = "skip_off"

SMODS.Atlas({
	key = key,
	path = "j_skip_off.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = key,
	atlas = key,
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { h_size = 0, d_size = 0, extra = { extra_hands = 1, extra_discards = 1, current_nemesis = nil } },
	loc_vars = function(self, info_queue, card) -- TODO: Convert to 1.0
		MP.add_nemesis_info(info_queue, card.ability.extra.current_nemesis)
		return {
			vars = {
				card.ability.extra.extra_hands,
				card.ability.extra.extra_discards,
				card.ability.h_size,
				card.ability.d_size,
				"Tied" --[[G.GAME.skips ~= nil and G.MULTIPLAYER_GAME.enemy.skips ~= nil and localize({
					type = "variable",
					key = G.MULTIPLAYER_GAME.enemy.skips > G.GAME.skips and "mp_skips_behind"
						or G.MULTIPLAYER_GAME.enemy.skips == G.GAME.skips and "mp_skips_tied"
						or "mp_skips_ahead",
					vars = { math.abs(G.MULTIPLAYER_GAME.enemy.skips - G.GAME.skips) },
				})[1] or "",]],
			},
		}
	end,
	in_pool = function(self)
		return false -- MP.is_in_lobby()
	end,
	update = function(self, card, dt) -- TODO: Convert to 1.0
		--[[if G.STAGE == G.STAGES.RUN and G.GAME.skips ~= nil and G.MULTIPLAYER_GAME.enemy.skips ~= nil then
			local skip_diff = 0 --(math.max(G.GAME.skips - G.MULTIPLAYER_GAME.enemy.skips, 0))
			card.ability.h_size = skip_diff * card.ability.extra.extra_hands
			card.ability.d_size = skip_diff * card.ability.extra.extra_discards
		end]]
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.setting_blind and not context.blueprint then
			G.E_MANAGER:add_event(Event({
				func = function()
					ease_hands_played(card.ability.h_size)
					ease_discard(card.ability.d_size, nil, true)
					return true
				end,
			}))
		end
	end,
	mp_credits = {
		idea = { "Dr. Monty", "Carter" },
		art = { "Aura!" },
		code = { "Virtualized" },
	},
})

table.insert(MP.cards, "j_mp_" .. key)
