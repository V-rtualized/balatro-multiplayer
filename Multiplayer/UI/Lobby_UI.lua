local Disableable_Button = G.MULTIPLAYER.COMPONENTS.Disableable_Button
local Disableable_Toggle = G.MULTIPLAYER.COMPONENTS.Disableable_Toggle
local Disableable_Option_Cycle = G.MULTIPLAYER.COMPONENTS.Disableable_Option_Cycle

local function toggle_lobby_options(value)
	G.MULTIPLAYER.lobby_options()
end

G.HUD_connection_status = nil

function G.UIDEF.get_connection_status_ui()
	return UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = {
				align = "cm",
				colour = G.C.UI.TRANSPARENT_DARK,
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.3,
						text = (G.LOBBY.code and mp_localize("in_lobby", "In Lobby"))
							or (G.LOBBY.connected and mp_localize("connected", "Connected to Service"))
							or mp_localize("warn_service", "WARN: Cannot Find Multiplayer Service"),
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		},
		config = {
			align = "tri",
			bond = "Weak",
			offset = {
				x = 0,
				y = 0.9,
			},
			major = G.ROOM_ATTACH,
		},
	})
end

function G.UIDEF.create_UIBox_view_code()
	local var_495_0 = 0.75

	return (
		create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.R,
					config = {
						padding = 0,
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {
								padding = 0.5,
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = G.LOBBY.code,
										shadow = true,
										scale = var_495_0 * 0.6,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = {
								padding = 0,
								align = "cm",
							},
							nodes = {
								UIBox_button({
									label = { mp_localize("copy_clipboard", "Copy to Clipboard") },
									colour = G.C.BLUE,
									button = "copy_to_clipboard",
									minw = 5,
								}),
							},
						},
					},
				},
			},
		})
	)
end

function G.UIDEF.create_UIBox_lobby_menu()
	local text_scale = 0.45

	local t = {
		n = G.UIT.ROOT,
		config = {
			align = "cm",
			colour = G.C.CLEAR,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = {
					align = "bm",
				},
				nodes = {
					G.LOBBY.username == "Guest" and {
						n = G.UIT.R,
						config = {
							padding = 0.1,
							align = "cm",
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									scale = 0.3,
									shadow = true,
									text = mp_localize(
										"set_name",
										"Set your username in the main menu! (Mods > Multiplayer > Config)"
									),
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					} or nil,
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							padding = 0.2,
							r = 0.1,
							emboss = 0.1,
							colour = G.C.L_BLACK,
							mid = true,
						},
						nodes = {
							Disableable_Button({
								id = "lobby_menu_start",
								button = "lobby_start_game",
								colour = G.C.BLUE,
								minw = 3.65,
								minh = 1.55,
								label = { mp_localize("start", "START") },
								disabled_text = G.LOBBY.is_host and {
									mp_localize("wait_for", "WAITING FOR"),
									mp_localize("players", "PLAYERS"),
								} or {
									mp_localize("wait_for", "WAITING FOR"),
									mp_localize("host_start", "HOST TO START"),
								},
								scale = text_scale * 2,
								col = true,
								enabled_ref_table = G.LOBBY,
								enabled_ref_value = "ready_to_start",
							}),
							{
								n = G.UIT.C,
								config = {
									align = "cm",
								},
								nodes = {
									UIBox_button({
										button = "lobby_options",
										colour = G.C.ORANGE,
										minw = 3.15,
										minh = 1.35,
										label = { mp_localize("lobby_options_cap", "LOBBY OPTIONS") },
										scale = text_scale * 1.2,
										col = true,
									}),
									{
										n = G.UIT.C,
										config = {
											align = "cm",
											minw = 0.2,
										},
										nodes = {},
									},
									{
										n = G.UIT.C,
										config = {
											align = "tm",
											minw = 2.65,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0.2,
													align = "cm",
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = mp_localize("connect_player", "Connected Players:"),
															shadow = true,
															scale = text_scale * 0.8,
															colour = G.C.UI.TEXT_LIGHT,
														},
													},
												},
											},
											G.LOBBY.host.username and {
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm",
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															ref_table = G.LOBBY.host,
															ref_value = "username",
															shadow = true,
															scale = text_scale * 0.8,
															colour = G.C.UI.TEXT_LIGHT,
														},
													},
												},
											} or nil,
											G.LOBBY.guest.username and {
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm",
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															ref_table = G.LOBBY.guest,
															ref_value = "username",
															shadow = true,
															scale = text_scale * 0.8,
															colour = G.C.UI.TEXT_LIGHT,
														},
													},
												},
											} or nil,
										},
									},
									{
										n = G.UIT.C,
										config = {
											align = "cm",
											minw = 0.2,
										},
										nodes = {},
									},
									UIBox_button({
										button = "view_code",
										colour = G.C.PALE_GREEN,
										minw = 3.15,
										minh = 1.35,
										label = { mp_localize("view_code", "VIEW CODE") },
										scale = text_scale * 1.2,
										col = true,
									}),
								},
							},
							UIBox_button({
								id = "lobby_menu_leave",
								button = "lobby_leave",
								colour = G.C.RED,
								minw = 3.65,
								minh = 1.55,
								label = { mp_localize("leave", "LEAVE") },
								scale = text_scale * 1.5,
								col = true,
							}),
						},
					},
				},
			},
		},
	}
	return t
end

