----------------------------------------------
------------MOD BLIND-------------------------

local bl_pvp = {
	name = "Your Nemesis",
	defeated = false,
	order = 0,
	dollars = 5,
	mult = 0,
	vars = {},
	debuff = {},
	pos = { x = 0, y = 25 },
	boss_colour = HEX("ac3232"),
	boss = { min = 1, max = 10 },
	key = "bl_pvp",
}

G.P_BLINDS["bl_pvp"] = bl_pvp

local localize_ref = localize
function localize(args, misc_cat)
	if type(args) == "table" and args.key == "bl_pvp" and args.set == "Blind" then
		if args.type == "name_text" then
			return mp_localize("bl_pvp_name", "Your Nemesis")
		elseif args.type == "raw_descriptions" then
			return {
				mp_localize("bl_pvp_desc1", "Face another player,"),
				mp_localize("bl_pvp_desc2", "most chips wins"),
			}
		end
	end
	return localize_ref(args, misc_cat)
end

local create_UIBox_your_collection_blinds_ref = create_UIBox_your_collection_blinds
function create_UIBox_your_collection_blinds(exit)
	G.P_BLINDS["bl_pvp"] = nil
	local res = create_UIBox_your_collection_blinds_ref(exit)
	G.P_BLINDS["bl_pvp"] = bl_pvp
	return res
end

local set_discover_tallies_ref = set_discover_tallies
function set_discover_tallies()
	G.P_BLINDS["bl_pvp"] = nil
	local res = set_discover_tallies_ref()
	G.P_BLINDS["bl_pvp"] = bl_pvp
	return res
end

function is_pvp_boss()
	if not G.GAME or not G.GAME.blind then
		return false
	end
	return G.GAME.blind.name == "Your Nemesis"
end

----------------------------------------------
------------MOD BLIND END---------------------
