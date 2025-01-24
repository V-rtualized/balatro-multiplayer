import { assertEquals } from 'jsr:@std/assert'
import { Client } from '../src/client.ts'
import { assertAction, assertTrue, getMockSocket } from './testing_utils.ts'
import ActionHandler from '../src/action_handler.ts'

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

    assertTrue(client.getCurrentLobby()?.getHost().getCode() === client.getCode())
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
      action: 'joinLobby',
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
      action: 'joinLobby',
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
      action: 'joinLobby',
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
      action: 'joinLobby',
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
    await ActionHandler.joinLobby(client, { action: 'joinLobby', code: host.getCode() })

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