local create_UIBox_game_over_ref = create_UIBox_game_over
function create_UIBox_game_over()
	if MPAPI.is_in_lobby() then
		local eased_red = copy_table(G.GAME.round_resets.ante <= G.GAME.win_ante and G.C.RED or G.C.BLUE)
		eased_red[4] = 0
		ease_value(eased_red, 4, 0.8, nil, nil, true)
		local t = create_UIBox_generic_options({
			bg_colour = eased_red,
			no_back = true,
			padding = 0,
			contents = {
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = { localize("ph_game_over") },
									colours = { G.C.RED },
									shadow = true,
									float = true,
									scale = 1.5,
									pop_in = 0.4,
									maxw = 6.5,
								}),
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.15 },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm" },
							nodes = {
								{
									n = G.UIT.R,
									config = {
										align = "cm",
										padding = 0.05,
										colour = G.C.BLACK,
										emboss = 0.05,
										r = 0.1,
									},
									nodes = {
										{
											n = G.UIT.R,
											config = { align = "cm", padding = 0.08 },
											nodes = {
												create_UIBox_round_scores_row("hand"),
												create_UIBox_round_scores_row("poker_hand"),
											},
										},
										{
											n = G.UIT.R,
											config = { align = "cm" },
											nodes = {
												{
													n = G.UIT.C,
													config = { align = "cm", padding = 0.08 },
													nodes = {
														create_UIBox_round_scores_row("cards_played", G.C.BLUE),
														create_UIBox_round_scores_row("cards_discarded", G.C.RED),
														create_UIBox_round_scores_row("cards_purchased", G.C.MONEY),
														create_UIBox_round_scores_row("times_rerolled", G.C.GREEN),
														create_UIBox_round_scores_row("new_collection", G.C.WHITE),
														create_UIBox_round_scores_row("seed", G.C.WHITE),
														UIBox_button({
															button = "copy_seed",
															label = { localize("b_copy") },
															colour = G.C.BLUE,
															scale = 0.3,
															minw = 2.3,
															minh = 0.4,
															focus_args = { nav = "wide" },
														}),
													},
												},
												{
													n = G.UIT.C,
													config = { align = "tr", padding = 0.08 },
													nodes = {
														create_UIBox_round_scores_row("furthest_ante", G.C.FILTER),
														create_UIBox_round_scores_row("furthest_round", G.C.FILTER),
														create_UIBox_round_scores_row("defeated_by"),
													},
												},
											},
										},
									},
								},
								{
									n = G.UIT.R,
									config = { align = "cm", padding = 0.1 },
									nodes = {
										{
											n = G.UIT.R,
											config = {
												id = "from_game_over",
												align = "cm",
												minw = 5,
												padding = 0.1,
												r = 0.1,
												hover = true,
												colour = G.C.RED,
												button = "mp_return_to_lobby",
												shadow = true,
												focus_args = { nav = "wide", snap_to = true },
											},
											nodes = {
												{
													n = G.UIT.R,
													config = { align = "cm", padding = 0, no_fill = true, maxw = 4.8 },
													nodes = {
														{
															n = G.UIT.T,
															config = {
																text = localize("return_lobby"),
																scale = 0.5,
																colour = G.C.UI.TEXT_LIGHT,
															},
														},
													},
												},
											},
										},
										{
											n = G.UIT.R,
											config = {
												align = "cm",
												minw = 5,
												padding = 0.1,
												r = 0.1,
												hover = true,
												colour = G.C.RED,
												button = "mp_leave_lobby",
												shadow = true,
												focus_args = { nav = "wide" },
											},
											nodes = {
												{
													n = G.UIT.R,
													config = { align = "cm", padding = 0, no_fill = true, maxw = 4.8 },
													nodes = {
														{
															n = G.UIT.T,
															config = {
																text = localize("b_leave_lobby"),
																scale = 0.5,
																colour = G.C.UI.TEXT_LIGHT,
															},
														},
													},
												},
											},
										},
									},
								},
							},
						},
					},
				},
			},
		})
		t.nodes[1] = {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cm", padding = 2 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{
									n = G.UIT.O,
									config = {
										padding = 0,
										id = "jimbo_spot",
										object = Moveable(0, 0, G.CARD_W * 1.1, G.CARD_H * 1.1),
									},
								},
							},
						},
					},
				},
				{ n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = { t.nodes[1] } },
			},
		}

		return t
	end
	return create_UIBox_game_over_ref()
