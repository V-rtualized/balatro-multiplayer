function MP.UI.BTN.galdur_next_page_btn(e)
	if Galdur.run_setup.current_page == #Galdur.run_setup.pages and MPAPI.is_in_lobby() then
		e.config.hover = MPAPI.is_host()
		e.config.shadow = MPAPI.is_host()
		e.config.colour = MPAPI.is_host() and HEX("00be67") or G.C.UI.BACKGROUND_INACTIVE
		e.children[1].children[1].config.colour = MPAPI.is_host() and G.C.WHITE or G.C.UI.TEXT_INACTIVE
		e.children[1].children[1].config.shadow = MPAPI.is_host()
		e.config.button = MPAPI.is_host() and "deck_select_next" or nil
	else
		e.config.hover = true
		e.config.shadow = true
		e.config.colour = G.C.BLUE
		e.children[1].children[1].config.colour = G.C.WHITE
		e.children[1].children[1].config.shadow = true
		e.config.button = "deck_select_next"
	end
end
G.FUNCS.mp_galdur_next_page_btn = MP.UI.BTN.galdur_next_page_btn

function MP.UI.BTN.galdur_last_run_btn(e)
	if MPAPI.is_in_lobby() then
		e.config.hover = MPAPI.is_host()
		e.config.shadow = MPAPI.is_host()
		e.config.colour = MPAPI.is_host() and G.C.ORANGE or G.C.UI.BACKGROUND_INACTIVE
		e.children[1].children[1].children[1].config.colour = MPAPI.is_host() and G.C.WHITE or G.C.UI.TEXT_INACTIVE
		e.children[1].children[1].children[1].config.shadow = MPAPI.is_host()
		e.config.button = MPAPI.is_host() and "quick_start" or nil
	else
		e.config.hover = true
		e.config.shadow = true
		e.config.colour = G.C.ORANGE
		e.children[1].children[1].children[1].config.colour = G.C.WHITE
		e.children[1].children[1].children[1].config.shadow = true
		e.config.button = "quick_start"
	end
end
G.FUNCS.mp_galdur_last_run_btn = MP.UI.BTN.galdur_last_run_btn

for i, _ in ipairs(Galdur.pages_to_add) do
	Galdur.pages_to_add[i].condition = function()
		return MPAPI.get_lobby() == nil or MPAPI.is_host()
	end
end

function MP.get_gamemode_sprite(_gamemode, _scale)
	_gamemode = _gamemode or 1
	_scale = _scale or 1
	local gamemode_sprite = Sprite(
		0,
		0,
		_scale * 1,
		_scale * 1,
		G.ANIMATION_ATLAS[G.P_CENTER_POOLS.Gamemode[_gamemode].atlas],
		G.P_CENTER_POOLS.Gamemode[_gamemode].pos
	)
	gamemode_sprite.states.drag.can = false
	if G.P_CENTER_POOLS["Gamemode"][_gamemode].shiny then
		gamemode_sprite.draw = function(_sprite)
			_sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
			_sprite.ARGS.send_to_shader[1] = math.min(_sprite.VT.r * 3, 1)
				+ G.TIMERS.REAL / 18
				+ (_sprite.juice and _sprite.juice.r * 20 or 0)
				+ 1
			_sprite.ARGS.send_to_shader[2] = G.TIMERS.REAL

			Sprite.draw_shader(_sprite, "dissolve")
			Sprite.draw_shader(_sprite, "voucher", nil, _sprite.ARGS.send_to_shader)
		end
	end
	return gamemode_sprite
end

function MP.gamemode_description(_gamemode)
	local _gamemode_center = G.P_CENTER_POOLS.Gamemode[_gamemode]
	if not _gamemode_center then
		return {}
	end

	local ret_nodes = {}

	localize({ type = "descriptions", key = _gamemode_center.key, set = "Gamemode", nodes = ret_nodes })

	local desc_t = {}
	for i, v in ipairs(ret_nodes) do
		desc_t[#desc_t + 1] = { n = G.UIT.R, config = { align = "cm", maxw = 12 }, nodes = v }
	end

	return {
		n = G.UIT.C,
		config = { align = "cm", padding = 0.05, r = 0.1, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.03, colour = G.C.CLEAR, r = 0.1, minh = 1, minw = 5.5 },
				nodes = desc_t,
			},
		},
	}
