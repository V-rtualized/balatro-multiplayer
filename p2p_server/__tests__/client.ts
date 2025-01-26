import { assertEquals, assertNotEquals } from 'jsr:@std/assert'
import { Client } from '../src/client.ts'
import { assertAction, assertTrue, getMockSocket } from './testing_utils.ts'
import { Lobby } from '../src/lobby.ts'
import { sendType } from '../src/types.ts'

Deno.test('Client - Basic Operations', async (t) => {
	await t.step('should generate unique codes', () => {
		const socket1 = getMockSocket()
		const socket2 = getMockSocket()
		const client1 = new Client(socket1)
		const client2 = new Client(socket2)

		assertNotEquals(client1.getCode(), client2.getCode())
		assertEquals(client1.getCode().length, 6)
		assertEquals(client2.getCode().length, 6)
	})

	await t.step('should handle client connection state', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)

		assertTrue(!client.isConnected())
		client.setConnected('testUser')
		assertTrue(client.isConnected())
		assertEquals(client.getUsername(), 'testUser')
	})

	await t.step('should manage lobby membership', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		assertEquals(client.getCurrentLobby(), null)
		lobby.addClient(client)
		assertEquals(client.getCurrentLobby(), lobby)
	})
})

Deno.test('Client - Static Methods', async (t) => {
	await t.step('should get client from code', () => {
		const socket = getMockSocket()
		const client = new Client(socket)
		const retrievedClient = Client.getClientFromCode(client.getCode())
		assertEquals(retrievedClient, client)
	})

	await t.step('should return undefined for invalid code', () => {
		const retrievedClient = Client.getClientFromCode('INVALID')
		assertEquals(retrievedClient, undefined)
	})
})

Deno.test('Client - Username Management', async (t) => {
	await t.step('should set and get username', () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		assertEquals(client.getUsername(), undefined)
		client.setUsername('newUser')
		assertEquals(client.getUsername(), 'newUser')
	})

	await t.step('should update username', () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		client.setUsername('user1')
		assertEquals(client.getUsername(), 'user1')
		client.setUsername('user2')
		assertEquals(client.getUsername(), 'user2')
	})
})

Deno.test('Client - Lobby Operations', async (t) => {
	await t.step('should join lobby', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		client.joinLobby(lobby)
		assertEquals(client.getCurrentLobby(), lobby)
	})

	await t.step('should leave lobby', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		client.joinLobby(lobby)
		client.leaveLobby()
		assertEquals(client.getCurrentLobby(), null)
	})

	await t.step('should handle host status', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		Lobby.getOrCreateLobby(client)
		assertTrue(client.isHost())
	})

	await t.step('should handle non-host status', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		client.joinLobby(lobby)
		assertTrue(!client.isHost())
	})
})

Deno.test('Client - Cleanup', async (t) => {
	await t.step('should clean up client references', () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		const code = client.getCode()
		client.delete()

		assertEquals(Client.getClientFromCode(code), undefined)
	})

	await t.step('should leave lobby on delete', () => {
		const socket = getMockSocket()
		const client: Client = new Client(socket)
		client.setConnected('testUser')

		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		client.joinLobby(lobby)
		client.delete()

		assertEquals(client.getCurrentLobby(), null)
	})
})

Deno.test('Client - Message Sending', async (t) => {
	await t.step('should send formatted messages', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		await client.send('test message', sendType.Sending, 'SERVER')
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]
		assertEquals(lastMessage, 'test message\n')
	})

	await t.step('should handle object messages', async () => {
		const socket = getMockSocket()
		const client = new Client(socket)

		await client.send(
			{ action: 'error', message: 'message' },
			sendType.Sending,
			'SERVER',
		)
		const writtenData = await socket.toArray()
		const lastMessage = writtenData[writtenData.length - 1]
		assertAction(lastMessage, 'error')
	})
})
