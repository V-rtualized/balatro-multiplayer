local start_run_ref = Game.start_run
function Game:start_run(args)
	start_run_ref(self, args)

	if not MP.is_in_lobby() then
		return
	end

	local scale = 0.4
	local hud_ante = G.HUD:get_UIE_by_ID("hud_ante")
	hud_ante.children[1].children[1].config.text = localize("lives")

	-- Set lives number
	hud_ante.children[2].children[1].config.object = DynaText({
		string = { { ref_table = MP.game_state, ref_value = "lives" } },
		colours = { G.C.IMPORTANT },
		shadow = true,
		font = G.LANGUAGES["en-us"].font,
		scale = 2 * scale,
	})

	-- Remove unnecessary HUD elements
	hud_ante.children[2].children[2] = nil
	hud_ante.children[2].children[3] = nil
	hud_ante.children[2].children[4] = nil

	self.HUD:recalculate()
end

function MP.UI.update_blind_HUD(aniamte)
	if MP.is_in_lobby() and MP.is_pvp_boss() then
		if aniamte then
			G.HUD_blind.alignment.offset.y = -10
		end
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.3,
			blockable = false,
			func = function()
				local nemesis = MP.get_nemesis()
				G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_table = nemesis
				G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_value = "score_text"
				G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.func = "multiplayer_blind_chip_UI_scale"
				G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[1].children[1].config.text =
					localize("enemy_score")
				G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[3].children[1].config.text =
					localize("enemy_hands")
				G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object.config.string =
					{ { ref_table = nemesis, ref_value = "hands_left" } }
				G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:update_text()
				if aniamte then
					G.HUD_blind.alignment.offset.y = 0
				end
				return true
			end,
		}))
	end
end

local function reset_blind_HUD()
	if MP.is_in_lobby() then
		G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object.config.string =
			{ { ref_table = G.GAME.blind, ref_value = "loc_name" } }
		G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:update_text()
		G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_table = G.GAME.blind
		G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_value = "chip_text"
		G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[1].children[1].config.text =
			localize("ph_blind_score_at_least")
		G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[3].children[1].config.text =
			localize("ph_blind_reward")
		G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object.config.string =
			{ { ref_table = G.GAME.current_round, ref_value = "dollars_to_be_earned" } }
		G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:update_text()
	end
end

local update_draw_to_hand_ref = Game.update_draw_to_hand
function Game:update_draw_to_hand(dt)
	if MP.is_in_lobby() then
		if
			not G.STATE_COMPLETE
			and G.GAME.current_round.hands_played == 0
			and G.GAME.current_round.discards_used == 0
			and G.GAME.facing_blind
		then
			if MP.is_pvp_boss() then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 1,
					blockable = false,
					func = function()
						G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:pop_out(0)
						MP.UI.update_blind_HUD(true)
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.45,
							blockable = false,
							func = function()
								if MP.lobby_state.config.gamemode == "nemesis" then
									G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object.config.string = {
										{
											ref_table = MP.get_nemesis(),
											ref_value = "username",
										},
									}
									G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:update_text()
									G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:pop_in(0)
								end
								return true
							end,
						}))
						return true
					end,
				}))
			end
		end
	end
	update_draw_to_hand_ref(self, dt)
end

local blind_defeat_ref = Blind.defeat
function Blind:defeat(silent)
	blind_defeat_ref(self, silent)
	reset_blind_HUD()
end

local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
	if not G.STATE_COMPLETE then
		MP.game_state.ready_blind = false
		MP.game_state.ready_blind_text = localize("ready")
	end
	update_shop_ref(self, dt)
end

