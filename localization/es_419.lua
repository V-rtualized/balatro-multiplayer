-- Localization by @themike_71
return {
	descriptions = {
		Joker = {
			j_mp_defensive_joker = {
				name = "Comodín Defensivo",
				text = {
					"Este comodín gana {C:chips}+#1#{} Fichas",
					"por {C:red,E:1}vida{} perdida esta ronda",
					"{C:inactive}(Actual {C:chips}+#2#{C:inactive} Fichas)",
				},
			},
			j_mp_skip_off = {
				name = "Avioncito",
				text = {
					"{C:blue}+#1#{} Manos y {C:red}+#2#{} Descartes",
					"por {C:attention}ciega{} adicional omitida",
					"comparado con tu {X:purple,C:white}Némesis{}",
					"{C:inactive}(Actual {C:blue}+#3#{C:inactive}/{C:red}+#4#{C:inactive}, #5#)",
				},
			},
			j_mp_lets_go_gambling = {
				name = "Let's Go Gambling",
				text = {
					"Cuando se vende, {C:green}#1# en #2#{} probabilidades",
					"de ser destruída, si no se destruye gana {X:mult,C:white} +X#3# {}",
					"{C:inactive}(Aumenta {X:mult,C:white}+X#4#{C:inactive} cando derrotas a la {C:attention}ciega jefe{C:inactive})",
					"{C:inactive}(Actual {X:mult,C:white}X#5#{C:inactive} Multi)",
				},
			},
			j_mp_hanging_bad = {
				name = "Tirando Mal",
				text = {
					"Durante las {C:attention}ciegas{} contra tu {X:purple,C:white}Némesis{}",
					"la {C:attention}primera{} carta jugada que puntúe queda",
					"{C:attention}debilitada{} para ambos jugadores",
				},
			},
			j_mp_speedrun = {
				name = "SPEEDRUN",
				text = {
					"Si gastas todas tus {C:blue}Manos{} antes que",
					"tu {X:purple,C:white}Némesis{} en una {C:attention}ciega PvP{},",
					"{C:attention}triplica{} tu puntación total",
				},
			},
			j_broken = {
				name = "ERROR :(",
				text = {
					"Esta carta está rota o no está",
					"implementada en la versión actual",
					"de un mod que estás usando.",
				},
			},
		},
		Planet = {
			c_mp_asteroid = {
			name = "Asteroide",
			text = {
				"Disminuye #1# nivel de la",
				"{C:legendary,E:1}mano de poker{}",
				"con mayor nivel",
				"de tu {X:purple,C:white}Némesis{}",
				},
			},
		},
		Blind = {
			bl_mp_nemesis = {
				name = "Tu Némesis",
				text = {
					"Tú contra tu propio Némesis,", -- Changed as of 1.0
					"quien tenga más fichas gana",
				},
			},
			-- New as of 1.0
			bl_mp_precision = {
				name = "La Marca",
				text = {
					"Entfrentate a otro jugador,",
					"el más cercano al objetivo gana",
				},
			},
			bl_mp_horde = {
				name = "La Orda",
				text = {
					"Pelea contra todos los jugadores,",
					"el puntaje más bajo pierde",
				},
			},
			bl_mp_truce = {
				name = "La Tregua",
				text = {
					"Copia #1#,",
					"no mueras",
				},
			},
		},
		Gamemode = {
			gamemode_mp_attrition = {
				name = "Desgaste",
				text = {
					"Pelea 1 a 1 contra tu {X:purple,C:white}Némesis{},",
					"El jugador con menos puntos",
					"pierde una vida.",
					"{C:inactive}--", -- Lives text
					"{C:red}4 Vidas",
					"{C:inactive}--", -- Other
					"{C:inactive}Tu {X:purple,C:white}Némesis{C:inactive} cambia cada ciega.{}",
				},
			},
			gamemode_mp_battle_royale = {
				name = "Battle Royale",
				text = {
					"Pelea contra todos los jugadores restantes",
					"en cada ciega jefe. El jgador con",
					"la menor puntiación pierde una vida.",
					"{C:inactive}--", -- Lives text
					"{C:red}2-4 Vidas{C:inactive}, dependiando la cantidad de jugadores",
					"{C:inactive}--", -- Other
					"{C:inactive}Con 5+ jugadores, los últimos 2 pierden una vida",
				},
			},
			gamemode_mp_precision = {
				name = "Precisión",
				text = {
					"Pelea contra todos los jugadores restantes ",
					"en cada ciega jefe. El jugador con la ",
					"puntuación más lejana al Target pierde una vida",
					"{C:inactive}--", -- Lives text
					"{C:red}2-4 Vidas{C:inactive}, dependiando la cantidad de jugadores",
					"{C:inactive}--", -- Other
					"{C:inactive}Con 5+ jugadores, los últimos 2 pierden una vida",
				},
			},
			gamemode_mp_speedrun = {
				name = "Speedrun",
				text = {
					"El primer jugador en vencer la ciega 8",
					"gana. No hay vidas ni reinicios al perder",
					"1 a 1 con difrerentes Seeds",
					"{C:inactive}--", -- Lives text
					"{C:red}Gana o Pierde{}",
					"{C:inactive}--", -- Other
					"{C:inactive}Misma Seed, los jugadores estarán en la misma seed",
				},
			},
		},
		Edition = {
			e_mp_phantom = {
				name = "Fantasma",
				text = {
					"{C:attention}Eternos{} y {C:dark_edition}Negativos{}",
					"Creados y destruidos por tu {X:purple,C:white}Némesis{}",
				},
			},
		},
		Other = {
			current_nemesis = {
				name = "Némesis",
				text = {
					"{X:purple,C:white}#1#{}",
					"Tu propio Némesis",
				},
			},
		},
	},
	misc = {
		labels = {
			mp_phantom = "Fantasma",
		},
		challenge_names = {
			c_multiplayer_1 = "Multijugador",
		},
		dictionary = {
			singleplayer = "Un Jugador",
			join_lobby = "Unirse al Lobby",
			return_lobby = "Regresar al Lobby",
			reconnect = "Reconnectar",
			create_lobby = "Crear una Lobby",
			start_lobby = "Iniciar Lobby",
			coming_soon = "¡Próximamente!",
			ready = "Listo",
			unready = "No Listo",
			wait_enemy = "Esperando al contrincante...",
			lives = "Vidas",
			leave_lobby = "Abandonar Lobby",
			lost_life = "-1 a vida",
			failed = "Falló",
			defeat_enemy = "Enemigo Derrotado",
			total_lives_lost = " Vidas Totales perdidas ($4 cada una)",
			attrition_name = "Desgaste",
			attrition_desc = "Every boss round is a competition between players where the player with the lower score loses a life.",
			showdown_name = "Showdown",
			showdown_desc = "Ambos jugadores juegan 3 Apuestas normales, luego deben seguir superando la puntuación anterior del oponente cada ronda.",
			draft_name = "Draft",
			draft_desc = "Se jugará con el Mazo Evolutivo del Balatro Draft mod, donde se consigue una Draft Tag (etiqueta) después de la ciega PvP.",
			draft_req = "Requiere Balatro Draft mod",
			monty_special_name = "El Especial del Dr. Monty",
			monty_special_desc = "Un modo especial hecho por @dr_monty_the_snek en nuestro server. ¡Supongo que tendrás que jugar para averiguar de qué trata! (El modo cambia cada actualización)",
			precision_name = "Precisión",
			precision_desc = "Igual que Desgaste, pero gana quien se acerque al puntaje marcado (en vez del mayor puntaje).",
			royale_name = "Battle Royale",
			royale_desc = "Desgaste, excepto que son 8 Jugadores con 1 sola vida.",
			vanilla_plus_name = "Vanilla+",
			vp_desc = "El primero que falle una ronda pierde, no hay Ciegas PvP.",
			enter_lobby_code = "Agregar Código de Lobby",
			join_clip = "Pega desde el portapapeles",
			username = "Nombre de Usuario:",
			enter_username = "Agregar Nombre de Usuario",
			join_discord = "Únete a nuestro Discord ",
			discord_name = "Balatro Multiplayer Discord Server",
			discord_msg = "Puedes reportar bugs y encontrar más jugadores allí",
			enter_to_save = "Presiona ENTER para guardar cambios",
			in_lobby = "En lobby",
			connected = "Conectado al Servidor",
			warn_service = "ADVERTENCIA: No se ha encontrado Server Multijugador",
			set_name = "¡Agrega tu Usuario en el menú! (Mods > Multiplayer > Config)",
			start = "INICIAR",
			wait_for = "ESPERAANDO AL",
			host_start = "ANFITRIÓN PARA EMPEZAR",
			players = "JUGADORES",
			lobby_options_cap = "OPCIONES DEL LOBBY",
			lobby_options = "Opciones del Lobby",
			copy_clipboard = "Copiar desde el portapapeles",
			connect_player = "Jugadores conectados:",
			opts_only_host = "Solo el Anfitrion puede modificar esta opción",
			opts_cb_money = "Recibe oro al perder una vida",
			opts_no_gold_on_loss = "Sin recompensa al perder una ronda",
			opts_death_on_loss = "Pierde una Vida por ronda No-PvP",
			opts_start_antes = "Iniciando ciega",
			opts_diff_seeds = "Los jugadores estan en diferentes Seeds",
			opts_lives = "Vidas",
			opts_gm = "Opciones del Modo de Juego",
			bl_or = "o",
			bl_life = "Vive",
			bl_death = "Muere",
			loc_ready = "Listo para el PvP",
			loc_selecting = "Eligiendo ciega",
			loc_shop = "En la Tienda",
			loc_playing = "Jugando ",
			current_seed = "Seed actual: ",
			random = "Random",
			reset = "Resetear",
			set_custom_seed = "Agregar Seed",
			mod_hash_warning = "¡Los jugadores tienen diferentes mods o diferentes versiones de mods! ¡Esto puede causar problemas!",
			lobby_choose_deck = "MAZO",
			opts_player_diff_deck = "Los jugadores tienen diferentes Mazos",
			-- New as of 1.0
			page_title_lobby = "Lobby",
			page_title_gamemode = "Elegir Modo de Juego",
			lobby_host = "Anfitrión",
			lobby_member = "Miembro",
			lobby_spectator = "Espectador",
			lobby_deck = "Mazo del Lobby",
			b_open_lobby = "Crear Lobby",
			b_join_lobby = "Unirse a Lobby",
			not_connected = "No se encontró Servidor",
			b_reconnect = "Reconnectar",
			b_copy_code = "Copiar Código",
			b_return_to_lobby = "Regresar al Lobby",
			b_leave_lobby = "Abandonar Lobby",
			k_enter_code = "Agregar Codigo",
			k_planetesimal = "Planetesimal",
			consider_supporting = "Este mod está hecho por una persona, si quieres apoyar el desarrollo puedes considerar",
			kofi_name = "Donar en Ko-Fi",
			new_host = "El anfitrión abandonó la Lobby, Ahora eres el anfitrión. El codigo ha cambiado",
			enemy_loc = { "Enemigo", "Ubicación" },
			return_to_lobby_split = { "regresar al", "Lobby" },
			leave_lobby_split = { "Leave", "Lobby" },
			k_bl_mp_nemesis_score_text = "Puntuación del Némesis:",
			k_bl_mp_nemesis_secondary_text = "Manos restantes: ",
			k_bl_mp_horde_score_text = "Puntuación a superar:",
			k_bl_mp_horde_secondary_text = "Ranking Actual: ",
			k_bl_mp_precision_score_text = "Puntiación Marcada",
			k_bl_mp_precision_secondary_text = "Ranking Actual: ",
			k_gamemode = "Gamemode",
		},
		v_dictionary = {
			mp_art = { "Arte: #1#" },
			mp_code = { "Código: #1#" },
			mp_idea = { "Idea: #1#" },
			mp_skips_ahead = { "#1# Skips Delante" },
			mp_skips_behind = { "#1# Skips Detras" },
			mp_skips_tied = { "Tied" },
			a_xmult_plus = "+X#1# Multi",
		},
	},
}
