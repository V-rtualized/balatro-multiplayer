import type Client from "./Client.js";
import GameModes from "./GameMode.js";
import type {
	ActionLobbyInfo,
	ActionServerToClient,
	GameMode,
} from "./actions.js";

const Lobbies = new Map();

const generateUniqueLobbyCode = (): string => {
	const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	let result = "";
	for (let i = 0; i < 5; i++) {
		result += chars.charAt(Math.floor(Math.random() * chars.length));
	}
	return Lobbies.get(result) ? generateUniqueLobbyCode() : result;
};

class Lobby {
	code: string;
	host: Client | null;
	guest: Client | null;
	gameMode: GameMode;
	// biome-ignore lint/suspicious/noExplicitAny: 
	options: { [key: string]: any };

	// Attrition is the default game mode
	constructor(gameMode: GameMode = "attrition", code: string) {
		this.code = code;
		Lobbies.set(this.code, this);

		this.host = null;
		this.guest = null;
		this.gameMode = gameMode;
		this.options = {};

		//host.setLobby(this);
		//host.sendAction({
		//	action: "joinedLobby",
		//	code: this.code,
		//	type: this.gameMode,
		//});
	}

	static get = (code: string) => {
		return Lobbies.get(code);
	};

	leave = (client: Client) => {
		if (this.host?.id === client.id) {
			this.host = this.guest;
			this.guest = null;
		} else if (this.guest?.id === client.id) {
			this.guest = null;
		}

		client.setLobby(null);
		this.broadcastAction({ action: "stopGame" });
		this.resetPlayers();
		this.broadcastLobbyInfo();
	};

	join = (client: Client) => {
		if (this.guest) {
			client.sendAction({
				action: "error",
				message: "Lobby is full or does not exist.",
			});
			return;
		}
		if (!this.host) {
			this.host = client;
		} else {			
			this.guest = client;
		}
		client.setLobby(this);
		client.sendAction({
			action: "joinedLobby",
			code: this.code,
			type: this.gameMode,
		});
		client.sendAction({ action: "lobbyOptions", gamemode: this.gameMode, ...this.options });
		this.broadcastLobbyInfo();
	};

	broadcastAction = (action: ActionServerToClient) => {
		this.host?.sendAction(action);
		this.guest?.sendAction(action);
	};

	broadcastLobbyInfo = () => {
		if (!this.host) {
			return;
		}

		const action: ActionLobbyInfo = {
			action: "lobbyInfo",
			host: this.host.username,
			hostHash: this.host.modHash,
			isHost: false,
		};

		if (this.guest?.username) {
			action.guest = this.guest.username;
			action.guestHash = this.guest.modHash;
			this.guest.sendAction(action);
		}

		// Should only sent true to the host
		action.isHost = true;
		this.host.sendAction(action);
	};

	setPlayersLives = (lives: number) => {
		if (this.host) this.host.lives = lives;
		if (this.guest) this.guest.lives = lives;

		this.broadcastAction({ action: "playerInfo", lives });
	};

	// Deprecated
	sendGameInfo = (client: Client) => {
		if (this.host !== client && this.guest !== client) {
			return client.sendAction({
				action: "error",
				message: "Client not in Lobby",
			});
		}

		client.sendAction({
			action: "gameInfo",
			...GameModes[this.gameMode].getBlindFromAnte(client.ante, this.options),
		});
	};

	setOptions = (options: { [key: string]: string }) => {
		for (const key of Object.keys(options)) {
			if (options[key] === "true" || options[key] === "false") {
				this.options[key] = options[key] === "true";
			} else {
				this.options[key] = options[key];
			}
		}
		this.guest?.sendAction({ action: "lobbyOptions", gamemode: this.gameMode, ...options });
	};

	resetPlayers = () => {
		if (this.host) {
			this.host.isReady = false;
			this.host.resetBlocker();
			this.host.setLocation("loc_selecting");
		}
		if (this.guest) {
			this.guest.isReady = false;
			this.guest.resetBlocker();
			this.guest.setLocation("loc_selecting");
		}
	}
}

export const fixBug = (lobbyCode: string, host: boolean) => {
	const lobby = Lobbies.get(lobbyCode)
	if (!lobby) {
		return
	}

	if (host) {
		if (!lobby.host) {
			return
		}
		lobby.host.lives += 1
		lobby.host.sendAction({ action: "playerInfo", lives: lobby.host.lives });
		lobby.host.sendAction({ action: "fixBug" });
	} else {
		if (!lobby.guest) {
			return
		}
		lobby.guest.lives += 1
		lobby.guest.sendAction({ action: "playerInfo", lives: lobby.guest.lives });
		lobby.guest.sendAction({ action: "fixBug" });
	}
}

export const addLives = (lobbyCode: string, host: boolean, lives: number) => {
	const lobby = Lobbies.get(lobbyCode)
	if (!lobby) {
		return
	}

	if (host) {
		if (!lobby.host) {
			return
		}
		lobby.host.lives += lives
		lobby.host.sendAction({ action: "playerInfo", lives: lobby.host.lives });
	} else {
		if (!lobby.guest) {
			return
		}
		lobby.guest.lives += lives
		lobby.guest.sendAction({ action: "playerInfo", lives: lobby.guest.lives });
	}
}

export const startGame = (seed: string, lobbyCode: string | undefined) => {
	if (!lobbyCode) {
		Lobbies.forEach((lobby) => {
			lobby.broadcastAction({ 
				action: "startGame",
				deck: "c_multiplayer_1",
				seed: seed, 
			})
			lobby.setPlayersLives(4);
		})
		return
	}
	
	const lobby = Lobbies.get(lobbyCode)
	if (!lobby) {
		return
	}

	lobby.broadcastAction({
		action: "startGame",
		deck: "c_multiplayer_1",
		seed: seed
	})
	lobby.setPlayersLives(4);
}

export const getLobbyInfo = (lobbyCode: string) => {
	const lobby = Lobbies.get(lobbyCode)
	if (!lobby) {
		return
	}

	const host = lobby.host?.username
	const guest = lobby.guest?.username

	const ante = lobby.host?.ante

	console.log(`Lobby: ${lobbyCode} Host: ${host} Guest: ${guest} Ante: ${ante}`)
}

new Lobby("attrition", "AAAAA")
new Lobby("attrition", "BBBBB")
new Lobby("attrition", "CCCCC")
new Lobby("attrition", "DDDDD")
new Lobby("attrition", "EEEEE")
new Lobby("attrition", "FFFFF")
new Lobby("attrition", "GGGGG")
new Lobby("attrition", "HHHHH")
new Lobby("attrition", "IIIII")

export default Lobby;