local function eval_hand_and_jokers()
	for i = 1, #G.hand.cards do
		--Check for hand doubling
		local reps = { 1 }
		local j = 1
		while j <= #reps do
			local percent = (i - 0.999) / (#G.hand.cards - 0.998) + (j - 1) * 0.1
			if reps[j] ~= 1 then
				card_eval_status_text(
					(reps[j].jokers or reps[j].seals).card,
					"jokers",
					nil,
					nil,
					nil,
					(reps[j].jokers or reps[j].seals)
				)
			end

			--calculate the hand effects
			local effects = { G.hand.cards[i]:get_end_of_round_effect() }
			for k = 1, #G.jokers.cards do
				--calculate the joker individual card effects
				local eval = G.jokers.cards[k]:calculate_joker({
					cardarea = G.hand,
					other_card = G.hand.cards[i],
					individual = true,
					end_of_round = true,
				})
				if eval then
					table.insert(effects, eval)
				end
			end

			if reps[j] == 1 then
				--Check for hand doubling
				--From Red seal
				local eval = eval_card(
					G.hand.cards[i],
					{ end_of_round = true, cardarea = G.hand, repetition = true, repetition_only = true }
				)
				if next(eval) and (next(effects[1]) or #effects > 1) then
					for h = 1, eval.seals.repetitions do
						reps[#reps + 1] = eval
					end
				end

				--from Jokers
				for j = 1, #G.jokers.cards do
					--calculate the joker effects
					local eval = eval_card(G.jokers.cards[j], {
						cardarea = G.hand,
						other_card = G.hand.cards[i],
						repetition = true,
						end_of_round = true,
						card_effects = effects,
					})
					if next(eval) then
						for h = 1, eval.jokers.repetitions do
							reps[#reps + 1] = eval
						end
					end
				end
			end

			for ii = 1, #effects do
				--if this effect came from a joker
				if effects[ii].card then
					G.E_MANAGER:add_event(Event({
						trigger = "immediate",
						func = function()
							effects[ii].card:juice_up(0.7)
							return true
						end,
					}))
				end

				--If dollars
				if effects[ii].h_dollars then
					ease_dollars(effects[ii].h_dollars)
					card_eval_status_text(G.hand.cards[i], "dollars", effects[ii].h_dollars, percent)
				end

				--Any extras
				if effects[ii].extra then
					card_eval_status_text(G.hand.cards[i], "extra", nil, percent, nil, effects[ii].extra)
				end
			end
			j = j + 1
		end
	end
end

local update_hand_played_ref = Game.update_hand_played
---@diagnostic disable-next-line: duplicate-set-field
function Game:update_hand_played(dt)
	-- Ignore for singleplayer or regular blinds
	if not MP.is_in_lobby() or not MP.is_pvp_boss() then
		update_hand_played_ref(self, dt)
		return
	end

	if self.buttons then
		self.buttons:remove()
		self.buttons = nil
	end
	if self.shop then
		self.shop:remove()
		self.shop = nil
	end

	if not G.STATE_COMPLETE then
		G.STATE_COMPLETE = true
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				MP.send.play_hand(G.GAME.chips, G.GAME.current_round.hands_left)
				-- Set blind chips to enemy score
				G.GAME.blind.chips = MP.get_nemesis().score
				-- For now, never advance to next round
				if G.GAME.current_round.hands_left < 1 then
					attention_text({
						scale = 0.8,
						text = localize("wait_enemy"),
						hold = 5,
						align = "cm",
						offset = { x = 0, y = -1.5 },
						major = G.play,
					})
					if G.hand.cards[1] then
						eval_hand_and_jokers()
						G.FUNCS.draw_from_hand_to_discard()
					end
					G.STATE_COMPLETE = false
					G.STATE = G.STATES.WAITING_ON_PVP_END
				else
					G.STATE_COMPLETE = false
					G.STATE = G.STATES.DRAW_TO_HAND
				end
				return true
			end,
		}))
	end
end

local can_play_ref = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
	if G.GAME.current_round.hands_left <= 0 then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		can_play_ref(e)
	end
end

local update_new_round_ref = Game.update_new_round
function Game:update_new_round(dt)
	if MP.is_in_lobby() and not G.STATE_COMPLETE then
		-- Prevent player from losing
		if to_big(G.GAME.chips) < to_big(G.GAME.blind.chips) and not MP.is_pvp_boss() then
			G.GAME.blind.chips = -1
			MP.send.fail_round()
		end

		-- Prevent player from winning
		G.GAME.win_ante = 999

		update_new_round_ref(self, dt)

		-- Reset ante number
		G.GAME.win_ante = 8
		return
	end
	update_new_round_ref(self, dt)
end

function MP.end_round()
	G.RESET_BLIND_STATES = true
	G.RESET_JIGGLES = true
	for i = 1, #G.jokers.cards do
		local eval = nil
		eval = G.jokers.cards[i]:calculate_joker({ end_of_round = true, game_over = false })
		if eval then
			card_eval_status_text(G.jokers.cards[i], "jokers", nil, nil, nil, eval)
		end
		G.jokers.cards[i]:calculate_rental()
		G.jokers.cards[i]:calculate_perishable()
	end
	G.GAME.unused_discards = (G.GAME.unused_discards or 0) + G.GAME.current_round.discards_left
	if G.GAME.blind and G.GAME.blind.config.blind then
		discover_card(G.GAME.blind.config.blind)
	end

	if G.GAME.blind:get_type() == "Boss" then
		local _handname, _played, _order = "High Card", -1, 100
		for k, v in pairs(G.GAME.hands) do
			if v.played > _played or (v.played == _played and _order > v.order) then
				_played = v.played
				_handname = k
			end
		end
		G.GAME.current_round.most_played_poker_hand = _handname
	end

	if G.GAME.blind:get_type() == "Boss" and not G.GAME.seeded and not G.GAME.challenge then
		G.GAME.current_boss_streak = G.GAME.current_boss_streak + 1
		check_and_set_high_score("boss_streak", G.GAME.current_boss_streak)
	end

	if G.GAME.current_round.hands_played == 1 then
		inc_career_stat("c_single_hand_round_streak", 1)
	else
		if not G.GAME.seeded and not G.GAME.challenge then
			G.PROFILES[G.SETTINGS.profile].career_stats.c_single_hand_round_streak = 0
			G:save_settings()
		end
	end

	check_for_unlock({ type = "round_win" })
	set_joker_usage()
	for i = 1, #G.hand.cards do
		--Check for hand doubling
		local reps = { 1 }
		local j = 1
		while j <= #reps do
			local percent = (i - 0.999) / (#G.hand.cards - 0.998) + (j - 1) * 0.1
			if reps[j] ~= 1 then
				card_eval_status_text(
					(reps[j].jokers or reps[j].seals).card,
					"jokers",
					nil,
					nil,
					nil,
					(reps[j].jokers or reps[j].seals)
				)
			end

			--calculate the hand effects
			local effects = { G.hand.cards[i]:get_end_of_round_effect() }
			for k = 1, #G.jokers.cards do
				--calculate the joker individual card effects
				local eval = G.jokers.cards[k]:calculate_joker({
					cardarea = G.hand,
					other_card = G.hand.cards[i],
					individual = true,
					end_of_round = true,
				})
				if eval then
					table.insert(effects, eval)
				end
			end

			if reps[j] == 1 then
				--Check for hand doubling
				--From Red seal
				local eval = eval_card(
					G.hand.cards[i],
					{ end_of_round = true, cardarea = G.hand, repetition = true, repetition_only = true }
				)
				if next(eval) and (next(effects[1]) or #effects > 1) then
					for h = 1, eval.seals.repetitions do
						reps[#reps + 1] = eval
					end
				end

				--from Jokers
				for j = 1, #G.jokers.cards do
					--calculate the joker effects
					local eval = eval_card(G.jokers.cards[j], {
						cardarea = G.hand,
						other_card = G.hand.cards[i],
						repetition = true,
						end_of_round = true,
						card_effects = effects,
					})
					if next(eval) then
						for h = 1, eval.jokers.repetitions do
							reps[#reps + 1] = eval
						end
					end
				end
			end

			for ii = 1, #effects do
				--if this effect came from a joker
				if effects[ii].card then
					G.E_MANAGER:add_event(Event({
						trigger = "immediate",
						func = function()
							effects[ii].card:juice_up(0.7)
							return true
						end,
					}))
				end

				--If dollars
				if effects[ii].h_dollars then
					ease_dollars(effects[ii].h_dollars)
					card_eval_status_text(G.hand.cards[i], "dollars", effects[ii].h_dollars, percent)
				end

				--Any extras
				if effects[ii].extra then
					card_eval_status_text(G.hand.cards[i], "extra", nil, percent, nil, effects[ii].extra)
				end
			end
			j = j + 1
		end
	end
	delay(0.3)

	G.FUNCS.draw_from_hand_to_discard()
	if G.GAME.blind:get_type() == "Boss" then
		G.GAME.voucher_restock = nil
		if G.GAME.modifiers.set_eternal_ante and (G.GAME.round_resets.ante == G.GAME.modifiers.set_eternal_ante) then
			for k, v in ipairs(G.jokers.cards) do
				v:set_eternal(true)
			end
		end
		if
			G.GAME.modifiers.set_joker_slots_ante
			and (G.GAME.round_resets.ante == G.GAME.modifiers.set_joker_slots_ante)
		then
			G.jokers.config.card_limit = 0
		end
		delay(0.4)
		ease_ante(1)
		delay(0.4)
		check_for_unlock({ type = "ante_up", ante = G.GAME.round_resets.ante + 1 })
	end
	G.FUNCS.draw_from_discard_to_deck()
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.3,
		func = function()
			G.STATE = G.STATES.ROUND_EVAL
			G.STATE_COMPLETE = false

			if
				G.GAME.round_resets.blind_states.Small ~= "Defeated"
				and G.GAME.round_resets.blind_states.Small ~= "Skipped"
			then
				G.GAME.round_resets.blind_states.Small = "Defeated"
			elseif
				G.GAME.round_resets.blind_states.Big ~= "Defeated"
				and G.GAME.round_resets.blind_states.Big ~= "Skipped"
			then
				G.GAME.round_resets.blind_states.Big = "Defeated"
			else
				G.GAME.current_round.voucher = get_next_voucher_key()
				G.GAME.round_resets.blind_states.Boss = "Defeated"
				for k, v in ipairs(G.playing_cards) do
					v.ability.played_this_ante = nil
				end
			end

			if G.GAME.round_resets.temp_handsize then
				G.hand:change_size(-G.GAME.round_resets.temp_handsize)
				G.GAME.round_resets.temp_handsize = nil
			end
			if G.GAME.round_resets.temp_reroll_cost then
				G.GAME.round_resets.temp_reroll_cost = nil
				calculate_reroll_cost(true)
			end

			reset_idol_card()
			reset_mail_rank()
			reset_ancient_card()
			reset_castle_card()
			for k, v in ipairs(G.playing_cards) do
				v.ability.discarded = nil
				v.ability.forced_selection = nil
			end
			return true
		end,
	}))
	return true
end

function ease_lives(mod)
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			if not G.hand_text_area then
				return
			end
			local lives_UI = G.hand_text_area.ante
			mod = mod or 0
			local text = "+"
			local col = G.C.IMPORTANT
			if mod < 0 then
				text = "-"
				col = G.C.RED
			end
			lives_UI.config.object:update()
			G.HUD:recalculate()
			attention_text({
				text = text .. tostring(math.abs(mod)),
				scale = 1,
				hold = 0.7,
				cover = lives_UI.parent,
				cover_colour = col,
				align = "cm",
			})
			play_sound("highlight2", 0.685, 0.2)
			play_sound("generic1")
			return true
		end,
	}))
