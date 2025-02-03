import { assertEquals } from 'jsr:@std/assert'
import { Client, ConnectedClient } from '../src/client.ts'
import { assertAction, assertTrue, getMockSocket } from './testing_utils.ts'
import { Lobby } from '../src/lobby.ts'
import { ToMessage } from '../src/types.ts'
import { parseMessage } from '../src/utils.ts'

Deno.test('Lobby - Static Methods', async (t) => {
	await t.step('should get existing lobby', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		const retrieved = Lobby.getLobby(lobby.getCode())
		assertEquals(retrieved, lobby)
	})

	await t.step('should return undefined for invalid code', () => {
		const retrieved = Lobby.getLobby('INVALID')
		assertEquals(retrieved, undefined)
	})

	await t.step('should not create duplicate lobby for host', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby1 = Lobby.getOrCreateLobby(host)
		const lobby2 = Lobby.getOrCreateLobby(host)
		assertEquals(lobby1, lobby2)
	})

	await t.step('should list all lobbies', () => {
		const hostSocket1 = getMockSocket()
		const host1: Client = new Client(hostSocket1)
		host1.setConnected('host1')

		const hostSocket2 = getMockSocket()
		const host2: Client = new Client(hostSocket2)
		host2.setConnected('host2')

		const lobby1 = Lobby.getOrCreateLobby(host1)
		const lobby2 = Lobby.getOrCreateLobby(host2)

		const lobbies = Lobby.getLobbies()
		assertTrue(lobbies.includes(lobby1))
		assertTrue(lobbies.includes(lobby2))
	})
})

Deno.test('Lobby - Client Management', async (t) => {
	await t.step('should add clients up to max size', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		const lobby = Lobby.getOrCreateLobby(host)

		for (let i = 0; i < 7; i++) {
			const clientSocket = getMockSocket()
			const client: Client = new Client(clientSocket)
			client.setConnected(`user${i}`)
			lobby.addClient(client)
		}

		assertEquals(lobby.getClients().length, 8)
	})

	await t.step('should reject clients when full', async () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		const lobby = Lobby.getOrCreateLobby(host)

		for (let i = 0; i < 7; i++) {
			const clientSocket = getMockSocket()
			const client: Client = new Client(clientSocket)
			client.setConnected(`user${i}`)
			lobby.addClient(client)
		}

		const extraSocket = getMockSocket()
		const extraClient: Client = new Client(extraSocket)
		extraClient.setConnected('extraUser')
		lobby.addClient(extraClient)

		const messages = await extraSocket.toArray()
		assertAction(messages[messages.length - 1], 'error')
	})

	await t.step('should force join clients when specified', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		const lobby = Lobby.getOrCreateLobby(host)

		for (let i = 0; i < 7; i++) {
			const clientSocket = getMockSocket()
			const client: Client = new Client(clientSocket)
			client.setConnected(`user${i}`)
			lobby.addClient(client)
		}

		const extraSocket = getMockSocket()
		const extraClient: Client = new Client(extraSocket)
		extraClient.setConnected('extraUser')
		lobby.addClient(extraClient, true)

		assertTrue(lobby.getClients().includes(extraClient))
	})

	await t.step('should reject unconnected clients', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		const lobby = Lobby.getOrCreateLobby(host)

		const clientSocket = getMockSocket()
		const client: Client = new Client(clientSocket)

		try {
			lobby.addClient(client as ConnectedClient)
			assertTrue(false)
		} catch (e) {
			assertTrue(e instanceof Error)
			assertEquals(
				(e as Error).message,
				'Client must be connected to join lobby',
			)
		}
	})
})

Deno.test('Lobby - State Management', async (t) => {
	await t.step('should manage playing state', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		const lobby = Lobby.getOrCreateLobby(host)

		assertTrue(!lobby.isPlaying())
		lobby.setPlaying(true)
		assertTrue(lobby.isPlaying())
		lobby.setPlaying(false)
		assertTrue(!lobby.isPlaying())
	})
})

Deno.test('Lobby - Host Management', async (t) => {
	await t.step('should handle host migration on leave', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const clientSocket = getMockSocket()
		const client: Client = new Client(clientSocket)
		client.setConnected('clientUser')

		const lobby = Lobby.getOrCreateLobby(host)
		lobby.addClient(client)

		host.leaveLobby()
		assertEquals(lobby.getHost().getCode(), client.getCode())
	})

	await t.step('should close lobby when last client leaves', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const lobby = Lobby.getOrCreateLobby(host)
		const code = lobby.getCode()

		host.leaveLobby()
		assertEquals(Lobby.getLobby(code), undefined)
	})
})

Deno.test('Lobby - Broadcasting', async (t) => {
	await t.step('should broadcast messages to all clients', async () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')

		const clientSocket = getMockSocket()
		const client: Client = new Client(clientSocket)
		client.setConnected('clientUser')

		const lobby = Lobby.getOrCreateLobby(host)
		lobby.addClient(client)

		await lobby.broadcast('test message')

		const hostMessages = await hostSocket.toArray()
		const clientMessages = await clientSocket.toArray()

		assertTrue(hostMessages[hostMessages.length - 1].includes('test message'))
		assertTrue(
			clientMessages[clientMessages.length - 1].includes('test message'),
		)
	})
})

Deno.test('Lobby - Relaying', async (t) => {
	await t.step('should relay messages to specific clients', async () => {
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

		lobby.addClient(client2)

		lobby.sendTo(
			client.getCode(),
			parseMessage(
				`action:score,to:${client.getCode()},from:${client2.getCode()},score:123`,
			) as ToMessage,
		)

		const clientMessages = await clientSocket.toArray()
		const lastClientMessage = clientMessages[clientMessages.length - 1]

		assertAction(lastClientMessage, 'score')

		const hostMessages = await hostSocket.toArray()
		assertEquals(hostMessages[hostMessages.length - 1], undefined)
	})
})