end

-- This is not very nice of you Galdur, have an API
local card_hover_ref = Card.hover
function Card:hover()
	if
		(self.params.gamemode_chip or self.params.gamemode_preview)
		and (not self.states.drag.is or G.CONTROLLER.HID.touch)
		and not self.no_ui
		and not G.debug_tooltip_toggle
	then
		self:juice_up(0.05, 0.03)
		play_sound("paper1", math.random() * 0.2 + 0.9, 0.35)
		if self.children.alert and not self.config.center.alerted then
			self.config.center.alerted = true
			G:save_progress()
		end

		local info_queue = populate_info_queue("Gamemode", G.P_CENTER_POOLS.Gamemode[self.params.gamemode].key)
		local tooltips = {}
		for _, center in pairs(info_queue) do
			local desc =
				generate_card_ui(center, { main = {}, info = {}, type = {}, name = "done" }, nil, center.set, nil)
			tooltips[#tooltips + 1] = {
				n = G.UIT.C,
				config = { align = "bm" },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							colour = lighten(G.C.JOKER_GREY, 0.5),
							r = 0.1,
							padding = 0.05,
							emboss = 0.05,
						},
						nodes = {
							info_tip_from_rows(desc.info[1], desc.info[1].name),
						},
					},
				},
			}
		end

		local badges = { n = G.UIT.ROOT, config = { colour = G.C.CLEAR, align = "cm" }, nodes = {} }
		SMODS.create_mod_badges(G.P_CENTER_POOLS.Gamemode[self.params.gamemode], badges.nodes)
		if badges.nodes.mod_set then
			badges.nodes.mod_set = nil
		end

		self.config.h_popup = {
			n = G.UIT.C,
			config = { align = "cm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{
							n = G.UIT.C,
							config = {
								align = "cm",
								minh = 1.5,
								r = 0.1,
								colour = G.C.L_BLACK,
								padding = 0.1,
								outline = 1,
							},
							nodes = {
								{
									n = G.UIT.R,
									config = { align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4 },
									nodes = {
										{
											n = G.UIT.O,
											config = {
												object = UIBox({
													definition = {
														n = G.UIT.ROOT,
														config = { align = "cm", colour = G.C.CLEAR },
														nodes = {
															{
																n = G.UIT.O,
																config = {
																	object = DynaText({
																		string = localize({
																			type = "name_text",
																			set = "Gamemode",
																			key = G.P_CENTER_POOLS.Gamemode[self.params.gamemode].key,
																		}),
																		maxw = 4,
																		colours = { G.C.WHITE },
																		shadow = true,
																		bump = true,
																		scale = 0.5,
																		pop_in = 0,
																		silent = true,
																	}),
																},
															},
														},
													},
													config = { offset = { x = 0, y = 0 }, align = "cm", parent = e },
												}),
											},
										},
									},
								},
								{
									n = G.UIT.R,
									config = {
										align = "cm",
										colour = G.C.WHITE,
										minh = 1.3,
										maxh = 8,
										minw = 3,
										maxw = 12,
										r = 0.1,
									},
									nodes = {
										MP.gamemode_description(self.params.gamemode),
									},
								},
								badges.nodes[1] and {
									n = G.UIT.R,
									config = { align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4 },
									nodes = {
										{
											n = G.UIT.O,
											config = {
												object = UIBox({
													definition = badges,
													config = { offset = { x = 0, y = 0 } },
												}),
											},
										},
									},
								},
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.1 },
					nodes = tooltips,
				},
			},
		}
		self.config.h_popup_config = self:align_h_popup()

		Node.hover(self)
	else
		card_hover_ref(self)
	end
end

local card_click_ref = Card.click
function Card:click()
	if self.params.gamemode_chip then
		MP.lobby_state.config.gamemode = self.params.gamemode
		G.E_MANAGER:clear_queue("galdur")
		MP.UI.populate_gamemode_preview(self.params.gamemode)
	else
		card_click_ref(self)
	end
end

function MP.UI.include_gamemode_preview()
	MP.UI.generate_gamemode_card_areas()
	MP.UI.generate_gamemode_preview()
	MP.UI.populate_gamemode_preview(MP.lobby_state.config.gamemode)
end

