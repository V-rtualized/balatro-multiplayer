MP.gamemode_preview_texts = {
	gamemode_preview_1 = "",
	gamemode_preview_2 = "",
}

function MP.UI.BTN.change_gamemode_page(args)
	Galdur.clean_up_functions.clean_gamemode_areas()
	MP.UI.populate_player_card_areas(args.cycle_config.current_option)
end
G.FUNCS.mp_change_gamemode_page = MP.UI.BTN.change_gamemode_page

function MP.UI.gamemode_page()
	MP.UI.should_watch_player_cards = true
	MP.UI.generate_gamemode_card_areas()
	MP.UI.include_gamemode_preview()

	return {
		n = G.UIT.ROOT,
		config = { align = "tm", minh = 3.8, colour = G.C.CLEAR, padding = 0.1 },
		nodes = {
			{
				n = G.UIT.C,
				config = { padding = 0.15 },
				nodes = {
					MP.UI.generate_gamemode_card_areas_ui(),
					MP.UI.create_gamemode_page_cycle(),
				},
			},
			MP.UI.display_gamemode_preview(),
		},
	}
end

function MP.UI.generate_gamemode_card_areas()
	if Galdur.run_setup.gamemode_select_areas then
		for i = 1, #Galdur.run_setup.gamemode_select_areas do
			for j = 1, #G.I.CARDAREA do
				if Galdur.run_setup.gamemode_select_areas[i] == G.I.CARDAREA[j] then
					table.remove(G.I.CARDAREA, j)
					Galdur.run_setup.gamemode_select_areas[i] = nil
				end
			end
		end
	end
	Galdur.run_setup.gamemode_select_areas = {}
	for i = 1, #G.P_CENTER_POOLS.Gamemode do
		Galdur.run_setup.gamemode_select_areas[i] = CardArea(
			G.ROOM.T.w * 0.116,
			G.ROOM.T.h * 0.209,
			3.4 * 14 / 30,
			3.4 * 14 / 30,
			{ card_limit = 1, type = "deck", highlight_limit = 0, gamemode_select = true }
		)
	end
end

