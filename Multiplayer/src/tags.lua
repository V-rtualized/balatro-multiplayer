SMODS.take_ownership("tag_negative", {
	in_pool = function(self, args)
		if MP.is_in_lobby() then
			return true -- Can spawn in any ante while in multiplayer
		end
		return G.GAME.round_resets.ante >= args.min_ante
	end,
}, true)

SMODS.take_ownership("tag_standard", {
	in_pool = function(self, args)
		if MP.is_in_lobby() then
			return true -- Can spawn in any ante while in multiplayer
		end
		return G.GAME.round_resets.ante >= args.min_ante
	end,
}, true)

SMODS.take_ownership("tag_rare", {
	in_pool = function(self, args)
		if MP.is_in_lobby() then
			return G.GAME.round_resets.ante >= 2 -- Effectively min_ante = 2 while in multiplayer
		end
		return true
	end,
}, true)

SMODS.take_ownership("tag_uncommon", {
	in_pool = function(self, args)
		if MP.is_in_lobby() then
			return G.GAME.round_resets.ante >= 2 -- Effectively min_ante = 2 while in multiplayer
		end
		return true
	end,
}, true)