function MP.UI.generate_gamemode_preview()
	if Galdur.run_setup.selected_gamemode_area_holding then
		for j = 1, #G.I.CARDAREA do
			if Galdur.run_setup.selected_gamemode_area_holding == G.I.CARDAREA[j] then
				table.remove(G.I.CARDAREA, j)
				Galdur.run_setup.selected_gamemode_area_holding = nil
			end
		end
	end

	Galdur.run_setup.selected_gamemode_area_holding = CardArea(
		17.475,
		2,
		G.CARD_W,
		G.CARD_H,
		{ card_limit = 1, type = "deck", highlight_limit = 0, gamemode_select = true }
	)
end

function MP.UI.populate_gamemode_preview(_gamemode)
	if Galdur.run_setup.selected_gamemode_area_holding.cards then
		remove_all(Galdur.run_setup.selected_gamemode_area_holding.cards)
		Galdur.run_setup.selected_gamemode_area_holding.cards = {}
	end
	if not _gamemode then
		_gamemode = 1
	end
	local card = Card(
		Galdur.run_setup.gamemode_select_areas[1].T.x,
		Galdur.run_setup.gamemode_select_areas[1].T.y,
		3.4 * 14 / 30,
		3.4 * 14 / 30,
		Galdur.run_setup.choices.deck.effect.center,
		Galdur.run_setup.choices.deck.effect.center,
		{ gamemode = _gamemode, gamemode_preview = true }
	)
	Galdur.run_setup.selected_gamemode_area_holding:emplace(card)
	card.sprite_facing = "back"
	card.facing = "back"
	card.children.back:remove()
	card.children.back = Sprite(
		0,
		0,
		1,
		1,
		G.ANIMATION_ATLAS[G.P_CENTER_POOLS.Gamemode[_gamemode].atlas],
		G.P_CENTER_POOLS.Gamemode[_gamemode].pos
	)
	card.children.back.states.hover = card.states.hover
	card.children.back.states.click = card.states.click
	card.children.back.states.drag = card.states.drag
	card.children.back.states.collide.can = false
	card.children.back:set_role({ major = card, role_type = "Glued", draw_major = card })
end

function MP.UI.display_gamemode_preview()
	local gamemode_node = {
		n = G.UIT.R,
		config = { align = "tm" },
		nodes = {
			{ n = G.UIT.O, config = { object = Galdur.run_setup.selected_gamemode_area_holding } },
		},
	}

	return {
		n = G.UIT.C,
		config = { align = "tm", padding = 0.15 },
		nodes = {
			{
				n = G.UIT.R,
				config = {
					minh = 5.95,
					minw = 3,
					maxw = 3,
					colour = G.C.BLACK,
					r = 0.1,
					align = "bm",
					padding = 0.15,
					emboss = 0.05,
				},
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", minh = 0.6, maxw = 2.8 },
						nodes = {
							{
								n = G.UIT.O,
								config = {
									id = "gamemode_name_1",
									object = DynaText({
										string = {
											{ ref_table = MP.gamemode_preview_texts, ref_value = "gamemode_preview_1" },
										},
										scale = 0.7
											/ math.max(1, string.len(MP.gamemode_preview_texts.gamemode_preview_1) / 8),
										colours = { G.C.GREY },
										pop_in_rate = 5,
										silent = true,
									}),
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm", minh = 0.6, maxw = 2.8 },
						nodes = {
							{
								n = G.UIT.O,
								config = {
									id = "gamemode_name_2",
									object = DynaText({
										string = {
											{ ref_table = MP.gamemode_preview_texts, ref_value = "gamemode_preview_2" },
										},
										scale = 0.7
											/ math.max(1, string.len(MP.gamemode_preview_texts.gamemode_preview_2) / 8),
										colours = { G.C.GREY },
										pop_in_rate = 5,
										silent = true,
									}),
								},
							},
						},
					},
					{ n = G.UIT.R, config = { align = "cm", minh = 0.2 } },
					gamemode_node,
					{
						n = G.UIT.R,
						config = { minh = 0.8, align = "bm" },
						nodes = {
							{
								n = G.UIT.T,
								config = { text = localize("gald_selected"), scale = 0.75, colour = G.C.GREY },
							},
						},
					},
				},
			},
		},
	}
end
