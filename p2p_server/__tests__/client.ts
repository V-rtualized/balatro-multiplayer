import { assertEquals, assertNotEquals } from 'jsr:@std/assert'
import { Client } from '../src/client.ts'
import { assertTrue, getMockSocket } from './testing_utils.ts'
import { Lobby } from '../src/lobby.ts'

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
