import { assertEquals } from 'jsr:@std/assert'
import { Client } from '../src/client.ts'
import { assertAction, assertTrue, getMockSocket } from './testing_utils.ts'
import ActionHandler from '../src/action_handler.ts'

Deno.test('ActionHandler - Message Handling', async (t) => {
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
})
