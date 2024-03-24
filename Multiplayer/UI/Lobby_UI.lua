--- STEAMODDED HEADER
--- STEAMODDED SECONDARY FILE

----------------------------------------------
------------MOD LOBBY UI----------------------

local Disableable_Button = require("Components.Disableable_Button")

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
						text = (G.LOBBY.code and "In Lobby")
							or (G.LOBBY.connected and "Connected to Service")
							or "WARN: Cannot Find Multiplayer Service",
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

local function createClickableFriendBox(steamInfo, scale)
	return {
		n = G.UIT.R,
		config = {
			padding = 0,
			align = "cm",
		},
		nodes = {
			UIBox_button({
				label = {" " .. steamInfo.name .. " "},
				shadow = true,
				scale = scale,
				colour = G.C.BOOSTER,
				button = "inviteSteamFriend_" .. steamInfo.id,
				minh = 0.8,
				minw = 8
			})
		}
	}
end

local function recalculateSteamList(page)
	local friendsPerPage = 4
	local startIndex = (page - 1) * friendsPerPage + 1
	local endIndex = startIndex + friendsPerPage - 1
	local totalPages = math.ceil(#SMODS.MODS / friendsPerPage)
	local currentPage = "Page " .. page .. "/" .. totalPages
	local pageOptions = {}
	for i = 1, totalPages do
		table.insert(pageOptions, ("Page " .. i .. "/" .. totalPages))
	end
	local showingList = #SMODS.MODS > 0

	return currentPage, pageOptions, showingList, startIndex, endIndex, friendsPerPage
end

function SMODS.GUI.dynamicSteamListContent(page)
	local scale = 0.75
	local _, __, showingList, startIndex, endIndex, friendsPerPage = recalculateSteamList(page)

	local steamNodes = {}

	-- If no mods are loaded, show a default message
	if showingList == false then
		table.insert(steamNodes, {
			n = G.UIT.R,
			config = {
				padding = 0,
				align = "cm"
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = "No friends have been detected...",
						shadow = true,
						scale = scale * 0.5,
						colour = G.C.UI.TEXT_DARK
					}
				}
			}
		})
	else
		local steamCount = 0
		for id, steamInfo in ipairs(SMODS.MODS) do
			if id >= startIndex and id <= endIndex then
				table.insert(steamNodes, createClickableFriendBox(steamInfo, scale * 0.5))
				steamCount = steamCount + 1
				if steamCount >= friendsPerPage then break end
			end
		end
	end

	return {
		n = G.UIT.R,
		config = {
			r = 0.1,
			align = "cm",
			padding = 0.2,
		},
		nodes = steamNodes
	}
end

function SMODS.GUI.staticInviteListContent()
	local scale = 0.75
	local currentPage, pageOptions, showingList = recalculateSteamList(1)
	return {
		n = G.UIT.ROOT,
		config = {
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "tm",
			padding = 0.2,
			colour = G.C.BLACK
		},
		nodes = {
			-- row container
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.05 },
				nodes = {
					-- column container
					{
						n = G.UIT.C,
						config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
						nodes = {
							-- title row
							{
								n = G.UIT.R,
								config = {
									padding = 0.05,
									align = "cm"
								},
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "Steam Friends",
											shadow = true,
											scale = scale * 0.6,
											colour = G.C.UI.TEXT_LIGHT
										}
									}
								}
							},

							-- add some empty rows for spacing
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},

							-- dynamic content rendered in this row container
							-- list of 4 mods on the current page
							{
								n = G.UIT.R,
								config = {
									padding = 0.05,
									align = "cm",
									minh = 2,
									minw = 4
								},
								nodes = {
									{n=G.UIT.O, config={id = 'steamList', object = Moveable()}},
								}
							},

							-- another empty row for spacing
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.3 },
								nodes = {}
							},

							-- page selector
							-- does not appear when list of mods is empty
							showingList and SMODS.GUI.createOptionSelector({label = "", scale = 0.8, options = pageOptions, opt_callback = 'update_steam_list', no_pips = true, current_option = (
									currentPage
							)}) or nil
						}
					},
				}
			},
		}
	}
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
						align = "cm"
					},
					nodes = {
						create_tabs({
							snap_to_nav = true,
							colour = G.C.BOOSTER,
							tabs = {
								{
									label = "Steam",
									chosen = true,
									tab_definition_function = function()
										return SMODS.GUI.DynamicUIManager.initTab({
											updateFunctions = {
												modsList = G.FUNCS.update_mod_list,
											},
											staticPageDefinition = SMODS.GUI.staticModListContent()
										})
									end
								},
								{
									label = "Code",
									tab_definition_function = function()
										return (
											{
												n = G.UIT.ROOT,
												config = {
													emboss = 0.05,
													minh = 6,
													r = 0.1,
													minw = 6,
													align = "cm",
													padding = 0.2,
													colour = G.C.BLACK
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
																label = { "Copy to Clipboard" },
																colour = G.C.BLUE,
																button = "copy_to_clipboard",
																minw = 5,
															}),
														},
													}
												}
											}
										)
									end
								}
							}
						})
					}
				}
			}
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
								label = { "START" },
								disabled_text = G.LOBBY.is_host and { "WAITING FOR", "PLAYERS" }
									or { "WAITING FOR", "HOST TO START" },
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
									Disableable_Button({
										button = "lobby_options",
										colour = G.C.ORANGE,
										minw = 3.15,
										minh = 1.35,
										label = { "LOBBY OPTIONS" },
										scale = text_scale * 1.2,
										col = true,
										enabled_ref_table = G.LOBBY,
										enabled_ref_value = "is_host",
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
															text = "Connected Players:",
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
										label = { "INVITE" },
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
								label = { "LEAVE" },
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
									text = "Not Implemented Yet",
									shadow = true,
									scale = 0.6,
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					},
				},
			},
		},
	})
end

function G.UIDEF.create_UIBox_invite_steam_friends()
	return create_UIBox_generic_options({
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
							SMODS.GUI.createOptionSelector({label = "", scale = 0.8, options = pageOptions, opt_callback = 'update_mod_list', no_pips = true, current_option = (
									currentPage
							)})
						},
					},
				},
			},
		},
	})
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

function G.FUNCS.invite_steam_friends(e)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_invite_steam_friends(),
	})
end

---@type fun(e: table | nil, args: { deck: string, stake: number | nil, seed: string | nil })
function G.FUNCS.lobby_start_run(e, args)
	G.FUNCS.start_run(e, {
		stake = 1,
		seed = args.seed,
		challenge = {
			name = "Multiplayer Deck",
			id = "c_multiplayer_1",
			rules = {
				custom = {},
				modifiers = {},
			},
			jokers = {},
			consumeables = {},
			vouchers = {},
			deck = {
				type = "Challenge Deck",
			},
			restrictions = {
				banned_cards = {
					{ id = "j_diet_cola" }, -- Intention to disable skipping
					{ id = "j_mr_bones" },
					{ id = "v_hieroglyph" },
					{ id = "v_petroglyph" },
				},
				banned_tags = {},
				banned_other = {},
			},
		},
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
	end
	gameUpdateRef(self, dt)
end

----------------------------------------------
------------MOD LOBBY UI END------------------