end

G.FUNCS.can_skip_booster = function(e)
	if
		G.pack_cards
		and G.pack_cards.cards
		and G.pack_cards.cards[1]
		and (
			G.STATE == G.STATES.PLANET_PACK
			or G.STATE == G.STATES.STANDARD_PACK
			or G.STATE == G.STATES.BUFFOON_PACK
			or (G.hand and G.hand.cards[1])
		)
	then
		e.config.colour = G.C.GREY
		e.config.button = "skip_booster"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

local update_selecting_hand_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
	if
		G.GAME.current_round.hands_left < G.GAME.round_resets.hands
		and #G.hand.cards < 1
		and #G.deck.cards < 1
		and #G.play.cards < 1
		and MP.is_in_lobby()
	then
		G.GAME.current_round.hands_left = 0
		if not MP.is_pvp_boss() then
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.NEW_ROUND
		else
			MP.send.play_hand(G.GAME.chips, 0)
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.HAND_PLAYED
		end
		return
	end
	update_selecting_hand_ref(self, dt)
end

local can_open_ref = G.FUNCS.can_open
G.FUNCS.can_open = function(e)
	if MP.game_state.ready_blind then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
		return
	end
	can_open_ref(e)
end

G.FUNCS.multiplayer_blind_chip_UI_scale = function(e)
	local nemesis = MP.get_nemesis()
	local new_score_text = number_format(nemesis.score)
	if G.GAME.blind and nemesis.score ~= nil and nemesis.score_text ~= new_score_text then
		e.config.scale = scale_number(nemesis.score, 0.7, 100000)
		nemesis.score_text = new_score_text
	end
