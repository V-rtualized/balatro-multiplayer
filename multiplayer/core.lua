--- STEAMODDED HEADER
--- MOD_NAME: Multiplayer
--- MOD_ID: virtualizedMultiplayer
--- MOD_AUTHOR: [virtualized]
--- MOD_DESCRIPTION: Allows players to compete with their friends! Contact @virtualized on discord for mod assistance.
----------------------------------------------
------------MOD CORE--------------------------
MULTIPLAYER_VERSION = "0.1.0-MULTIPLAYER"

-- Credit to Henrik Ilgen (https://stackoverflow.com/a/6081639)
function serialize_table(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(" ", depth)

	if name then tmp = tmp .. name .. " = " end

	if type(val) == "table" then
			tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

			for k, v in pairs(val) do
					tmp =  tmp .. serialize_table(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
			end

			tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif type(val) == "number" then
			tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
			tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
			tmp = tmp .. (val and "true" or "false")
	else
			tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	return tmp
end

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

local modify_UIBox_main_menu_buttonRef = modify_UIBox_main_menu_button
function modify_UIBox_main_menu_button()
	local menu = modify_UIBox_main_menu_buttonRef()
	menu.nodes[1].nodes[1].nodes[1].nodes[1].config.button = "play_options"
	return(menu)
end
----------------------------------------------
------------MOD CORE END----------------------