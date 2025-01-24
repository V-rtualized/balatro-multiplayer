import { Client, ConnectedClient } from './state_manager.ts'
import { ActionMessage, ConnectMessage, JoinLobbyMessage } from './types.ts'

const relayToHost = async (client: ConnectedClient, message: ActionMessage) => {
	const lobby = client.getLobby()

	if (lobby === null) {
		await client.send('action:error,message:Not in a lobby')
		return
	}

	const lobbyClient = Client.getClientFromCode(lobby)

	if (!lobbyClient || !lobbyClient.isConnected()) {
		await client.send('action:error,message:Lobby not found')
		return
	}

	lobbyClient.send(message, 'relay', client._code)
}

const broadcastToLobby = async (
	client: ConnectedClient,
	message: ActionMessage,
) => {
	const lobby = client.getLobby()

	if (lobby === null) {
		await client.send('action:error,message:Not in a lobby')
		return
	}

	const lobbyClients = Client.getClientsInLobby(lobby)

	for (const lobbyClient of lobbyClients) {
		lobbyClient.send(
			`[Broadcast] [${client._code}]->[${lobbyClient._code}]: ${message}`,
		)
	}
}

const ActionHandler = {
	connect: async (client: Client, message: ConnectMessage) => {
		if (client.isConnected()) {
			await client.send('action:error,message:Already connected')
			return
		}

		if (typeof message.username !== 'string') {
			await client.send('action:error,message:Missing username')
			return
		}

		const username = message.username.trim().substring(0, 20)

		if (username.length === 0) {
			await client.send('action:error,message:Invalid username')
			return
		}

		client.setConnected(username)

		await client.send(`action:connect_ack,code:${client.getCode()}`)
	},
	relay: async (client: Client, message: ActionMessage) => {
		if (!client.isConnected()) {
			await client.send('action:error,message:Not connected')
			return
		}

		if (client.isHost()) {
			await broadcastToLobby(client, message)
			return
		}

		await relayToHost(client, message)
	},
	openLobby: async (client: ConnectedClient) => {
		client.setLobby(client.getCode())

		await client.send('action:openLobby_ack')
	},
	joinLobby: async (client: ConnectedClient, message: JoinLobbyMessage) => {
		const lobby = message.code

		if (typeof lobby !== 'string') {
			await client.send('action:error,message:Missing lobby code')
			return
		}

		const lobbyClient = Client.getClientFromCode(lobby)

		if (!lobbyClient || !lobbyClient.isConnected()) {
			await client.send('action:error,message:Lobby not found')
			return
		}

		lobbyClient.send(`action:joinLobby,code:${lobby}`)

		client.setLobby(lobby)

		await client.send('action:joinLobby_ack')
	},
}

export default ActionHandler