end

local function show_enemy_location()
	local row_dollars_chips = G.HUD:get_UIE_by_ID("row_dollars_chips")
	if row_dollars_chips then
		row_dollars_chips.children[1]:remove()
		row_dollars_chips.children[1] = nil
		G.HUD:add_child({
			n = G.UIT.C,
			config = { align = "cm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cm", minw = 1.3 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0, maxw = 1.3 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = localize("enemy_loc"),
										scale = 0.42,
										colour = G.C.UI.TEXT_LIGHT,
										shadow = true,
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0, maxw = 1.3 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = localize("enemy_loc"),
										scale = 0.42,
										colour = G.C.UI.TEXT_LIGHT,
										shadow = true,
									},
								},
							},
						},
					},
				},
				{
					n = G.UIT.C,
					config = { align = "cm", minw = 3.3, minh = 0.7, r = 0.1, colour = G.C.DYN_UI.BOSS_DARK },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								ref_table = MP.get_nemesis(),
								ref_value = "location",
								scale = 0.35,
								colour = G.C.WHITE,
								id = "chip_UI_count",
								shadow = true,
							},
						},
					},
				},
			},
		}, row_dollars_chips)
	end
end

local function hide_enemy_location()
	local row_dollars_chips = G.HUD:get_UIE_by_ID("row_dollars_chips")
	if row_dollars_chips then
		row_dollars_chips.children[1]:remove()
		row_dollars_chips.children[1] = nil
		G.HUD:add_child({
			n = G.UIT.C,
			config = { align = "cm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cm", minw = 1.3 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0, maxw = 1.3 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = localize("k_round"),
										scale = 0.42,
										colour = G.C.UI.TEXT_LIGHT,
										shadow = true,
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0, maxw = 1.3 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = localize("k_lower_score"),
										scale = 0.42,
										colour = G.C.UI.TEXT_LIGHT,
										shadow = true,
									},
								},
							},
						},
					},
				},
				{
					n = G.UIT.C,
					config = { align = "cm", minw = 3.3, minh = 0.7, r = 0.1, colour = G.C.DYN_UI.BOSS_DARK },
					nodes = {
						{
							n = G.UIT.O,
							config = {
								w = 0.5,
								h = 0.5,
								object = get_stake_sprite(G.GAME.stake or 1, 0.5),
								hover = true,
								can_collide = false,
							},
						},
						{ n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
						{
							n = G.UIT.T,
							config = {
								ref_table = G.GAME,
								ref_value = "chips_text",
								lang = G.LANGUAGES["en-us"],
								scale = 0.85,
								colour = G.C.WHITE,
								id = "chip_UI_count",
								func = "chip_UI_set",
								shadow = true,
							},
						},
					},
				},
			},
		}, row_dollars_chips)
	end
