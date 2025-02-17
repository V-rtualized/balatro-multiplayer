local key = "nemesis"

SMODS.Atlas({
	key = key,
	path = "nemesis_blind_row.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
	px = 34,
	py = 34,
})

SMODS.Blind({
	key = key,
	atlas = key,
	dollars = 5,
	mult = 1, -- Jen's Almanac crashes the game if the mult is 0
	boss = { min = 1, max = 10 },
	boss_colour = HEX("835aad"),
	discovered = true,
	in_pool = function(self)
		return false
	end,
	variable_hud_text = function(self)
		return {
			ref_table = MP.GAME_PLAYERS.BY_CODE[MP.game_state.nemesis],
			ref_value = "hands_left",
		}
	end,
	mp_credits = {
		art = { "KilledByLava" },
		code = { "Virtualized" },
	},
})

table.insert(MP.blinds, "bl_mp_" .. key)
