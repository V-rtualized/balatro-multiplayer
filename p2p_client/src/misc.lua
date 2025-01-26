local load_profile_ref = G.FUNCS.load_profile
G.FUNCS.load_profile = function(delete_prof_data)
	load_profile_ref(delete_prof_data)
	MP.send.set_username()
end

local save_settings_ref = Game.save_settings
function Game:save_settings()
	save_settings_ref(self)
	MP.send.set_username()
end
