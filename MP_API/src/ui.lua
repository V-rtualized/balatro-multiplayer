MPAPI.UI = {
	temp_vals = {
		code = "",
	},
}

function MPAPI.FUNCS.open_lobby(e)
	local action = MPAPI.NetworkAction(MPAPI.ACTIONS.OPEN_LOBBY_ACTION_TYPE)
	action:callback(MPAPI.FUNCS.OPEN_LOBBY_CALLBACK)
	action:send_to_server({})
end
G.FUNCS.mpapi_open_lobby = MPAPI.FUNCS.open_lobby

function MPAPI.FUNCS.join_lobby(e)
	local clip = MPAPI.get_from_clipboard()

	if type(clip) == "string" and clip ~= "" then
		local trimmed = clip:match("^%s*(.-)%s*$")
		if trimmed:match("^[%w][%w][%w][%w][%w][%w]$") ~= nil then
			local action = MPAPI.NetworkAction(MPAPI.ACTIONS.JOIN_LOBBY_ACTION_TYPE)
			action:callback(MPAPI.FUNCS.JOIN_LOBBY_CALLBACK)
			action:send_to_server({
				code = trimmed,
				checking = true,
			})
			return
		end
	end

	MPAPI.UI.create_join_lobby_overlay()
end
G.FUNCS.mpapi_join_lobby = MPAPI.FUNCS.join_lobby

function MPAPI.FUNCS.leave_lobby(e)
	local action = MPAPI.NetworkAction(MPAPI.ACTIONS.LEAVE_LOBBY_ACTION_TYPE)
	action:callback(MPAPI.FUNCS.LEAVE_LOBBY_CALLBACK)
	action:send_to_server({})
end
G.FUNCS.mpapi_leave_lobby = MPAPI.FUNCS.leave_lobby

function MPAPI.FUNCS.reconnect(e)
	MPAPI.reconnect_to_server()
	local action = MPAPI.NetworkAction(MPAPI.ACTIONS.CONNECT_ACTION_TYPE)
	action:callback(MPAPI.FUNCS.CONNECT_CALLBACK)
	action:send_to_server({
		username = G.PROFILES[G.SETTINGS.profile].name or "Guest",
	})
end
G.FUNCS.mpapi_reconnect = MPAPI.FUNCS.reconnect

function MPAPI.FUNCS.copy_code(e)
	e.config.colour = G.C.GREEN
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		blockable = false,
		blocking = false,
		timer = "REAL",
		delay = 0.5,
		func = function(t)
			e.config.colour = G.C.BLUE
			return true
		end,
	}))
	MPAPI.copy_to_clipboard(MPAPI.network_state.lobby)
end
G.FUNCS.mpapi_copy_code = MPAPI.FUNCS.copy_code

local set_main_menu_UI_ref = set_main_menu_UI
function MPAPI.UI.set_main_menu_UI()
	set_main_menu_UI_ref()

	MPAPI.FUNCS.draw_lobby_ui()
end
set_main_menu_UI = MPAPI.UI.set_main_menu_UI

function MPAPI.FUNCS.draw_lobby_ui()
	if MPAPI.LOBBY_UI then
		MPAPI.LOBBY_UI:remove()
	end

	if G.MAIN_MENU_UI then
		MPAPI.LOBBY_UI = UIBox({
			definition = MPAPI.UI.create_UIBox_lobby(),
			config = { align = "tl", offset = { x = 1.5, y = -10 }, major = G.ROOM_ATTACH, bond = "Weak" },
		})
		MPAPI.LOBBY_UI.alignment.offset.y = MPAPI.network_state.connected and 4 or 3
		MPAPI.LOBBY_UI:align_to_major()
	end
end

function MPAPI.UI.create_join_lobby_overlay()
	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			padding = 0,
			contents = {
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0, draw_layer = 1, minw = 4 },
					nodes = {
						create_tabs({
							tabs = {
								{
									label = localize("k_join_via_code"),
									chosen = true,
									tab_definition_function = MPAPI.UI.join_lobby_overlay,
								},
								{
									label = localize("k_quick_play"),
									tab_definition_function = MPAPI.UI.quick_play_overlay,
								},
							},
							snap_to_nav = true,
						}),
					},
				},
			},
		}),
	})
end

function MPAPI.UI.create_lobby_status()
	return {
		n = G.UIT.R,
		config = { align = "tm" },
		nodes = {
			{
				n = G.UIT.T,
				config = {
					text = MPAPI.is_in_lobby() and localize("k_in_lobby")
						or MPAPI.network_state.connected and localize("k_connected")
						or localize("k_disconnected"),
					shadow = true,
					scale = 0.3,
					colour = G.C.UI.TEXT_LIGHT,
				},
			},
		},
	}
