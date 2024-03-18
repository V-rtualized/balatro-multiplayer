interface SMODS_T {
	Card: AnyTable;
	Deck: AnyTable;
	Decks: AnyTable;
	GUI: AnyTable;
	INIT: AnyTable;
	Joker: AnyTable;
	Jokers: AnyTable;
	MODS: AnyTable;
	Sprite: AnyTable;
	Sprites: AnyTable;
	customUIElements: AnyTable;
	end_calculate_context: (...args: any[]) => any;
	findModByID: (...args: any[]) => any;
	injectDecks: (...args: any[]) => any;
	injectJokers: (...args: any[]) => any;
	injectSprites: (...args: any[]) => any;
	registerUIElement: (...args: any[]) => any;
}

// biome-ignore lint/style/noVar:
declare var SMODS: SMODS_T;
// biome-ignore lint/style/noVar:
declare var G: AnyTable;
