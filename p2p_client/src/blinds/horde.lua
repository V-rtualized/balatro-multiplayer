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
	boss_colour = HEX("67f9f2"),
	discovered = true,
	in_pool = function(self)
		return false
	end,
})

table.insert(MP.blinds, key)
