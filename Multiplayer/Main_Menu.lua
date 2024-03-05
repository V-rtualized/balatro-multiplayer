----------------------------------------------
------------MOD MAIN MENU---------------------

local Debug = require "Debug"

MULTIPLAYER_VERSION = "0.1.0-MULTIPLAYER"

local gameMainMenuRef = Game.main_menu
function Game.main_menu(arg_280_0, arg_280_1)
	gameMainMenuRef(arg_280_0, arg_280_1)
	UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = {
				align = "cm",
				colour = G.C.UI.TRANSPARENT_DARK
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.3,
						text = MULTIPLAYER_VERSION,
						colour = G.C.UI.TEXT_LIGHT
					}
				}
			}
		},
		config = {
			align = "tri",
			bond = "Weak",
			offset = {
				x = 0,
				y = 0.6
			},
			major = G.ROOM_ATTACH
		}
	})
end

function create_UIBox_multiplayer_button()
	local var_495_0 = 0.75

	return (create_UIBox_generic_options({
		contents = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm"
				},
				nodes = {
					create_tabs({
						snap_to_nav = true,
						colour = G.C.BOOSTER,
						tabs = {
							{
								label = "Create Lobby",
								chosen = true,
								tab_definition_function = function()
									return {
										n = G.UIT.ROOT,
										config = {
											emboss = 0.05,
											minh = 6,
											r = 0.1,
											minw = 10,
											align = "tm",
											padding = 0.2,
											colour = G.C.BLACK
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm"
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = "Test",
															shadow = true,
															scale = var_495_0 * 0.6,
															colour = G.C.UI.TEXT_LIGHT
														}
													}
												}
											}
										}
									}
								end
							},
							{
								label = "Join Lobby",
								tab_definition_function = function()
									return {
										n = G.UIT.ROOT,
										config = {
											emboss = 0.05,
											minh = 6,
											r = 0.1,
											minw = 10,
											align = "tm",
											padding = 0.2,
											colour = G.C.BLACK
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm"
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = "Test",
															shadow = true,
															scale = var_495_0 * 0.6,
															colour = G.C.UI.TEXT_LIGHT
														}
													}
												}
											}
										}
									}
								end
							}
						}
					})
				}
			}
		}
	}))
end

function override_main_menu_play_button()
	local var_495_0 = 0.75

	return (create_UIBox_generic_options({
		contents = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm"
				},
				nodes = {
					UIBox_button({
						label = {"Singleplayer"},
						shadow = true,
						scale = var_495_0 * 0.6,
						colour = G.C.BLUE,
						button = "setup_run",
						minh = 0.8,
						minw = 8,
					}),
					UIBox_button({
						label = {"Create Lobby"},
						shadow = true,
						scale = var_495_0 * 0.6,
						colour = G.C.GREEN,
						button = "create_lobby",
						minh = 0.8,
						minw = 8,
					}),
					UIBox_button({
						label = {"Join Lobby"},
						shadow = true,
						scale = var_495_0 * 0.6,
						colour = G.C.RED,
						button = "join_lobby",
						minh = 0.8,
						minw = 8,
					}),
				}
			}
		}
	}))
end

function G.FUNCS.play_options(arg_736_0)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = override_main_menu_play_button()
	})
end

function G.FUNCS.create_lobby(arg_736_0)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = create_UIBox_multiplayer_button()
	})
end

function G.FUNCS.join_lobby(arg_736_0)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = create_UIBox_multiplayer_button()
	})
end

-- Modify play button to take you to mode select first
local create_UIBox_main_menu_buttonsRef = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
	local menu = create_UIBox_main_menu_buttonsRef()
	menu.nodes[1].nodes[1].nodes[1].nodes[1].config.button = "play_options"
	sendDebugMessage(Debug.serialize_table(Debug))
	return(menu)
end

----------------------------------------------
------------MOD MAIN MENU END-----------------