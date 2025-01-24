import { assertEquals, assertNotEquals } from 'jsr:@std/assert'
import { Client } from '../src/client.ts'
import { Lobby } from '../src/lobby.ts'
import { ActionMessage } from '../src/types.ts'
import ActionHandler from '../src/action_handler.ts'
import { parseMessage } from '../src/main.ts'
import { serializeMessage } from '../src/utils.ts'
import { getMockSocket } from './testing_utils.ts'

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

    assertEquals(client._state, 'connecting')
    client.setConnected('testUser')
    assertEquals(client._state, 'connected')
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

Deno.test('Lobby - Basic Operations', async (t) => {
  await t.step('should create and manage lobbies', () => {
    const hostSocket = getMockSocket()
    const host: Client = new Client(hostSocket)
    host.setConnected('hostUser')
    
    const lobby = Lobby.getOrCreateLobby(host)
    
    assertEquals(lobby.getHost().getCode(), host.getCode())
    assertEquals(lobby.getClients().length, 1)
    assertEquals(lobby.getState(), 'waiting')
  })

  await t.step('should handle client management', () => {
    const hostSocket = getMockSocket()
    const host: Client = new Client(hostSocket)
    host.setConnected('hostUser')
    
    const clientSocket = getMockSocket()
    const client: Client = new Client(clientSocket)
    client.setConnected('testUser')
    
    const lobby = Lobby.getOrCreateLobby(host)
    lobby.addClient(client)
    
    assertEquals(lobby.getClients().length, 2)
    assertTrue(lobby.getClients().includes(client))
  })

  await t.step('should handle host migration', () => {
    const hostSocket = getMockSocket()
    const host: Client = new Client(hostSocket)
    host.setConnected('hostUser')
    
    const clientSocket = getMockSocket()
    const client: Client = new Client(clientSocket)
    client.setConnected('testUser')
    
    const lobby = Lobby.getOrCreateLobby(host)
    lobby.addClient(client)
    
    host.leaveLobby()
    
    assertEquals(lobby.getHost().getCode(), client.getCode())
    assertEquals(lobby.getClients().length, 1)
  })
})

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

    assertEquals(client._state, 'connected')
    assertEquals(client.getUsername(), 'testUser')
    assertTrue(lastMessage.includes('action:connect_ack'))
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

    assertEquals(client._state, 'connecting')
    assertTrue(lastMessage.includes('action:error'))
  })

  await t.step('should handle lobby creation', async () => {
    const socket = getMockSocket()
    const client: Client = new Client(socket)
    client.setConnected('testUser')

    await ActionHandler.openLobby(client)
    const writtenData = await socket.toArray()
    const lastMessage = writtenData[writtenData.length - 1]

    assertTrue(client.getCurrentLobby()?.getHost().getCode() === client.getCode())
    assertTrue(lastMessage.includes('action:openLobby_ack'))
  })
})

Deno.test('Message Handling', async (t) => {
  await t.step('should serialize action messages correctly', () => {
    const message: ActionMessage = {
      action: 'connect',
      username: 'testUser',
    }

    const serialized = serializeMessage(message)
    assertEquals(serialized, 'action:connect,username:testUser')
  })

  await t.step('should parse messages correctly', () => {
    const messageStr = 'action:connect,username:testUser'
    const parsed = parseMessage(messageStr)

    assertEquals(parsed.action, 'connect')
    assertEquals(parsed.username, 'testUser')
  })
})

Deno.test('Lobby Operations', async (t) => {
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

    assertTrue(client.getCurrentLobby()?.getCode() === host.getCode())
    const hostWrittenData = await hostSocket.toArray()
    const lastHostMessage = hostWrittenData[hostWrittenData.length - 1]
    const clientWrittenData = await clientSocket.toArray()
    const lastClientMessage = clientWrittenData[clientWrittenData.length - 1]

    assertTrue(
      lastHostMessage.includes('action:joinLobby') &&
      lastHostMessage.includes(host.getCode())
    )
    assertTrue(lastClientMessage.includes('action:joinLobby_ack'))
  })

  await t.step('should reject joining non-existent lobby', async () => {
    const socket = getMockSocket()
    const client: Client = new Client(socket)
    client.setConnected('testUser')

    const joinMessage = {
      action: 'joinLobby',
      code: 'INVALID',
    } as const

    await ActionHandler.joinLobby(client, joinMessage)
    const writtenData = await socket.toArray()
    const lastMessage = writtenData[writtenData.length - 1]

    assertEquals(client.getCurrentLobby(), null)
    assertTrue(lastMessage.includes('action:error'))
    assertTrue(lastMessage.includes('Lobby not found'))
  })

  await t.step('should handle lobby leaving', async () => {
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
    await ActionHandler.leaveLobby(client)

    assertEquals(client.getCurrentLobby(), null)
    const writtenData = await clientSocket.toArray()
    const lastMessage = writtenData[writtenData.length - 1]
    assertTrue(lastMessage.includes('action:leaveLobby_ack'))
  })
})

function assertTrue(condition: boolean) {
  assertEquals(condition, true)
}