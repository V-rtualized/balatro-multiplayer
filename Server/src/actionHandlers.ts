import type Client from './Client.js'
import Lobby from './Lobby.js'
import type {
	ActionCreateLobby,
	ActionHandlerArgs,
	ActionHandlers,
	ActionJoinLobby,
	ActionUsername,
} from './actions.js'
import { serializeAction } from './main.js'
import { generateSeed } from './utils.js'

const usernameAction = (
	{ username }: ActionHandlerArgs<ActionUsername>,
	client: Client,
) => {
	client.setUsername(username)
}

const createLobbyAction = (
	{ gameMode }: ActionHandlerArgs<ActionCreateLobby>,
	client: Client,
) => {
	/** Also sets the client lobby to this newly created one */
	new Lobby(client)
}

const joinLobbyAction = (
	{ code }: ActionHandlerArgs<ActionJoinLobby>,
	client: Client,
) => {
	const newLobby = Lobby.get(code)
	if (!newLobby) {
		client.send(
			serializeAction({
				action: 'error',
				message: 'Lobby does not exist.',
			}),
		)
		return
	}
	newLobby.join(client)
}

const leaveLobbyAction = (client: Client) => {
	client.lobby?.leave(client)
}

const lobbyInfoAction = (client: Client) => {
	client.lobby?.broadcastLobbyInfo()
}

const keepAliveAction = (client: Client) => {
	// Send an ack back to the received keepAlive
	client.send(serializeAction({ action: 'keepAliveAck' }))
}

const startGameAction = (client: Client) => {
	// Only allow the host to start the game
	if (!client.lobby || client.lobby.host?.id !== client.id) {
		return
	}

	// Hardcoded for testing
	client.lobby.broadcast({
		action: 'startGame',
		deck: 'c_multiplayer_1',
		seed: generateSeed(),
	})
}

// Declared partial for now untill all action handlers are defined
export const actionHandlers = {
	username: usernameAction,
	createLobby: createLobbyAction,
	joinLobby: joinLobbyAction,
	lobbyInfo: lobbyInfoAction,
	leaveLobby: leaveLobbyAction,
	keepAlive: keepAliveAction,
	startGame: startGameAction,
} satisfies Partial<ActionHandlers>
