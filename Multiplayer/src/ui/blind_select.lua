-- TODO: Refactor to lovely injection
local create_UIBox_blind_choice_ref = create_UIBox_blind_choice
function create_UIBox_blind_choice(type, run_info)
	if MPAPI.is_in_lobby() then
		if not G.GAME.blind_on_deck then
			G.GAME.blind_on_deck = "Small"
		end
		if not run_info then
			G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = "Select"
		end

		local disabled = false
		type = type or "Small"

		local blind_choice = {
			config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type]],
		}

		local blind_atlas = "blind_chips"
		if blind_choice.config and blind_choice.config.atlas then
			blind_atlas = blind_choice.config.atlas
		end
		blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS[blind_atlas], blind_choice.config.pos)
		blind_choice.animation:define_draw_steps({
			{ shader = "dissolve", shadow_height = 0.05 },
			{ shader = "dissolve" },
		})
		blind_choice.animation:define_draw_steps({
			{ shader = "dissolve", shadow_height = 0.05 },
			{ shader = "dissolve" },
		})
		local extras = nil
		local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)

		G.GAME.orbital_choices = G.GAME.orbital_choices or {}
		G.GAME.orbital_choices[G.GAME.round_resets.ante] = G.GAME.orbital_choices[G.GAME.round_resets.ante] or {}

		if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then
			local _poker_hands = {}
			for k, v in pairs(G.GAME.hands) do
				if v.visible then
					_poker_hands[#_poker_hands + 1] = k
				end
			end

			G.GAME.orbital_choices[G.GAME.round_resets.ante][type] =
				pseudorandom_element(_poker_hands, pseudoseed("orbital"))
		end

		if MP.value_is_pvp_boss(G.GAME.round_resets.blind_choices[type]) then
			local dt1 = DynaText({
				string = { { string = localize("bl_life"), colour = G.C.FILTER } },
				colours = { G.C.BLACK },
				scale = 0.55,
				silent = true,
				pop_delay = 4.5,
				shadow = true,
				bump = true,
				maxw = 3,
			})
			local dt2 = DynaText({
				string = { { string = localize("bl_or"), colour = G.C.WHITE } },
				colours = { G.C.CHANCE },
				scale = 0.35,
				silent = true,
				pop_delay = 4.5,
				shadow = true,
				maxw = 3,
			})
			local dt3 = DynaText({
				string = { { string = localize("bl_death"), colour = G.C.FILTER } },
				colours = { G.C.BLACK },
				scale = 0.55,
				silent = true,
				pop_delay = 4.5,
				shadow = true,
				bump = true,
				maxw = 3,
			})
			extras = {
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.07, r = 0.1, colour = { 0, 0, 0, 0.12 }, minw = 2.9 },
						nodes = {
							{
								n = G.UIT.R,
								config = { align = "cm" },
								nodes = {
									{ n = G.UIT.O, config = { object = dt1 } },
								},
							},
							{
								n = G.UIT.R,
								config = { align = "cm" },
								nodes = {
									{ n = G.UIT.O, config = { object = dt2 } },
								},
							},
							{
								n = G.UIT.R,
								config = { align = "cm" },
								nodes = {
									{ n = G.UIT.O, config = { object = dt3 } },
								},
							},
						},
					},
				},
			}
		elseif type == "Small" then
			extras = create_UIBox_blind_tag(type, run_info)
		elseif type == "Big" then
			extras = create_UIBox_blind_tag(type, run_info)
		else
			extras = nil
		end
		G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante

		local loc_target = localize({
			type = "raw_descriptions",
			key = blind_choice.config.key,
			set = "Blind",
			vars = { localize(G.GAME.current_round.most_played_poker_hand, "poker_hands") },
		})
		local loc_name = localize({ type = "name_text", key = blind_choice.config.key, set = "Blind" })
		local blind_col = get_blind_main_colour(type)
		local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante)
			* blind_choice.config.mult
			* G.GAME.starting_params.ante_scaling

		if MP.value_is_pvp_boss(G.GAME.round_resets.blind_choices[type]) then
			blind_amt = "????"
		end

		local text_table = loc_target

		local blind_state = G.GAME.round_resets.blind_states[type]
		local _reward = true
		if G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[type] then
			---@diagnostic disable-next-line: cast-local-type
			_reward = nil
		end
		if blind_state == "Select" then
			blind_state = "Current"
		end
		local run_info_colour = run_info
			and (
				blind_state == "Defeated" and G.C.GREY
				or blind_state == "Skipped" and G.C.BLUE
				or blind_state == "Upcoming" and G.C.ORANGE
				or blind_state == "Current" and G.C.RED
				or G.C.GOLD
			)

		local t = {
			n = G.UIT.R,
			config = {
				id = type,
				align = "tm",
				func = "blind_choice_handler",
				minh = not run_info and 10 or nil,
				ref_table = { deck = nil, run_info = run_info },
				r = 0.1,
				padding = 0.05,
			},
			nodes = {
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5),
						r = 0.1,
						outline = 1,
						outline_colour = G.C.L_BLACK,
					},
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0.2 },
							nodes = {
								not run_info and {
									n = G.UIT.R,
									config = {
										id = "select_blind_button",
										align = "cm",
										ref_table = blind_choice.config,
										colour = disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE,
										minh = 0.6,
										minw = 2.7,
										padding = 0.07,
										r = 0.1,
										shadow = true,
										hover = true,
										one_press = true,
										func = MP.value_is_pvp_boss(G.GAME.round_resets.blind_choices[type])
												and "pvp_ready_button"
											or nil,
										button = "select_blind",
									},
									nodes = {
										{
											n = G.UIT.T,
											config = {
												ref_table = G.GAME.round_resets.loc_blind_states,
												ref_value = type,
												scale = 0.45,
												colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.UI.TEXT_LIGHT,
												shadow = not disabled,
											},
										},
									},
								} or {
									n = G.UIT.R,
									config = {
										id = "select_blind_button",
										align = "cm",
										ref_table = blind_choice.config,
										colour = run_info_colour,
										minh = 0.6,
										minw = 2.7,
										padding = 0.07,
										r = 0.1,
										emboss = 0.08,
									},
									nodes = {
										{
											n = G.UIT.T,
											config = {
												text = localize(blind_state, "blind_states"),
												scale = 0.45,
												colour = G.C.UI.TEXT_LIGHT,
												shadow = true,
											},
										},
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = { id = "blind_name", align = "cm", padding = 0.07 },
							nodes = {
								{
									n = G.UIT.R,
									config = {
										align = "cm",
										r = 0.1,
										outline = 1,
										outline_colour = blind_col,
										colour = darken(blind_col, 0.3),
										minw = 2.9,
										emboss = 0.1,
										padding = 0.07,
										line_emboss = 1,
									},
									nodes = {
										{
											n = G.UIT.O,
											config = {
												object = DynaText({
													string = loc_name,
													colours = { disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE },
													shadow = not disabled,
													float = not disabled,
													y_offset = -4,
													scale = 0.45,
													maxw = 2.8,
												}),
											},
										},
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0.05 },
							nodes = {
								{
									n = G.UIT.R,
									config = { id = "blind_desc", align = "cm", padding = 0.05 },
									nodes = {
										{
											n = G.UIT.R,
											config = { align = "cm" },
											nodes = {
												{
													n = G.UIT.R,
													config = { align = "cm", minh = 1.5 },
													nodes = {
														{ n = G.UIT.O, config = { object = blind_choice.animation } },
													},
												},
												text_table and text_table[1] and {
													n = G.UIT.R,
													config = {
														align = "cm",
														minh = 0.7,
														padding = 0.05,
														minw = 2.9,
													},
													nodes = {
														text_table[1]
																and {
																	n = G.UIT.R,
																	config = { align = "cm", maxw = 2.8 },
																	nodes = {
																		{
																			n = G.UIT.T,
																			config = {
																				id = blind_choice.config.key,
																				ref_table = { val = "" },
																				ref_value = "val",
																				scale = 0.32,
																				colour = disabled
																						and G.C.UI.TEXT_INACTIVE
																					or G.C.WHITE,
																				shadow = not disabled,
																				func = "HUD_blind_debuff_prefix",
																			},
																		},
																		{
																			n = G.UIT.T,
																			config = {
																				text = text_table[1] or "-",
																				scale = 0.32,
																				colour = disabled
																						and G.C.UI.TEXT_INACTIVE
																					or G.C.WHITE,
																				shadow = not disabled,
																			},
																		},
																	},
																}
															or nil,
														text_table[2] and {
															n = G.UIT.R,
															config = { align = "cm", maxw = 2.8 },
															nodes = {
																{
																	n = G.UIT.T,
																	config = {
																		text = text_table[2] or "-",
																		scale = 0.32,
																		colour = disabled and G.C.UI.TEXT_INACTIVE
																			or G.C.WHITE,
																		shadow = not disabled,
																	},
																},
															},
														} or nil,
													},
												} or nil,
											},
										},
										{
											n = G.UIT.R,
											config = {
												align = "cm",
												r = 0.1,
												padding = 0.05,
												minw = 3.1,
												colour = G.C.BLACK,
												emboss = 0.05,
											},
											nodes = {
												{
													n = G.UIT.R,
													config = { align = "cm", maxw = 3 },
													nodes = {
														{
															n = G.UIT.T,
															config = {
																text = localize("ph_blind_score_at_least"),
																scale = 0.3,
																colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE,
																shadow = not disabled,
															},
														},
													},
												},
												{
													n = G.UIT.R,
													config = { align = "cm", minh = 0.6 },
													nodes = {
														{
															n = G.UIT.O,
															config = {
																w = 0.5,
																h = 0.5,
																colour = G.C.BLUE,
																object = stake_sprite,
																hover = true,
																can_collide = false,
															},
														},
														{ n = G.UIT.B, config = { h = 0.1, w = 0.1 } },
														{
															n = G.UIT.T,
															config = {
																text = number_format(blind_amt),
																scale = score_number_scale(0.9, blind_amt),
																colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.RED,
																shadow = not disabled,
															},
														},
													},
												},
												_reward and {
													n = G.UIT.R,
													config = { align = "cm" },
													nodes = {
														{
															n = G.UIT.T,
															config = {
																text = localize("ph_blind_reward"),
																scale = 0.35,
																colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE,
																shadow = not disabled,
															},
														},
														{
															n = G.UIT.T,
															config = {
																text = string.rep(
																	localize("$"),
																	blind_choice.config.dollars
																) .. "+",
																scale = 0.35,
																colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.MONEY,
																shadow = not disabled,
															},
														},
													},
												} or nil,
											},
										},
									},
								},
							},
						},
					},
				},
				{ n = G.UIT.R, config = { id = "blind_extras", align = "cm" }, nodes = {
					extras,
				} },
			},
		}
		return t
	else
		return create_UIBox_blind_choice_ref(type, run_info)
	end
