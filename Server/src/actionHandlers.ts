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
	client.lobby?.broadcast()
}

const keepAliveAckAction = (client: Client) => {
	client.send(serializeAction({ action: 'keepAliveAck' }))
}

// Declared partial for now untill all action handlers are defined
export const actionHandlers: Partial<ActionHandlers> = {
	username: usernameAction,
	createLobby: createLobbyAction,
	joinLobby: joinLobbyAction,
	lobbyInfo: lobbyInfoAction,
	leaveLobby: leaveLobbyAction,
	keepAliveAck: keepAliveAckAction,
}
