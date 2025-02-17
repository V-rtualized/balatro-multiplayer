return {
	descriptions = {
		Joker = {
			j_mp_defensive_joker = {
				name = "Defensive Joker",
				text = {
					"This Joker gains {C:chips}+#1#{} Chips",
					"per {C:red,E:1}life{} lost this run",
					"{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)",
				},
			},
			j_mp_skip_off = {
				name = "Skip-Off",
				text = {
					"{C:blue}+#1#{} Hands and {C:red}+#2#{} Discards",
					"per additional {C:attention}Blind{} skipped",
					"compared to your {X:purple,C:white}Nemesis{}",
					"{C:inactive}(Currently {C:blue}+#3#{C:inactive}/{C:red}+#4#{C:inactive}, #5#)",
				},
			},
			j_mp_lets_go_gambling = {
				name = "Let's Go Gambling",
				text = {
					"{C:green}#1# in #2#{} chance to be destroyed",
					"when sold, otherwise gain {X:mult,C:white} +X#3# {}",
					"{C:inactive}(Scaling increases by {X:mult,C:white}+X#4#{C:inactive} after each {C:attention}Boss Blind{C:inactive})",
					"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult)",
				},
			},
			j_mp_hanging_bad = {
				name = "Hanging Bad",
				text = {
					"During {X:purple,C:white}Nemesis{} {C:attention}Blinds{} the",
					"{C:attention}first{} played card used in scoring",
					"is {C:attention}debuffed{} for both players",
				},
			},
			j_mp_speedrun = {
				name = "SPEEDRUN",
				text = {
					"{C:attention}Triple{} your total score",
					"when you spend all your {C:blue}Hands{} before",
					"your {X:purple,C:white}Nemesis{} on a {C:attention}PvP Blind{}",
				},
			},
			j_broken = {
				name = "BROKEN",
				text = {
					"This card is either broken or",
					"not implemented in the current",
					"version of a mod you are using.",
				},
			},
		},
		Planet = {
			c_mp_asteroid = {
				name = "Asteroid",
				text = {
					"Remove #1# level from",
					"your {X:purple,C:white}Nemesis'{}",
					"highest level",
					"{C:legendary,E:1}poker hand{}",
				},
			},
		},
		Blind = {
			bl_mp_nemesis = {
				name = "Your Nemesis",
				text = {
					"Face your nemesis,", -- Changed as of 1.0
					"most score wins",
				},
			},
			-- New as of 1.0
			bl_mp_precision = {
				name = "The Marksman",
				text = {
					"Face another player, closest",
					"to the target score wins",
				},
			},
			bl_mp_horde = {
				name = "The Horde",
				text = {
					"Face all other players,",
					"least score loses",
				},
			},
			bl_mp_truce = {
				name = "The Truce",
				text = {
					"Copies #1#,",
					"don't lose a life",
				},
			},
		},
		Gamemode = {
			gamemode_mp_attrition = {
				name = "Attrition",
				text = {
					"Fight 1-on-1 with your {X:purple,C:white}Nemesis{},",
					"player with the lowest score",
					"loses a life.",
					"{C:inactive}--", -- Lives text
					"{C:red}4 Lives",
					"{C:inactive}--", -- Other
					"{C:inactive}Your {X:purple,C:white}Nemesis{C:inactive} changes every ante.{}",
				},
			},
			gamemode_mp_battle_royale = {
				name = "Battle Royale",
				text = {
					"Fight against all remaining players",
					"at each Boss Blind. Player with",
					"the lowest score loses a life.",
					"{C:inactive}--", -- Lives text
					"{C:red}2-4 Lives{C:inactive}, depending on amount of players",
					"{C:inactive}--", -- Other
					"{C:inactive}At 5+ players, bottom 2 players lose a life",
				},
			},
			gamemode_mp_precision = {
				name = "Precision",
				text = {
					"Fight against all remaining players at ",
					"each Boss Blind. Player with the farthest",
					"score from the target score loses a life.",
					"{C:inactive}--", -- Lives text
					"{C:red}2-4 Lives{C:inactive}, depending on amount of players",
					"{C:inactive}--", -- Other
					"{C:inactive}At 5+ players, bottom 2 players lose a life",
				},
			},
			gamemode_mp_speedrun = {
				name = "Speedrun",
				text = {
					"First player to beat ante 8",
					"wins. No lives, losing restarts",
					"you on ante 1 with a different seed.",
					"{C:inactive}--", -- Lives text
					"{C:red}Win or Game Over{}",
					"{C:inactive}--", -- Other
					"{C:inactive}On same seed, players will get the same seed order",
				},
			},
		},
		Edition = {
			e_mp_phantom = {
				name = "Phantom",
				text = {
					"{C:attention}Eternal{} and {C:dark_edition}Negative{}",
					"Created and destroyed by your {X:purple,C:white}Nemesis{}",
				},
			},
		},
		Other = {
			current_nemesis = {
				name = "Nemesis",
				text = {
					"{X:purple,C:white}#1#{}",
					"Your one and only Nemesis",
				},
			},
		},
	},
	misc = {
		labels = {
			mp_phantom = "Phantom",
		},
		challenge_names = {
			c_multiplayer_1 = "Multiplayer",
		},
		dictionary = {
			singleplayer = "Singleplayer",
			join_lobby = "Join Lobby",
			return_lobby = "Return Lobby",
			reconnect = "Reconnect",
			create_lobby = "Create Lobby",
			start_lobby = "Start Lobby",
			coming_soon = "Coming Soon!",
			ready = "Ready",
			unready = "Unready",
			wait_enemy = "Waiting for enemy to finish...",
			lives = "Lives",
			leave_lobby = "Leave Lobby",
			lost_life = "Lost a life",
			failed = "Failed",
			defeat_enemy = "Defeated the Enemy",
			total_lives_lost = " Total Lives Lost ($4 each)",
			attrition_name = "Attrition",
			attrition_desc = "Every boss round is a competition between players where the player with the lower score loses a life.",
			showdown_name = "Showdown",
			showdown_desc = "Both players play 3 normal antes, then they play an ante where every round the player with the higher scorer wins.",
			draft_name = "Draft",
			draft_desc = "Players play the Evolving Deck from the Balatro Draft mod, where they each gain a Draft Tag after every PvP Blind.",
			draft_req = "Requires the Balatro Draft mod",
			monty_special_name = "The Dr. Monty Special",
			monty_special_desc = "A special gamemode designed by @dr_monty_the_snek on the discord server. I guess you'll have to find out what it is! (Gamemode changes with each minor update)",
			precision_name = "Precision",
			precision_desc = "The same as Attrition, except the person closest to the target score wins PvP blinds (instead of the person with the highest score).",
			royale_name = "Battle Royale",
			royale_desc = "Attrition, except there are up to 8 players and every player only has 1 life.",
			vanilla_plus_name = "Vanilla+",
			vp_desc = "The first person to fail a round loses, no PvP blinds.",
			enter_lobby_code = "Enter Lobby Code",
			join_clip = "Paste From Clipboard",
			username = "Username:",
			enter_username = "Enter username",
			join_discord = "Join the ",
			discord_name = "Balatro Multiplayer Discord Server",
			discord_msg = "You can report any bugs and find players to play there",
			enter_to_save = "Press enter to save",
			in_lobby = "In the lobby",
			connected = "Connected to Service",
			warn_service = "WARN: Cannot Find Multiplayer Service",
			set_name = "Set your username in the main menu! (Mods > Multiplayer > Config)",
			start = "START",
			wait_for = "WAITING FOR",
			host_start = "HOST TO START",
			players = "PLAYERS",
			lobby_options_cap = "LOBBY OPTIONS",
			lobby_options = "Lobby Options",
			copy_clipboard = "Copy to clipboard",
			connect_player = "Connected Players:",
			opts_only_host = "Only the Lobby Host can change these options",
			opts_cb_money = "Give comeback $ on life loss",
			opts_no_gold_on_loss = "Don't get blind rewards on round loss",
			opts_death_on_loss = "Lose a life on non-PvP round loss",
			opts_start_antes = "Starting Antes",
			opts_diff_seeds = "Players have different seeds",
			opts_lives = "Lives",
			opts_gm = "Gamemode Modifiers",
			bl_or = "or",
			bl_life = "Life",
			bl_death = "Death",
			loc_ready = "Ready for PvP",
			loc_selecting = "Selecting a Blind",
			loc_shop = "Shopping",
			loc_playing = "Playing ",
			current_seed = "Current seed: ",
			random = "Random",
			reset = "Reset",
			set_custom_seed = "Set Custom Seed",
			mod_hash_warning = "Players have different mods or mod versions! This can cause problems!",
			lobby_choose_deck = "DECK",
			opts_player_diff_deck = "Players have different decks",
			-- New as of 1.0
			page_title_lobby = "Lobby",
			page_title_gamemode = "Select Gamemode",
			lobby_host = "Host",
			lobby_member = "Member",
			lobby_spectator = "Spectator",
			lobby_deck = "Lobby Deck",
			b_open_lobby = "Open Lobby",
			b_join_lobby = "Join Lobby",
			not_connected = "Server Not Found",
			b_reconnect = "Reconnect",
			b_copy_code = "Copy Code",
			b_return_to_lobby = "Return to Lobby",
			b_leave_lobby = "Leave Lobby",
			k_enter_code = "Enter Code",
			k_planetesimal = "Planetesimal",
			consider_supporting = "This Mod is developed by one person, if you want to support it's development consider",
			kofi_name = "Buying me a Coffee",
			new_host = "The lobby host has left, you are now the lobby host. The lobby code has changed.",
			enemy_loc = { "Enemy", "location" },
			return_to_lobby_split = { "Return to", "Lobby" },
			leave_lobby_split = { "Leave", "Lobby" },
			k_bl_mp_nemesis_score_text = "Current Nemesis Score:",
			k_bl_mp_nemesis_secondary_text = "Nemesis Hands Left: ",
			k_bl_mp_horde_score_text = "Score to Beat:",
			k_bl_mp_horde_secondary_text = "Current Ranking: ",
			k_bl_mp_precision_score_text = "Target Score",
			k_bl_mp_precision_secondary_text = "Current Ranking: ",
			k_gamemode = "Gamemode",
		},
		v_dictionary = {
			mp_art = { "Art: #1#" },
			mp_code = { "Code: #1#" },
			mp_idea = { "Idea: #1#" },
			mp_skips_ahead = { "#1# Skips Ahead" },
			mp_skips_behind = { "#1# Skips Behind" },
			mp_skips_tied = { "Tied" },
			a_xmult_plus = "+X#1# Mult",
		},
	},
}
