MP.UI = {
	BTN = {}, -- For functions that are called from buttons
	DEF = {}, -- For functions that return a UI table
	VARS = {},
}

function MP.UI.show_mp_overlay_message(msg)
	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			padding = 0.2,
			contents = {
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.2, minw = 4 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "tm" },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = "Multiplayer",
										shadow = true,
										scale = 0.8,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.2, minw = 4 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "tm" },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = msg or "",
										shadow = true,
										scale = 0.5,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
							},
						},
					},
				},
			},
		}),
	})
end

local exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
function MP.UI.exit_overlay_menu(passed_self)
	if MP.UI.should_watch_player_cards then
		MP.UI.should_watch_player_cards = false
	end
	exit_overlay_menu_ref(passed_self)
end
G.FUNCS.exit_overlay_menu = MP.UI.exit_overlay_menu
