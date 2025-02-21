if SMODS.Mods["Pokermon"] and SMODS.Mods["Pokermon"].can_load then
	sendDebugMessage("Pokermon compatibility detected", "MULTIPLAYER")
	G.MULTIPLAYER.DECK.ban_card("j_poke_koffing")
	G.MULTIPLAYER.DECK.ban_card("j_poke_weezing")
	G.MULTIPLAYER.DECK.ban_card("j_poke_mimikyu")

	-- Tournament Bans
	G.MULTIPLAYER.DECK.ban_card("j_poke_dragapult")
	G.MULTIPLAYER.DECK.ban_card("j_poke_dreepy")
	G.MULTIPLAYER.DECK.ban_card("j_poke_drakloak")
	G.MULTIPLAYER.DECK.ban_card("j_poke_dreepy_dart")
	G.MULTIPLAYER.DECK.ban_card("j_poke_ponyta")
	G.MULTIPLAYER.DECK.ban_card("j_poke_rapidash")
	G.MULTIPLAYER.DECK.ban_card("j_poke_charmander")
	G.MULTIPLAYER.DECK.ban_card("j_poke_charmeleon")
	G.MULTIPLAYER.DECK.ban_card("j_poke_charizard")
	G.MULTIPLAYER.DECK.ban_card("j_poke_mega_charizard_x")
	G.MULTIPLAYER.DECK.ban_card("j_poke_mega_charizard_y")
	G.MULTIPLAYER.DECK.ban_card("j_poke_litwick")
	G.MULTIPLAYER.DECK.ban_card("j_poke_lampent")
	G.MULTIPLAYER.DECK.ban_card("j_poke_beldum")
	G.MULTIPLAYER.DECK.ban_card("j_poke_metang")
	G.MULTIPLAYER.DECK.ban_card("j_poke_metagross")
end
