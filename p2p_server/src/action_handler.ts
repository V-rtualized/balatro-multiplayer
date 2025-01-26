import { Client, ConnectedClient } from './client.ts'
import { Lobby } from './lobby.ts'
import {
	ConnectMessage,
	JoinLobbyMessage,
	sendType,
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
			`action:connect_ack,code:${client.getCode()}`,
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

		await client.send('action:openLobby_ack', sendType.Ack, 'SERVER')
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
			await client.send(
				'action:error,message:Lobby not found',
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		targetLobby.addClient(connectedClient)

		const host = targetLobby.getHost()
		await host.send(
			`action:joinLobby,code:${lobby}`,
			sendType.Sending,
			'SERVER',
		)

		await client.send('action:joinLobby_ack', sendType.Ack, 'SERVER')
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

		connectedClient.leaveLobby()
		await client.send('action:leaveLobby_ack', sendType.Ack, 'SERVER')
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
