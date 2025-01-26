function G.UIDEF.override_main_menu_play_button()
	return (
		create_UIBox_generic_options({
			contents = {
				UIBox_button({
					label = { "Singleplayer" },
					colour = G.C.BLUE,
					button = "setup_run",
					minw = 5,
				}),
				UIBox_button({
					label = { "Connect to Peer" },
					colour = G.C.RED,
					button = "connect_to_peer",
					minw = 5,
				}) or nil,
			},
		})
	)
end

function G.FUNCS.play_options(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = G.UIDEF.override_main_menu_play_button(),
	})
end

function G.FUNCS.connect_to_peer(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_connect_to_peer_button(),
	})
end

function G.UIDEF.create_UIBox_connect_to_peer_button()
	return (
		create_UIBox_generic_options({
			back_func = "play_options",
			contents = {
				{
					n = G.UIT.R,
					config = {
						padding = 0,
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.C,
							config = {
								padding = 0.5,
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										scale = 0.3,
										text = MP.code,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
								create_text_input({
									w = 4,
									h = 1,
									max_length = 6,
									prompt_text = "Enter Peer Code",
									all_caps = true,
									ref_table = MP,
									ref_value = "temp_code",
									extended_corpus = false,
									keyboard_offset = 1,
									minw = 5,
									callback = function(val)
										MP.joinLobby(MP.temp_code)
									end,
								}),
							},
						},
					},
				},
			},
		})
	)
end

local create_UIBox_main_menu_buttonsRef = create_UIBox_main_menu_buttons
---@diagnostic disable-next-line: lowercase-global
function create_UIBox_main_menu_buttons()
	local menu = create_UIBox_main_menu_buttonsRef()
	menu.nodes[1].nodes[1].nodes[1].nodes[1].config.button = "play_options"
	return menu
end
