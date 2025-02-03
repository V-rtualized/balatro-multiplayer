sendDebugMessage("LOADED MPPACKED")
if not next(SMODS.find_mod("MultiplayerAPI")) and not next(SMODS.find_mod("Multiplayer")) then
	loadMods(SMODS.current_mod.path)
end
