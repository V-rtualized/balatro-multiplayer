function MP.UI.lobby_page()
	MP.UI.generate_lobby_card_areas()

	return {
		n = G.UIT.ROOT,
		config = { align = "tm", minh = 3.8, colour = G.C.CLEAR, padding = 0.1 },
		nodes = {
			{
				n = G.UIT.C,
				config = { padding = 0.15 },
				nodes = {
					MP.UI.generate_lobby_card_areas_ui(),
					MP.UI.create_lobby_page_cycle(),
				},
			},
		},
	}
end

function MP.UI.generate_lobby_card_areas()
	if Galdur.run_setup.player_select_areas then
		for i = 1, #Galdur.run_setup.player_select_areas do
			for j = 1, #G.I.CARDAREA do
				if Galdur.run_setup.player_select_areas[i] == G.I.CARDAREA[j] then
					table.remove(G.I.CARDAREA, j)
					Galdur.run_setup.player_select_areas[i] = nil
				end
			end
		end
	end
	Galdur.run_setup.player_select_areas = {}
	for i = 1, 12 do
		Galdur.run_setup.player_select_areas[i] = CardArea(G.ROOM.T.w, G.ROOM.T.h, G.CARD_W, G.CARD_H, {
			card_limit = 1,
			type = "deck",
			highlight_limit = 0,
			player_select = true,
		})
	end
end

function MP.UI.generate_lobby_card_areas_ui()
	local player_ui_element = {}
	local count = 1
	for i = 1, 2 do
		local row = { n = G.UIT.R, config = { colour = G.C.LIGHT }, nodes = {} }
		for j = 1, 6 do
			table.insert(row.nodes, {
				n = G.UIT.O,
				config = {
					object = Galdur.run_setup.player_select_areas[count],
					r = 0.1,
					id = "player_select_" .. count,
					focus_args = { snap_to = true },
				},
			})
			count = count + 1
		end
		table.insert(player_ui_element, row)
	end

	MP.UI.populate_player_card_areas(1)

	return {
		n = G.UIT.R,
		config = { align = "cm", minh = 3.3, minw = 5, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05 },
		nodes = player_ui_element,
	}
end

function MP.UI.create_lobby_page_cycle()
	local player_count = MP.get_player_count()
	local options = {}
	local cycle
	local total_pages = math.ceil(player_count / 12)
	for i = 1, total_pages do
		table.insert(options, localize("k_page") .. " " .. i .. " / " .. total_pages)
	end
	cycle = create_option_cycle({
		options = options,
		w = 4.5,
		opt_callback = "change_lobby_page",
		focus_args = { snap_to = true, nav = "wide" },
		current_option = 1,
		colour = G.C.RED,
		no_pips = true,
	})
	return { n = G.UIT.R, config = { align = "cm" }, nodes = { cycle } }
end

function MP.UI.populate_player_card_areas(page)
	local player_count = MP.get_player_count()
	local count = 1 + (page - 1) * 12
	for i = 1, 12 do
		local card_number = Galdur.config.reduce and 1 or 10
		for index = 1, card_number do
			local card = Card(
				Galdur.run_setup.player_select_areas[i].T.x,
				Galdur.run_setup.player_select_areas[i].T.y,
				G.CARD_W,
				G.CARD_H,
				G.P_CARDS.empty,
				G.P_CENTER_POOLS.Joker[count]
			)
			card.sprite_facing = "back"
			card.facing = "back"
			card.children.back:remove()

			if count > player_count then
				card.children.back =
					Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["centers"], { y = 4, x = 0 })
			else
				card.children.back = Sprite(
					card.T.x,
					card.T.y,
					card.T.w,
					card.T.h,
					G.ASSET_ATLAS["Joker"],
					G.P_CENTER_POOLS.Joker[count].pos
				)
				card.children.back.states.hover = card.states.hover
				card.children.back.states.click = card.states.click
				card.children.back.states.drag = card.states.drag
			end

			card.children.back.states.collide.can = false
			card.children.back:set_role({ major = card, role_type = "Glued", draw_major = card })

			if not Galdur.run_setup.player_select_areas[i].cards then
				Galdur.run_setup.player_select_areas[i].cards = {}
			end
			Galdur.run_setup.player_select_areas[i]:emplace(card)
		end
		count = count + 1
	end
end

function Galdur.clean_up_functions.clean_lobby_areas()
	if not Galdur.run_setup.player_select_areas then
		return
	end
	for j = #Galdur.run_setup.player_select_areas, 1, -1 do
		if Galdur.run_setup.player_select_areas[j].cards then
			remove_all(Galdur.run_setup.player_select_areas[j].cards)
			Galdur.run_setup.player_select_areas[j].cards = {}
		end
	end
end

G.FUNCS.change_lobby_page = function(args)
	Galdur.clean_up_functions.clean_deck_areas()
	MP.UI.populate_player_card_areas(args.cycle_config.current_option)
end

Galdur.add_new_page({
	name = "page_title_lobby",
	definition = MP.UI.lobby_page,
	--pre_start = "function to run before game is started",
	--post_start = "function to run after game is started",
	--confirm = "function to run on page confirm",
	--quick_start_text = "function that returns the text to add to the tooltip",
	page = 1,
})
