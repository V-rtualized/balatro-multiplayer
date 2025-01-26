import { assertEquals } from 'jsr:@std/assert'
import { Client, ConnectedClient } from '../src/client.ts'
import { assertAction, assertTrue, getMockSocket } from './testing_utils.ts'
import ActionHandler from '../src/action_handler.ts'
import { Lobby } from '../src/lobby.ts'
import { parseMessage } from '../src/utils.ts'
import { ToMessage } from '../src/types.ts'

Deno.test('ActionHandler - connect', async (t) => {
	await t.step('should handle connect message', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)
		const connectMessage = {
			action: 'connect',
			username: 'testUser',
		} as const

		await ActionHandler.connect(client, connectMessage)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertTrue(client.isConnected())
		assertEquals(client.getUsername(), 'testUser')
		assertAction(lastMessage, 'connect_ack')
	})

	await t.step('should reject invalid connect message', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)
		const invalidMessage = {
			action: 'connect',
			username: '',
		} as const

		await ActionHandler.connect(client, invalidMessage)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertTrue(!client.isConnected())
		assertAction(lastMessage, 'error')
	})

	await t.step('should reject already connected client', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)
		const connectMessage = {
			action: 'connect',
			username: 'testUser',
		} as const

		await ActionHandler.connect(client, connectMessage)
		await ActionHandler.connect(client, connectMessage)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})

	await t.step('should reject missing username', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)
		const invalidMessage = {
			action: 'connect',
		} as const

		// deno-lint-ignore no-explicit-any
		await ActionHandler.connect(client, invalidMessage as any)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertTrue(!client.isConnected())
		assertAction(lastMessage, 'error')
	})
})

Deno.test('ActionHandler - openLobby', async (t) => {
	await t.step('should handle lobby creation', async () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		await ActionHandler.openLobby(client)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertTrue(
			client.getCurrentLobby()?.getHost().getCode() === client.getCode(),
		)
		assertAction(lastMessage, 'openLobby_ack')
	})

	await t.step('should reject if client not connected', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		await ActionHandler.openLobby(client)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})
})

Deno.test('ActionHandler - joinLobby', async (t) => {
	await t.step('should handle joining lobby', async () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		await ActionHandler.openLobby(host)

		const clientSocket = getMockSocket()
		const client: Client = new Client(clientSocket)
		client.setConnected('joinUser')

		const joinMessage = {
			action: 'join_lobby',
			code: host.getCode(),
		} as const

		await ActionHandler.joinLobby(client, joinMessage)

		const clientWrittenData = await clientSocket.toArray()
		const clientLastMessage = clientWrittenData[clientWrittenData.length - 1]
		assertAction(clientLastMessage, 'joinLobby_ack')

		const hostWrittenData = await hostSocket.toArray()
		const hostLastMessage = hostWrittenData[hostWrittenData.length - 1]
		assertAction(hostLastMessage, 'joinLobby')

		assertTrue(client.getCurrentLobby()?.getCode() === host.getCode())
	})

	await t.step('should reject if client not connected', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)
		const joinMessage = {
			action: 'join_lobby',
			code: 'TEST123',
		} as const

		await ActionHandler.joinLobby(client, joinMessage)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})

	await t.step('should reject missing lobby code', async () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')
		const invalidMessage = {
			action: 'join_lobby',
		} as const

		// deno-lint-ignore no-explicit-any
		await ActionHandler.joinLobby(client, invalidMessage as any)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})

	await t.step('should reject non-existent lobby', async () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')
		const joinMessage = {
			action: 'join_lobby',
			code: 'NONEXISTENT',
		} as const

		await ActionHandler.joinLobby(client, joinMessage)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})
})

Deno.test('ActionHandler - leaveLobby', async (t) => {
	await t.step('should handle leaving lobby', async () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		await ActionHandler.openLobby(host)

		const clientSocket = getMockSocket()
		const client: Client = new Client(clientSocket)
		client.setConnected('joinUser')
		await ActionHandler.joinLobby(client, {
			action: 'join_lobby',
			code: host.getCode(),
		})

		await ActionHandler.leaveLobby(client)
		const writtenData = await clientSocket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'leaveLobby_ack')
		assertEquals(client.getCurrentLobby(), null)
	})

	await t.step('should reject if client not connected', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		await ActionHandler.leaveLobby(client)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})

	await t.step('should reject if client not in lobby', async () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		await ActionHandler.leaveLobby(client)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]

		assertAction(lastMessage, 'error')
	})
})

Deno.test('ActionHandler - sendTo', async (t) => {
	await t.step('should reject if sending client is not in lobby', async () => {
		const clientSocket = getMockSocket()
		const client: Client = new Client(clientSocket)

		ActionHandler.sendTo(
			client,
			parseMessage(
				`action:score,to:ABC123,from:${client.getCode()},score:123`,
			) as ToMessage,
			'ABC123',
		)

		const clientMessages = await clientSocket.toArray()
		const lastClientMessage = clientMessages[clientMessages.length - 1]

		assertAction(lastClientMessage, 'error')
	})

	const hostSocket = getMockSocket()
	const host: Client = new Client(hostSocket)
	host.setConnected('hostUser')

	const lobby = Lobby.getOrCreateLobby(host)

	const clientSocket = getMockSocket()
	const client: Client = new Client(clientSocket)
	client.setConnected('clientUser')

	lobby.addClient(client)

	const client2Socket = getMockSocket()
	const client2: Client = new Client(client2Socket)
	client2.setConnected('clientUser2')

	await t.step(
		'should reject if receiving client is not in lobby',
		async () => {
			ActionHandler.sendTo(
				client,
				parseMessage(
					`action:score,to:${client2.getCode()},from:${client.getCode()},score:123`,
				) as ToMessage,
				client2.getCode(),
			)

			const clientMessages = await clientSocket.toArray()
			const lastClientMessage = clientMessages[clientMessages.length - 1]

			assertTrue(!lastClientMessage)
		},
	)

	lobby.addClient(client2)

	ActionHandler.sendTo(
		client2,
		parseMessage(
			`action:score,to:${client.getCode()},from:${client2.getCode()},score:123`,
		) as ToMessage,
		client.getCode(),
	)

	await t.step('should handle sending to specific clients', async () => {
		const clientMessages = await clientSocket.toArray()
		const lastClientMessage = clientMessages[clientMessages.length - 1]

		assertAction(lastClientMessage, 'score')
	})

	await t.step('should not send message to other clients', async () => {
		const hostMessages = await hostSocket.toArray()
		const lastHostMessage = hostMessages[hostMessages.length - 1]

		assertTrue(!lastHostMessage)
	})
})