function G.UIDEF.create_UIBox_lobby_options()
	return create_UIBox_generic_options({
		contents = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm",
				},
				nodes = {
					not G.LOBBY.is_host and {
						n = G.UIT.R,
						config = {
							padding = 0.3,
							align = "cm",
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									scale = 0.6,
									shadow = true,
									text = mp_localize(
										"opts_only_host",
										"Only the Lobby Host can change these options"
									),
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					} or nil,
					create_tabs({
						snap_to_nav = true,
						colour = G.C.BOOSTER,
						tabs = {
							{
								label = mp_localize("lobby_options", "Lobby Options"),
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
											colour = G.C.BLACK,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "gold_on_life_loss_toggle",
														enabled_ref_table = G.LOBBY,
														enabled_ref_value = "is_host",
														label = mp_localize(
															"opts_cb_money",
															"Give comeback gold on life loss"
														),
														ref_table = G.LOBBY.config,
														ref_value = "gold_on_life_loss",
														callback = toggle_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "no_gold_on_round_loss_toggle",
														enabled_ref_table = G.LOBBY,
														enabled_ref_value = "is_host",
														label = mp_localize(
															"opts_no_gold_on_loss",
															"Don't get blind gold on round loss"
														),
														ref_table = G.LOBBY.config,
														ref_value = "no_gold_on_round_loss",
														callback = toggle_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "death_on_round_loss_toggle",
														enabled_ref_table = G.LOBBY,
														enabled_ref_value = "is_host",
														label = mp_localize(
															"opts_death_on_loss",
															"Lose a life on non-PvP round loss"
														),
														ref_table = G.LOBBY.config,
														ref_value = "death_on_round_loss",
														callback = toggle_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "different_seeds_toggle",
														enabled_ref_table = G.LOBBY,
														enabled_ref_value = "is_host",
														label = mp_localize(
															"opts_diff_seeds",
															"Players have different seeds"
														),
														ref_table = G.LOBBY.config,
														ref_value = "different_seeds",
														callback = toggle_lobby_options,
													}),
												},
											},
										},
									}
								end,
							},
							{
								label = mp_localize("opts_gm", "Gamemode Modifiers"),
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
											colour = G.C.BLACK,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm",
												},
												nodes = {
													Disableable_Option_Cycle({
														id = "starting_lives_option",
														enabled_ref_table = G.LOBBY,
														enabled_ref_value = "is_host",
														label = mp_localize("opts_lives", "Lives"),
														options = { 1, 2, 4, 6, 8 },
														current_option = G.LOBBY.config.starting_lives < 4
																and G.LOBBY.config.starting_lives
															or G.LOBBY.config.starting_lives == 4 and 3
															or G.LOBBY.config.starting_lives == 6 and 4
															or 5,
														opt_callback = "change_starting_lives",
													}),
													G.LOBBY.type == "draft"
															and Disableable_Option_Cycle({
																id = "draft_starting_antes_option",
																enabled_ref_table = G.LOBBY,
																enabled_ref_value = "is_host",
																label = mp_localize(
																	"opts_start_antes",
																	"Starting Antes"
																),
																options = { 2, 3, 4, 5, 6, 7 },
																current_option = G.LOBBY.config.draft_starting_antes
																	- 1,
																opt_callback = "change_draft_starting_antes",
															})
														or nil,
												},
											},
										},
									}
								end,
							},
						},
					}),
				},
			},
		},
	})
end

G.FUNCS.change_starting_lives = function(args)
	G.LOBBY.config.starting_lives = args.to_val
	toggle_lobby_options()
end

G.FUNCS.change_draft_starting_antes = function(args)
	G.LOBBY.config.draft_starting_antes = args.to_val
	toggle_lobby_options()
end

function G.FUNCS.get_lobby_main_menu_UI(e)
	return UIBox({
		definition = G.UIDEF.create_UIBox_lobby_menu(),
		config = {
			align = "bmi",
			offset = {
				x = 0,
				y = 10,
			},
			major = G.ROOM_ATTACH,
			bond = "Weak",
		},
	})
end

---@type fun(e: table | nil, args: { deck: string, stake: number | nil, seed: string | nil })
function G.FUNCS.lobby_start_run(e, args)
	G.FUNCS.start_run(e, {
		stake = 1,
		seed = args.seed,
		challenge = G.CHALLENGES[get_challenge_int_from_id("c_multiplayer_1")],
	})
end

function G.FUNCS.lobby_start_game(e)
	G.MULTIPLAYER.start_game()
end

function G.FUNCS.lobby_options(e)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_lobby_options(),
	})
end

function G.FUNCS.view_code(e)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_view_code(),
	})
end

function G.FUNCS.lobby_leave(e)
	G.LOBBY.code = nil
	G.MULTIPLAYER.leave_lobby()
	G.MULTIPLAYER.update_connection_status()
end

function G.FUNCS.display_lobby_main_menu_UI(e)
	G.MAIN_MENU_UI = G.FUNCS.get_lobby_main_menu_UI(e)
	G.MAIN_MENU_UI.alignment.offset.y = 0
	G.MAIN_MENU_UI:align_to_major()

	G.CONTROLLER:snap_to({ node = G.MAIN_MENU_UI:get_UIE_by_ID("lobby_menu_start") })
end

function G.FUNCS.return_to_lobby()
	G.MULTIPLAYER.stop_game()
end

local set_main_menu_UI_ref = set_main_menu_UI
---@diagnostic disable-next-line: lowercase-global
function set_main_menu_UI()
	if G.LOBBY.code then
		G.FUNCS.display_lobby_main_menu_UI()
	else
		set_main_menu_UI_ref()
	end
end

local in_lobby = false
local gameUpdateRef = Game.update
---@diagnostic disable-next-line: duplicate-set-field
function Game:update(dt)
	if (G.LOBBY.code and not in_lobby) or (not G.LOBBY.code and in_lobby) then
		in_lobby = not in_lobby
		G.F_NO_SAVING = in_lobby
		self.FUNCS.go_to_menu()
		reset_game_states()
	end
	gameUpdateRef(self, dt)
end
