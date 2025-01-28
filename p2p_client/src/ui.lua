MP.UI = {}

function G.FUNCS.mp_open_lobby(e)
	MP.send.open_lobby()
end

function G.FUNCS.mp_join_lobby(e)
	MP.send.join_lobby("AAAAAA")
end

function G.FUNCS.mp_reconnect(e)
	MP.send.connect()
end

local set_main_menu_UI_ref = set_main_menu_UI
function set_main_menu_UI()
	set_main_menu_UI_ref()

	MP.draw_lobby_ui()
end

function MP.draw_lobby_ui()
	if MP.LOBBY_UI then
		MP.LOBBY_UI:remove()
	end

	if G.MAIN_MENU_UI then
		MP.LOBBY_UI = UIBox({
			definition = MP.create_UIBox_lobby(),
			config = { align = "tl", offset = { x = 1.2, y = -10 }, major = G.ROOM_ATTACH, bond = "Weak" },
		})
		MP.LOBBY_UI.alignment.offset.y = MP.network_state.connected and 2.5 or 1.7
		MP.LOBBY_UI:align_to_major()
	end
end

function MP.create_UIBox_lobby()
	local text_scale = 0.45

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
						nodes = {
							{
								n = G.UIT.R,
								config = { align = "tm" },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = MP.version,
											shadow = true,
											scale = text_scale * 0.65,
											colour = G.C.UI.TEXT_LIGHT,
										},
									},
								},
							},
							{
								n = G.UIT.B,
								config = { align = "tm", minw = 1, minh = 1 },
							},
							MP.network_state.connected and UIBox_button({
								id = "main_menu_open_lobby",
								button = "mp_open_lobby",
								colour = MP.badge_colour,
								minw = 2,
								minh = 1,
								label = { localize("b_open_lobby") },
								scale = text_scale,
							}) or nil,
							MP.network_state.connected and UIBox_button({
								id = "main_menu_join_lobby",
								button = "mp_join_lobby",
								colour = G.C.PURPLE,
								minw = 2,
								minh = 1,
								label = { localize("b_join_lobby") },
								scale = text_scale,
							}) or nil,
							not MP.network_state.connected and {
								n = G.UIT.R,
								config = { align = "tm" },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = localize("not_connected"),
											shadow = true,
											scale = text_scale * 0.5,
											colour = G.C.UI.TEXT_LIGHT,
										},
									},
								},
							} or nil,
							not MP.network_state.connected and UIBox_button({
								id = "main_menu_reconnect",
								button = "mp_reconnect",
								colour = G.C.PURPLE,
								minw = 2,
								minh = 1,
								label = { localize("b_reconnect") },
								scale = text_scale,
							}) or nil,
						},
					},
				},
			},
		},
	}
	return t
end
