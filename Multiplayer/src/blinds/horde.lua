local key = "horde"

SMODS.Atlas({
	key = key,
	path = "horde_blind_row.png",
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
	boss_colour = HEX("dfca81"),
	discovered = true,
	in_pool = function(self)
		return false
	end,
	variable_hud_text = function(self)
		return {
			ref_table = MP.game_state,
			ref_value = "ranking_position",
		}
	end,
	mp_credits = {
		art = { "Carter", "Aura!" },
		code = { "Virtualized" },
	},
})

table.insert(MP.blinds, "bl_mp_" .. key)
