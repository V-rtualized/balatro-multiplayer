import type { LuaClassFn } from '../types/global'

G.MULTIPLAYER = {}

G.LOBBY = {
	connected: false,
	temp_code: '',
	code: null,
	type: '',
	config: {},
	username: 'Guest',
	host: {},
	guest: {},
	is_host: false,
}

G.MULTIPLAYER_GAME = {
	ready_blind: false,
	ready_blind_text: 'Ready',
}

declare let PREV_ACHIEVEMENT_VALUE: boolean
PREV_ACHIEVEMENT_VALUE = true
G.MULTIPLAYER.update_connection_status = () => {
	// Save the previous value of the achievement flag
	PREV_ACHIEVEMENT_VALUE = G.F_NO_ACHIEVEMENTS

	if (G.LOBBY.connected) {
		// Disable achievements when connected to server
		G.F_NO_ACHIEVEMENTS = true
	} else {
		// Restore them when disconnected
		G.F_NO_ACHIEVEMENTS = PREV_ACHIEVEMENT_VALUE
	}

	if (G.HUD_connection_status) {
		;(G.HUD_connection_status.remove as LuaClassFn)()
	}

	G.HUD_connection_status = G.UIDEF.get_connection_status_ui()
}

const gameMainMenuRef = Game.main_menu
Game.main_menu = function (this: any, change_context: any) {
	G.MULTIPLAYER.update_connection_status()
	gameMainMenuRef(this, change_context)
}

G.FUNCS.copy_to_clipboard = (_e: any) => {
	Utils.copy_to_clipboard(G.LOBBY.code)
}

G.FUNCS.reconnect = (_e: any) => {
	G.MULTIPLAYER.connect()
	;(G.FUNCS.exit_overlay_menu as LuaClassFn)()
}

G.MULTIPLAYER.update_player_usernames = () => {
	if (G.LOBBY.code) {
		if (G.MAIN_MENU_UI !== null) {
			;(G.MAIN_MENU_UI.remove as LuaClassFn)()
		}

		G.FUNCS.display_lobby_main_menu_UI()
	}
}
