import { Client, ConnectedClient } from './client.ts'
import { Lobby } from './lobby.ts'
import {
ActionMessage,
	ConnectMessage,
	JoinLobbyMessage,
	LeaveLobbyMessage,
	OpenLobbyMessage,
	sendType,
	SetUsernameMessage,
	ToMessage,
} from './types.ts'

const ActionHandler = {
	connect: async (client: Client, message: ConnectMessage) => {
		if (client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Already connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		if (typeof message.username !== 'string') {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Missing username',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const username = message.username.trim().substring(0, 20)
		if (username.length === 0) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Invalid username',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		client.setConnected(username)
		await client.send(
			{
				action: 'netaction_connect_ack',
				id: message.id,
				code: client.getCode(),
				username: username,
				from: 'SERVER',
			},
			sendType.Ack,
			'SERVER',
		)
	},

	setUsername: async (client: Client, message: SetUsernameMessage) => {
		if (!client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		if (typeof message.username !== 'string') {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Missing username',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const username = message.username.trim().substring(0, 20)
		if (username.length === 0) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Invalid username',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		client.setUsername(username)
		await client.send(
			{
				action: 'netaction_set_username_ack',
				id: message.id,
				username: username,
				from: 'SERVER',
			},
			sendType.Ack,
			'SERVER',
		)
	},

	openLobby: async (client: Client, message: OpenLobbyMessage) => {
		if (!client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		Lobby.getOrCreateLobby(connectedClient)

		await client.send(
			{
				action: 'netaction_open_lobby_ack',
				id: message.id,
				from: 'SERVER',
			},
			sendType.Ack,
			'SERVER',
		)
	},

	joinLobby: async (client: Client, message: JoinLobbyMessage) => {
		if (!client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const lobby = message.code
		const checking = message.checking
		if (typeof lobby !== 'string') {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Missing lobby code',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const targetLobby = Lobby.getLobby(lobby)
		if (!targetLobby) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Lobby not found',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		targetLobby.addClient(connectedClient, message.id)

		await targetLobby.broadcast(
			{
				action: 'netaction_player_joined',
				code: connectedClient.getCode(),
				username: connectedClient.getUsername(),
				id: '0',
				from: 'SERVER',
			},
		)

		await client.send(
			{
				action: 'netaction_join_lobby_ack',
				code: lobby,
				id: message.id,
				from: 'SERVER',
				players: targetLobby.getClients().map(client => ({ username: client.getUsername(), code: client.getCode() }))
			},
			sendType.Ack,
			'SERVER',
		)
	},

	leaveLobby: async (client: Client, message: LeaveLobbyMessage) => {
		if (!client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		const currentLobby = connectedClient.getCurrentLobby()

		if (!currentLobby) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not in a lobby',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		connectedClient.leaveLobby()
		await client.send(
			{
				action: 'netaction_leave_lobby_ack',
				id: message.id,
				from: 'SERVER',
			},
			sendType.Ack,
			'SERVER',
		)
	},

	sendTo: async (
		client: Client,
		message: ToMessage,
		to: string,
		raw_message: string,
	) => {
		if (!client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		const currentLobby = connectedClient.getCurrentLobby()

		if (!currentLobby) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not in a lobby',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		await currentLobby.sendTo(to, message.from, raw_message)
	},

	broadcast: async (client: Client, message: ActionMessage, raw_message: string) => {
		if (!client.isConnected()) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not connected',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		const connectedClient = client as ConnectedClient
		const currentLobby = connectedClient.getCurrentLobby()

		if (!currentLobby) {
			await client.send(
				{
					action: 'netaction_error',
					id: message.id,
					message: 'Not in a lobby',
					from: 'SERVER',
				},
				sendType.Error,
				'SERVER',
			)
			return
		}

		await currentLobby.broadcast(raw_message, client)
	},
}

export default ActionHandler
