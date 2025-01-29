import { Client, ConnectedClient } from './client.ts'
import { Lobby } from './lobby.ts'
import {
	ConnectMessage,
	JoinLobbyMessage,
	sendType,
	SetUsernameMessage,
	ToMessage,
} from './types.ts'

const ActionHandler = {
	connect: async (client: Client, message: ConnectMessage) => {
		if (client.isConnected()) {
			await client.send(
				'action:error,message:Already connected',
				sendType.Error,
				'SERVER',
			)
			return
		}

		if (typeof message.username !== 'string') {
			await client.send(
				'action:error,message:Missing username',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const username = message.username.trim().substring(0, 20)
		if (username.length === 0) {
			await client.send(
				'action:error,message:Invalid username',
				sendType.Error,
				'SERVER',
			)
			return
		}

		client.setConnected(username)
		await client.send(
			`action:connect_ack,code:${client.getCode()},username:${username}`,
			sendType.Ack,
			'SERVER',
		)
	},

	setUsername: async (client: Client, message: SetUsernameMessage) => {
		if (!client.isConnected()) {
			await client.send(
				'action:error,message:Not connected',
				sendType.Error,
				'SERVER',
			)
			return
		}

		if (typeof message.username !== 'string') {
			await client.send(
				'action:error,message:Missing username',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const username = message.username.trim().substring(0, 20)
		if (username.length === 0) {
			await client.send(
				'action:error,message:Invalid username',
				sendType.Error,
				'SERVER',
			)
			return
		}

		client.setUsername(username)
		await client.send(
			`action:set_username_ack,username:${username}`,
			sendType.Ack,
			'SERVER',
		)
	},

	openLobby: async (client: Client) => {
		if (!client.isConnected()) {
			await client.send(
				'action:error,message:Not connected',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		Lobby.getOrCreateLobby(connectedClient)

		await client.send('action:open_lobby_ack', sendType.Ack, 'SERVER')
	},

	joinLobby: async (client: Client, message: JoinLobbyMessage) => {
		if (!client.isConnected()) {
			await client.send(
				'action:error,message:Not connected',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const lobby = message.code
		const checking = message.checking
		if (typeof lobby !== 'string') {
			await client.send(
				'action:error,message:Missing lobby code',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const targetLobby = Lobby.getLobby(lobby)
		if (!targetLobby) {
			if (checking === 'true') {
				await client.send(
					'action:join_lobby_ack',
					sendType.Error,
					'SERVER',
				)
			} else {
				await client.send(
					'action:error,message:Lobby not found',
					sendType.Error,
					'SERVER',
				)
			}
			return
		}

		const connectedClient = client as ConnectedClient
		targetLobby.addClient(connectedClient)

		await targetLobby.broadcast(
			`action:player_joined,code:${connectedClient.getCode()},username:${connectedClient.getUsername()}`)

		await client.send(`action:join_lobby_ack,code:${lobby}`, sendType.Ack, 'SERVER')
	},

	leaveLobby: async (client: Client) => {
		if (!client.isConnected()) {
			await client.send(
				'action:error,message:Not connected',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		const currentLobby = connectedClient.getCurrentLobby()

		if (!currentLobby) {
			await client.send(
				'action:error,message:Not in a lobby',
				sendType.Error,
				'SERVER',
			)
			return
		}

		await currentLobby.broadcast(
			`action:player_left,code:${connectedClient.getCode()}`)

		connectedClient.leaveLobby()
		await client.send('action:leave_lobby_ack', sendType.Ack, 'SERVER')
	},

	sendTo: async (client: Client, message: ToMessage, to: string) => {
		if (!client.isConnected()) {
			await client.send(
				'action:error,message:Not connected',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		const currentLobby = connectedClient.getCurrentLobby()

		if (!currentLobby) {
			await client.send(
				'action:error,message:Not in a lobby',
				sendType.Error,
				'SERVER',
			)
			return
		}

		await currentLobby.sendTo(to, message)
	},
}

export default ActionHandler