end

-- TODO: Refactor to lovely injection
G.FUNCS.blind_choice_handler = function(e)
	if
		not e.config.ref_table.run_info
		and G.blind_select
		and G.blind_select.VT.y < 10
		and e.config.id
		and G.blind_select_opts[string.lower(e.config.id)]
	then
		if e.UIBox.role.xy_bond ~= "Weak" then
			e.UIBox:set_role({ xy_bond = "Weak" })
		end
		if
			(e.config.ref_table.deck ~= "on" and e.config.id == G.GAME.blind_on_deck)
			or (e.config.ref_table.deck ~= "off" and e.config.id ~= G.GAME.blind_on_deck)
		then
			local _blind_choice = G.blind_select_opts[string.lower(e.config.id)]
			local _top_button = e.UIBox:get_UIE_by_ID("select_blind_button")
			local _border = e.UIBox.UIRoot.children[1].children[1]
			local _tag = e.UIBox:get_UIE_by_ID("tag_" .. e.config.id)
			local _tag_container = e.UIBox:get_UIE_by_ID("tag_container")
			if
				_tag_container
				and not G.SETTINGS.tutorial_complete
				and not G.SETTINGS.tutorial_progress.completed_parts["shop_1"]
			then
				_tag_container.states.visible = false
			elseif _tag_container then
				_tag_container.states.visible = true
			end
			if e.config.id == G.GAME.blind_on_deck then
				e.config.ref_table.deck = "on"
				e.config.draw_after = false
				e.config.colour = G.C.CLEAR
				_border.parent.config.outline = 2
				_border.parent.config.outline_colour = G.C.UI.TRANSPARENT_DARK
				_border.config.outline_colour = _border.config.outline and _border.config.outline_colour
					or get_blind_main_colour(e.config.id)
				_border.config.outline = 1.5
				_blind_choice.alignment.offset.y = -0.9
				if _tag and _tag_container then
					_tag_container.children[2].config.draw_after = false
					_tag_container.children[2].config.colour = G.C.BLACK
					_tag.children[2].config.button = "skip_blind"
					_tag.config.outline_colour = adjust_alpha(G.C.BLUE, 0.5)
					_tag.children[2].config.hover = true
					_tag.children[2].config.colour = G.C.RED
					_tag.children[2].children[1].config.colour = G.C.UI.TEXT_LIGHT
					local _sprite = _tag.config.ref_table
					_sprite.config.force_focus = nil
				end
				if _top_button then
					G.E_MANAGER:add_event(Event({
						func = function()
							G.CONTROLLER:snap_to({ node = _top_button })
							return true
						end,
					}))
					if _top_button.config.button ~= "mp_toggle_ready" then
						_top_button.config.button = "select_blind"
					end
					_top_button.config.colour = G.C.FILTER
					_top_button.config.hover = true
					_top_button.children[1].config.colour = G.C.WHITE
				end
			elseif e.config.id ~= G.GAME.blind_on_deck then
				e.config.ref_table.deck = "off"
				e.config.draw_after = true
				e.config.colour = adjust_alpha(
					G.GAME.round_resets.blind_states[e.config.id] == "Skipped"
							and mix_colours(G.C.BLUE, G.C.L_BLACK, 0.1)
						or G.C.L_BLACK,
					0.5
				)
				_border.parent.config.outline = nil
				_border.parent.config.outline_colour = nil
				_border.config.outline_colour = nil
				_border.config.outline = nil
				_blind_choice.alignment.offset.y = -0.2
				if _tag and _tag_container then
					if
						G.GAME.round_resets.blind_states[e.config.id] == "Skipped"
						or G.GAME.round_resets.blind_states[e.config.id] == "Defeated"
					then
						_tag_container.children[2]:set_role({ xy_bond = "Weak" })
						_tag_container.children[2]:align(0, 10)
						_tag_container.children[1]:set_role({ xy_bond = "Weak" })
						_tag_container.children[1]:align(0, 10)
					end
					if G.GAME.round_resets.blind_states[e.config.id] == "Skipped" then
						_blind_choice.children.alert = UIBox({
							definition = create_UIBox_card_alert({
								text_rot = -0.35,
								no_bg = true,
								text = localize("k_skipped_cap"),
								bump_amount = 1,
								scale = 0.9,
								maxw = 3.4,
							}),
							config = {
								align = "tmi",
								offset = { x = 0, y = 2.2 },
								major = _blind_choice,
								parent = _blind_choice,
							},
						})
					end
					_tag.children[2].config.button = nil
					_tag.config.outline_colour = G.C.UI.BACKGROUND_INACTIVE
					_tag.children[2].config.hover = false
					_tag.children[2].config.colour = G.C.UI.BACKGROUND_INACTIVE
					_tag.children[2].children[1].config.colour = G.C.UI.TEXT_INACTIVE
					local _sprite = _tag.config.ref_table
					_sprite.config.force_focus = true
				end
				if _top_button then
					_top_button.config.colour = G.C.UI.BACKGROUND_INACTIVE
					_top_button.config.button = nil
					_top_button.config.hover = false
					_top_button.children[1].config.colour = G.C.UI.TEXT_INACTIVE
				end
			end
		end
	end
end

G.FUNCS.pvp_ready_button = function(e)
	if e.children[1].config.ref_table[e.children[1].config.ref_value] == localize("Select", "blind_states") then
		e.config.button = "mp_toggle_ready"
		e.config.one_press = false
		e.children[1].config.ref_table = MP.game_state
		e.children[1].config.ref_value = "ready_blind_text"
	end
	if e.config.button == "mp_toggle_ready" then
		e.config.colour = (MP.game_state.ready_blind and G.C.GREEN) or G.C.RED
	end
end

function G.FUNCS.mp_toggle_ready(e)
	MP.game_state.ready_blind = not MP.game_state.ready_blind
	MP.game_state.ready_blind_text = MP.game_state.ready_blind and localize("ready") or localize("unready")

	if MP.game_state.ready_blind then
		--G.MULTIPLAYER.set_location("loc_ready")
		MP.send.ready_blind(e)
	else
		--G.MULTIPLAYER.set_location("loc_selecting")
		MP.send.unready_blind()
	end
end

local blind_disable_ref = Blind.disable
function Blind:disable()
	if MP.is_pvp_boss() then
		return
	end
	blind_disable_ref(self)
end
