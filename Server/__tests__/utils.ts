import { assertEquals, assertNotEquals } from 'jsr:@std/assert'
import { ActionMessage } from '../src/types.ts'
import {
	generateUniqueCode,
	parseMessage,
	serializeMessage,
} from '../src/utils.ts'
import { Lobby } from '../src/lobby.ts'
import { Client } from '../src/client.ts'
import { getMockSocket } from './testing_utils.ts'

Deno.test('Code Generation', async (t) => {
	await t.step('should generate unique codes', () => {
		const code1 = generateUniqueCode()
		const code2 = generateUniqueCode()

		assertEquals(code1.length, 6)
		assertEquals(code2.length, 6)
		assertEquals(code1.toUpperCase(), code1)
		assertEquals(code2.toUpperCase(), code2)
		assertNotEquals(code1, code2)
	})

	await t.step('should avoid existing lobby codes', () => {
		const hostSocket = getMockSocket()
		const host: Client = new Client(hostSocket)
		host.setConnected('hostUser')
		const lobby = Lobby.getOrCreateLobby(host)

		const newCode = generateUniqueCode()
		assertNotEquals(newCode, lobby.getCode())
	})
})

Deno.test('Message Serialization', async (t) => {
	await t.step('should serialize simple messages', () => {
		const message: ActionMessage = {
			action: 'connect',
			username: 'testUser',
		}
		assertEquals(serializeMessage(message), 'action:connect,username:testUser')
	})

	await t.step('should serialize messages with numbers', () => {
		const message = {
			action: 'score',
			points: 100,
		}
		assertEquals(
			serializeMessage(message as unknown as ActionMessage),
			'action:score,points:100',
		)
	})

	await t.step('should serialize messages with special characters', () => {
		const message = {
			action: 'chat',
			message: 'Hello, World!',
		}
		assertEquals(
			serializeMessage(message as unknown as ActionMessage),
			'action:chat,message:Hello World!',
		)
	})

	await t.step('should handle empty values', () => {
		const message = {
			action: 'update',
			data: '',
		}
		assertEquals(
			serializeMessage(message as unknown as ActionMessage),
			'action:update,data:',
		)
	})
})

Deno.test('Message Parsing', async (t) => {
	await t.step('should parse simple messages', () => {
		const messageStr = 'action:connect,username:testUser'
		const parsed = parseMessage(messageStr)
		assertEquals(parsed.action, 'connect')
		assertEquals(parsed.username, 'testUser')
	})

	await t.step('should parse messages with numbers', () => {
		const messageStr = 'action:score,points:100'
		const parsed = parseMessage(messageStr)
		assertEquals(parsed.action, 'score')
		assertEquals(parsed.points, '100')
	})

	await t.step('should parse messages with special characters', () => {
		const messageStr = 'action:chat,message:Hello World!'
		const parsed = parseMessage(messageStr)
		assertEquals(parsed.action, 'chat')
		assertEquals(parsed.message, 'Hello World!')
	})

	await t.step('should handle empty values', () => {
		const messageStr = 'action:update,data:'
		const parsed = parseMessage(messageStr)
		assertEquals(parsed.action, 'update')
		assertEquals(parsed.data, '')
	})

	await t.step('should handle whitespace', () => {
		const messageStr = 'action: connect , username: testUser '
		const parsed = parseMessage(messageStr)
		assertEquals(parsed.action, 'connect')
		assertEquals(parsed.username, 'testUser')
	})

	await t.step('should handle single key-value pair', () => {
		const messageStr = 'action:ping'
		const parsed = parseMessage(messageStr)
		assertEquals(parsed.action, 'ping')
	})
})
