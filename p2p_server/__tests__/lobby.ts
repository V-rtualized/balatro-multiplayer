import { assertEquals } from 'jsr:@std/assert'
import { Client } from '../src/client.ts'
import { assertAction, assertTrue, getMockSocket } from './testing_utils.ts'
import { Lobby } from '../src/lobby.ts'
import ActionHandler from '../src/action_handler.ts'

Deno.test('Lobby - Basic Operations', async (t) => {
  await t.step('should create and manage lobbies', () => {
    const hostSocket = getMockSocket()
    const host: Client = new Client(hostSocket)
    host.setConnected('hostUser')
    
    const lobby = Lobby.getOrCreateLobby(host)
    
    assertEquals(lobby.getHost().getCode(), host.getCode())
    assertEquals(lobby.getClients().length, 1)
    assertTrue(!lobby.isPlaying())
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

    assertAction(lastHostMessage, 'joinLobby')
    assertTrue(
      lastHostMessage.includes(host.getCode())
    )
    assertAction(lastClientMessage, 'joinLobby_ack')
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
    assertAction(lastMessage, 'error')
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
    assertAction(lastMessage, 'leaveLobby_ack')
  })
})