MP.UI.VARS.should_watch_player_cards = false

function MP.UI.BTN.change_lobby_page(args)
	MP.UI.should_watch_player_cards = false
	Galdur.clean_up_functions.clean_deck_areas()
	MP.UI.populate_player_card_areas(args.cycle_config.current_option)
end
G.FUNCS.mp_change_lobby_page = MP.UI.BTN.change_lobby_page

function MP.UI.BTN.galdur_next_page_btn(e)
	if Galdur.run_setup.current_page == #Galdur.run_setup.pages and MP.is_in_lobby() then
		e.config.hover = MP.lobby_state.is_host
		e.config.shadow = MP.lobby_state.is_host
		e.config.colour = MP.lobby_state.is_host and HEX("00be67") or G.C.UI.BACKGROUND_INACTIVE
		e.children[1].children[1].config.colour = MP.lobby_state.is_host and G.C.WHITE or G.C.UI.TEXT_INACTIVE
		e.children[1].children[1].config.shadow = MP.lobby_state.is_host
		e.config.button = MP.lobby_state.is_host and "deck_select_next" or nil
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
	if MP.is_in_lobby() then
		e.config.hover = MP.lobby_state.is_host
		e.config.shadow = MP.lobby_state.is_host
		e.config.colour = MP.lobby_state.is_host and G.C.ORANGE or G.C.UI.BACKGROUND_INACTIVE
		e.children[1].children[1].children[1].config.colour = MP.lobby_state.is_host and G.C.WHITE
			or G.C.UI.TEXT_INACTIVE
		e.children[1].children[1].children[1].config.shadow = MP.lobby_state.is_host
		e.config.button = MP.lobby_state.is_host and "quick_start" or nil
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

function MP.UI.lobby_page()
	MP.UI.should_watch_player_cards = true
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
			type = "shop",
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
	local player_count = #MP.lobby_state.players
	local options = {}
	local cycle
	local total_pages = math.ceil(player_count / 12)
	for i = 1, total_pages do
		table.insert(options, localize("k_page") .. " " .. i .. " / " .. total_pages)
	end
	cycle = create_option_cycle({
		options = options,
		w = 4.5,
		opt_callback = "mp_change_lobby_page",
		focus_args = { snap_to = true, nav = "wide" },
		current_option = 1,
		colour = G.C.RED,
		no_pips = true,
	})
	return { n = G.UIT.R, config = { align = "cm" }, nodes = { cycle } }
end

function MP.UI.update_player_card(card, index)
	local e_player = MP.lobby_state.players[index]
	if e_player then
		card.ability.extra.player_index = index
		card.ability.extra.username = e_player.username
		card.ability.extra.text1 = e_player.code == MP.network_state.lobby and localize("lobby_host")
			or localize("lobby_member")
		card.ability.extra.text2 = localize("lobby_deck")
		card.area.config.highlighted_limit = 1
		if card.facing == "back" then
			card:flip()
		end
	else
		card.area.config.highlighted_limit = 0
		if card.facing == "front" then
			card:flip()
		end
	end
end

local poses = {
	G.P_CENTERS["j_baron"].pos,
	G.P_CENTERS["j_card_sharp"].pos,
	G.P_CENTERS["j_vampire"].pos,
	G.P_CENTERS["j_mime"].pos,
	G.P_CENTERS["j_sixth_sense"].pos,
	G.P_CENTERS["j_chaos"].pos,
	G.P_CENTERS["j_scholar"].pos,
	G.P_CENTERS["j_space"].pos,
	G.P_CENTERS["j_burglar"].pos,
	G.P_CENTERS["j_runner"].pos,
	G.P_CENTERS["j_hiker"].pos,
	G.P_CENTERS["j_luchador"].pos,
	G.P_CENTERS["j_fortune_teller"].pos,
	G.P_CENTERS["j_swashbuckler"].pos,
	G.P_CENTERS["j_stuntman"].pos,
	G.P_CENTERS["j_ring_master"].pos,
	G.P_CENTERS["j_merry_andy"].pos,
	G.P_CENTERS["j_golden"].pos,
	G.P_CENTERS["j_marble"].pos,
	G.P_CENTERS["j_even_steven"].pos,
	G.P_CENTERS["j_odd_todd"].pos,
}

function MP.UI.populate_player_card_areas(page)
	local count = 1 + (page - 1) * 12
	for i = 1, 12 do
		local card = nil
		local player = MP.lobby_state.players[count]
		card = SMODS.create_card({
			set = "Joker",
			area = Galdur.run_setup.player_select_areas[i],
			key = "j_mp_player",
			no_edition = true,
		})
		card.children.center:set_sprite_pos(poses[count])

		if not player then
			card.sprite_facing = "back"
			card.facing = "back"
		end

		card.children.back:remove()
		card.children.back = Sprite(
			card.T.x,
			card.T.y,
			card.T.w,
			card.T.h,
			G.ASSET_ATLAS["centers"],
			count > 8 and { y = 0, x = 4 } or { y = 4, x = 0 }
		)
		card.children.back.states.collide.can = false
		card.children.back:set_role({ major = card, role_type = "Glued", draw_major = card })

		if not Galdur.run_setup.player_select_areas[i].cards then
			Galdur.run_setup.player_select_areas[i].cards = {}
		end
		Galdur.run_setup.player_select_areas[i]:emplace(card, "front", true)

		MP.UI.update_player_card(card, count)

		local event
		event = Event({
			trigger = "after",
			blockable = false,
			blocking = false,
			delay = 0.5 * G.SETTINGS.GAMESPEED,
			pause_force = true,
			no_delete = true,
			func = function(t)
				MP.UI.update_player_card(card, event.player_index)
				event.start_timer = false
				return not MP.UI.should_watch_player_cards
			end,
		})
		event.player_index = count
		G.E_MANAGER:add_event(event)

		count = count + 1
	end
end

function MP.UI.clean_lobby_areas()
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
Galdur.clean_up_functions.mp_clean_lobby_areas = MP.UI.clean_lobby_areas

local function is_host()
	return MP.network_state.lobby == nil or MP.lobby_state.is_host
end

for i, _ in ipairs(Galdur.pages_to_add) do
	Galdur.pages_to_add[i].condition = is_host
end

Galdur.add_new_page({
	name = "page_title_lobby",
	definition = MP.UI.lobby_page,
	confirm = function()
		MP.UI.should_watch_player_cards = false
	end,
	quick_start_text = function()
		return tostring(#MP.lobby_state.players) .. " Players"
	end,
	post_start = function(choices)
		MP.send.start_run(choices)
	end,
	page = 1,
	condition = MP.is_in_lobby,
})