end

local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
	local updated_location = false
	if MP.is_in_lobby() and not G.STATE_COMPLETE and not updated_location and not G.GAME.USING_RUN then
		MP.send.set_location("loc_shop")
		--show_enemy_location()
	end
	if G.STATE_COMPLETE and updated_location then
		updated_location = false
	end
	update_shop_ref(self, dt)
end

local update_blind_select_ref = Game.update_blind_select
function Game:update_blind_select(dt)
	local updated_location = false
	if MP.is_in_lobby() and not G.STATE_COMPLETE and not updated_location then
		MP.send.set_location("loc_selecting")
		--show_enemy_location()
		updated_location = true
	end
	if G.STATE_COMPLETE and updated_location then
		updated_location = false
	end
	update_blind_select_ref(self, dt)
end

local select_blind_ref = G.FUNCS.select_blind
function G.FUNCS.select_blind(e)
	MP.game_state.prevent_eval = false
	select_blind_ref(e)
	if MP.is_in_lobby() then
		local blind_key = (e.config.ref_table.key or e.config.ref_table.name)
		MP.game_state.ante_key = tostring(math.random())
		MP.send.play_hand(0, G.GAME.round_resets.hands)
		MP.send.set_location("loc_playing-" .. blind_key)
		--hide_enemy_location()
		if MP.is_host() and MP.value_is_pvp_boss(blind_key) then
			G.E_MANAGER:add_event(Event({
				trigger = "immediate",
				blockable = false,
				blocking = false,
				no_delete = true,
				func = function()
					local losers = MP.get_horde_losers()
					if losers ~= nil then
						for _, v in ipairs(losers) do
							MP.send.lose_life(v.code)
						end
						MP.send.end_pvp()
						return true
					end
					return false
				end,
			}))
		end
	end
end

function G.UIDEF.multiplayer_deck()
	return G.UIDEF.challenge_description(get_challenge_int_from_id("c_multiplayer_1"), nil, false)
end

local skip_blind_ref = G.FUNCS.skip_blind
G.FUNCS.skip_blind = function(e)
	skip_blind_ref(e)
	if MP.is_in_lobby() then
		MP.send.set_skips(G.GAME.skips)
	end
end
