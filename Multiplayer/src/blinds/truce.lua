local key = "truce"

SMODS.Atlas({
	key = key,
	path = "truce_blind_row.png",
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
	boss_colour = HEX("6dc0be"),
	discovered = true,
	in_pool = function(self)
		return false
	end,
	loc_vars = function(self)
		return { vars = { "The Horde" } }
	end,
	mp_credits = {
		art = { "Aura!" },
		code = { "Virtualized" },
	},
})

table.insert(MP.blinds, "bl_mp_" .. key)