function MP.UI.generate_gamemode_card_areas_ui()
	local gamemode_ui_element = {}
	local count = 1
	for i = 1, (math.floor(#G.P_CENTER_POOLS.Gamemode / 8) + 1) do
		local row = { n = G.UIT.R, config = { colour = G.C.LIGHT, padding = 0.1 }, nodes = {} }
		for j = 1, math.min(#G.P_CENTER_POOLS.Gamemode, 8) do
			table.insert(row.nodes, {
				n = G.UIT.O,
				config = {
					object = Galdur.run_setup.gamemode_select_areas[count],
					r = 0.1,
					id = "gamemode_select_" .. count,
					count = count,
					outline_colour = G.C.YELLOW,
					focus_args = { snap_to = true },
				},
			})
			count = count + 1
		end
		table.insert(gamemode_ui_element, row)
	end

	MP.UI.populate_gamemode_card_areas(1)

	return {
		n = G.UIT.R,
		config = {
			align = "cm",
			minh = 0.45 + G.CARD_H + G.CARD_H,
			minw = 10.7,
			colour = G.C.BLACK,
			padding = 0.15,
			r = 0.1,
			emboss = 0.05,
		},
		nodes = gamemode_ui_element,
	}
end

function MP.UI.create_gamemode_page_cycle()
	local player_count = #MPAPI.LOBBY_PLAYERS.BY_INDEX
	local options = {}
	local cycle
	local total_pages = math.ceil(player_count / 12)
	for i = 1, total_pages do
		table.insert(options, localize("k_page") .. " " .. i .. " / " .. total_pages)
	end
	cycle = create_option_cycle({
		options = options,
		w = 4.5,
		opt_callback = "mp_change_gamemode_page",
		focus_args = { snap_to = true, nav = "wide" },
		current_option = 1,
		colour = G.C.RED,
		no_pips = true,
	})
	return { n = G.UIT.R, config = { align = "cm" }, nodes = { cycle } }
end

function MP.UI.get_gamemode_sprite_in_area(_gamemode, _scale, _area)
	_gamemode = _gamemode or 1
	_scale = _scale or 1
	_area = _area.T or { x = 0, y = 0 }
	local stake_sprite = Sprite(
		_area.x,
		_area.y,
		_scale * 1,
		_scale * 1,
		G.ANIMATION_ATLAS[G.P_CENTER_POOLS.Gamemode[_gamemode].atlas],
		G.P_CENTER_POOLS.Gamemode[_gamemode].pos
	)
	stake_sprite.states.drag.can = false
	if G.P_CENTER_POOLS["Gamemode"][_gamemode].shiny then
		stake_sprite.draw = function(_sprite)
			_sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
			_sprite.ARGS.send_to_shader[1] = math.min(_sprite.VT.r * 3, 1)
				+ G.TIMERS.REAL / 18
				+ (_sprite.juice and _sprite.juice.r * 20 or 0)
				+ 1
			_sprite.ARGS.send_to_shader[2] = G.TIMERS.REAL

			if _sprite.won then
				if Galdur.config.stake_colour == 1 then
					Sprite.draw_shader(_sprite, "dissolve")
					Sprite.draw_shader(_sprite, "voucher", nil, _sprite.ARGS.send_to_shader)
				else
					Sprite.draw_self(_sprite, G.C.L_BLACK)
				end
			else
				if Galdur.config.stake_colour == 2 then
					Sprite.draw_shader(_sprite, "dissolve")
					Sprite.draw_shader(_sprite, "voucher", nil, _sprite.ARGS.send_to_shader)
				else
					Sprite.draw_self(_sprite, G.C.L_BLACK)
				end
			end
		end
	end
	return stake_sprite
end

function MP.UI.populate_gamemode_card_areas(page)
	local count = 1 + (page - 1) * 16
	for i = 1, 16 do
		if count > #G.P_CENTER_POOLS.Gamemode then
			return
		end
		local card = Card(
			Galdur.run_setup.gamemode_select_areas[i].T.x,
			Galdur.run_setup.gamemode_select_areas[i].T.y,
			3.4 * 14 / 30,
			3.4 * 14 / 30,
			Galdur.run_setup.choices.deck.effect.center,
			Galdur.run_setup.choices.deck.effect.center,
			{ gamemode_chip = true, gamemode = count, galdur_selector = true }
		)
		card.facing = "back"
		card.sprite_facing = "back"
		card.children.back = MP.UI.get_gamemode_sprite_in_area(count, 3.4 * 14 / 30, card)

		card.children.back.states.hover = card.states.hover
		card.children.back.states.click = card.states.click
		card.children.back.states.drag = card.states.drag
		card.states.collide.can = false
		card.children.back:set_role({ major = card, role_type = "Glued", draw_major = card })
		Galdur.run_setup.gamemode_select_areas[i]:emplace(card)
		count = count + 1
	end
end

function MP.UI.clean_gamemode_areas()
	if not Galdur.run_setup.gamemode_select_areas then
		return
	end
	for j = #Galdur.run_setup.gamemode_select_areas, 1, -1 do
		if Galdur.run_setup.gamemode_select_areas[j].cards then
			remove_all(Galdur.run_setup.gamemode_select_areas[j].cards)
			Galdur.run_setup.gamemode_select_areas[j].cards = {}
		end
	end
end
Galdur.clean_up_functions.mp_clean_gamemode_areas = MP.UI.clean_gamemode_areas

function MP.set_new_gamemode(silent)
	G.E_MANAGER:clear_queue("galdur")
	MP.UI.populate_gamemode_preview(MP.lobby_state.config.gamemode, silent)

	local gamemode_name = split_string_2(
		G.localization.descriptions["Gamemode"][G.P_CENTER_POOLS.Gamemode[MP.lobby_state.config.gamemode].key].parsed_name
	)
	MP.gamemode_preview_texts.gamemode_preview_1 = gamemode_name[1]
	MP.gamemode_preview_texts.gamemode_preview_2 = gamemode_name[2]

	for i = 1, 2 do
		local dyna_text_object = G.OVERLAY_MENU:get_UIE_by_ID("gamemode_name_" .. i).config.object
		dyna_text_object.scale = 0.7 / math.max(1, string.len(MP.gamemode_preview_texts["gamemode_preview_" .. i]) / 8)
	end
end

Galdur.add_new_page({
	name = "page_title_gamemode",
	definition = MP.UI.gamemode_page,
	page = 1,
	condition = MPAPI.is_in_lobby,
})
