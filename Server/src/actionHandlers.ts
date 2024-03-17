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

const playerReadyAction = (client: Client) => {
	client.isReady = true

	// TODO: Refactor for more than two players
	if (client.lobby?.host?.isReady && client.lobby.guest?.isReady) {
		// Reset ready status for next blind
		client.lobby.host.isReady = false
		client.lobby.guest.isReady = false

		client.lobby.broadcast({ action: 'startBlind' })
	}
}

const playerUnreadyAction = (client: Client) => {
	client.isReady = false
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
	playerReady: playerReadyAction,
	playerUnready: playerUnreadyAction,
} satisfies Partial<ActionHandlers>
