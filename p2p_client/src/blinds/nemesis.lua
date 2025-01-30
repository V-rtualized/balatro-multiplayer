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
	boss_colour = HEX("ac3232"),
	discovered = true,
	in_pool = function(self)
		return false
	end,
})

table.insert(MP.blinds, "bl_mp_" .. key)