end

function MPAPI.UI.create_lobby_version(additional_versions)
	additional_versions = additional_versions or {}

	table.insert(additional_versions, 1, "MPAPI_" .. MPAPI.VERSION)

	local rows = {}

	for _, v in ipairs(additional_versions) do
		table.insert(rows, {
			n = G.UIT.R,
			config = { align = "tm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = v,
						shadow = true,
						scale = 0.25,
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		})
	end

	return {
		n = G.UIT.R,
		config = { align = "tm" },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "tm" },
				nodes = rows,
			},
		},
	}
end

function MPAPI.UI.create_UIBox_lobby()
	local lobby_ui_btns = {
		MPAPI.UI.create_lobby_status(),
		{
			n = G.UIT.B,
			config = { align = "tm", minw = 1, minh = 1 },
		},
	}

	if MPAPI.is_in_lobby() then
		table.insert(
			lobby_ui_btns,
			UIBox_button({
				id = "main_menu_copy_code",
				button = "mpapi_copy_code",
				colour = G.C.BLUE,
				minw = 2,
				minh = 1,
				label = { localize("b_copy_code") },
				scale = 0.45,
			})
		)
		table.insert(
			lobby_ui_btns,
			UIBox_button({
				id = "main_menu_leave_lobby",
				button = "mpapi_leave_lobby",
				colour = G.C.RED,
				minw = 2,
				minh = 1,
				label = { localize("b_leave_lobby") },
				scale = 0.45,
			})
		)
	elseif MPAPI.network_state.connected then
		table.insert(
			lobby_ui_btns,
			UIBox_button({
				id = "main_menu_open_lobby",
				button = "mpapi_open_lobby",
				colour = MPAPI.BADGE_COLOUR,
				minw = 2,
				minh = 1,
				label = { localize("b_open_lobby") },
				scale = 0.45,
			})
		)
		table.insert(
			lobby_ui_btns,
			UIBox_button({
				id = "main_menu_join_lobby",
				button = "mpapi_join_lobby",
				colour = G.C.PURPLE,
				minw = 2,
				minh = 1,
				label = { localize("b_join_lobby") },
				scale = 0.45,
			})
		)
	else
		table.insert(
			lobby_ui_btns,
			UIBox_button({
				id = "main_menu_reconnect",
				button = "mpapi_reconnect",
				colour = G.C.PURPLE,
				minw = 2,
				minh = 1,
				label = { localize("b_reconnect") },
				scale = 0.45,
			})
		)
	end

	table.insert(lobby_ui_btns, MPAPI.UI.create_lobby_version())

	local t = {
		n = G.UIT.ROOT,
		config = { align = "cm", colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "bm" },
				nodes = {
					{
						n = G.UIT.C,
						config = {
							align = "cm",
							padding = 0.2,
							r = 0.1,
							emboss = 0.1,
							colour = G.C.L_BLACK,
							mid = true,
						},
						nodes = lobby_ui_btns,
					},
				},
			},
		},
	}
	return t
end

function MPAPI.UI.join_lobby_overlay()
	local t = {
		n = G.UIT.ROOT,
		config = { align = "cm", colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.1, minh = 0.8 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							create_text_input({
								w = 4,
								max_length = 6,
								prompt_text = localize("k_enter_code"),
								ref_table = MPAPI.UI.temp_vals,
								ref_value = "code",
								all_caps = true,
								callback = function()
									if G.OVERLAY_MENU then
										G.FUNCS:exit_overlay_menu()
									end
									local action = MPAPI.NetworkAction(MPAPI.ACTIONS.JOIN_LOBBY_ACTION_TYPE)
									action:callback(MPAPI.FUNCS.JOIN_LOBBY_CALLBACK)
									action:send_to_server({
										code = MPAPI.UI.temp_vals.code,
										checking = false,
									})
									G.E_MANAGER:add_event(Event({
										trigger = "after",
										blockable = false,
										blocking = false,
										timer = "REAL",
										delay = 1,
										func = function(t)
											MPAPI.UI.temp_vals.code = ""
											return true
										end,
									}))
								end,
							}),
						},
					},
				},
			},
		},
	}

	return t
end

function MPAPI.UI.quick_play_overlay()
	local t = {
		n = G.UIT.ROOT,
		config = { align = "cm", colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.1, minh = 0.8 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = localize("k_coming_soon"),
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
	}

	return t
end