end

local create_UIBox_win_ref = create_UIBox_win
function create_UIBox_win()
	if MPAPI.is_in_lobby() then
		local eased_green = copy_table(G.C.GREEN)
		eased_green[4] = 0
		ease_value(eased_green, 4, 0.5, nil, nil, true)
		local t = create_UIBox_generic_options({
			padding = 0,
			bg_colour = eased_green,
			colour = G.C.BLACK,
			outline_colour = G.C.EDITION,
			no_back = true,
			no_esc = true,
			contents = {
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = { localize("ph_you_win") },
									colours = { G.C.EDITION },
									shadow = true,
									float = true,
									spacing = 10,
									rotate = true,
									scale = 1.5,
									pop_in = 0.4,
									maxw = 6.5,
								}),
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.15 },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm" },
							nodes = {
								{
									n = G.UIT.R,
									config = { align = "cm", padding = 0.08 },
									nodes = {
										create_UIBox_round_scores_row("hand"),
										create_UIBox_round_scores_row("poker_hand"),
									},
								},
								{
									n = G.UIT.R,
									config = { align = "cm" },
									nodes = {
										{
											n = G.UIT.C,
											config = { align = "cm", padding = 0.08 },
											nodes = {
												create_UIBox_round_scores_row("cards_played", G.C.BLUE),
												create_UIBox_round_scores_row("cards_discarded", G.C.RED),
												create_UIBox_round_scores_row("cards_purchased", G.C.MONEY),
												create_UIBox_round_scores_row("times_rerolled", G.C.GREEN),
												create_UIBox_round_scores_row("new_collection", G.C.WHITE),
												create_UIBox_round_scores_row("seed", G.C.WHITE),
												UIBox_button({
													button = "copy_seed",
													label = { localize("b_copy") },
													colour = G.C.BLUE,
													scale = 0.3,
													minw = 2.3,
													minh = 0.4,
												}),
											},
										},
										{
											n = G.UIT.C,
											config = { align = "tr", padding = 0.08 },
											nodes = {
												create_UIBox_round_scores_row("furthest_ante", G.C.FILTER),
												create_UIBox_round_scores_row("furthest_round", G.C.FILTER),
												{
													n = G.UIT.R,
													config = { align = "cm", minh = 0.4, minw = 0.1 },
													nodes = {},
												},
												UIBox_button({
													id = "from_game_won",
													button = "mp_return_to_lobby",
													label = localize("return_to_lobby_split"),
													minw = 2.5,
													maxw = 2.5,
													minh = 1,
													focus_args = { nav = "wide", snap_to = true },
												}) or nil,
												{
													n = G.UIT.R,
													config = { align = "cm", minh = 0.2, minw = 0.1 },
													nodes = {},
												} or nil,
												UIBox_button({
													button = "mp_leave_lobby",
													label = localize("leave_lobby_split"),
													minw = 2.5,
													maxw = 2.5,
													minh = 1,
													focus_args = { nav = "wide" },
												}) or nil,
											},
										},
									},
								},
							},
						},
					},
				},
			},
		})
		t.nodes[1] = {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cm", padding = 2 },
					nodes = {
						{
							n = G.UIT.O,
							config = {
								padding = 0,
								id = "jimbo_spot",
								object = Moveable(0, 0, G.CARD_W * 1.1, G.CARD_H * 1.1),
							},
						},
					},
				},
				{ n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = { t.nodes[1] } },
			},
		}
		t.config.id = "you_win_UI"
		return t
	end
	return create_UIBox_win_ref()
end
