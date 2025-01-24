import { Client, ConnectedClient } from './client.ts'
import { Lobby } from './lobby.ts'
import { ActionMessage, ConnectMessage, JoinLobbyMessage } from './types.ts'
import { serializeMessage } from './utils.ts'

const relayToHost = async (client: ConnectedClient, message: ActionMessage) => {
  const lobby = client.getCurrentLobby()
  if (!lobby) {
    await client.send('action:error,message:Not in a lobby')
    return
  }

  const host = lobby.getHost()
  if (!host) {
    await client.send('action:error,message:Lobby host not found')
    return
  }

  host.send(message, 'relay', client.getCode())
}

const broadcastToLobby = async (
  client: ConnectedClient,
  message: ActionMessage,
) => {
  const lobby = client.getCurrentLobby()
  if (!lobby) {
    await client.send('action:error,message:Not in a lobby')
    return
  }

	const message_str = serializeMessage(message)

  await lobby.broadcast(message_str, client)
}

const ActionHandler = {
  connect: async (client: Client, message: ConnectMessage) => {
    if (client.isConnected()) {
      await client.send('action:error,message:Already connected')
      return
    }

    if (typeof message.username !== 'string') {
      await client.send('action:error,message:Missing username')
      return
    }

    const username = message.username.trim().substring(0, 20)
    if (username.length === 0) {
      await client.send('action:error,message:Invalid username')
      return
    }

    client.setConnected(username)
    await client.send(`action:connect_ack,code:${client.getCode()}`)
  },

  relay: async (client: Client, message: ActionMessage) => {
    if (!client.isConnected()) {
      await client.send('action:error,message:Not connected')
      return
    }

    if (client.isHost()) {
      await broadcastToLobby(client as ConnectedClient, message)
      return
    }

    await relayToHost(client as ConnectedClient, message)
  },

  openLobby: async (client: Client) => {
    if (!client.isConnected()) {
      await client.send('action:error,message:Not connected')
      return
    }

    const connectedClient = client as ConnectedClient
    Lobby.getOrCreateLobby(connectedClient)
    
    await client.send('action:openLobby_ack')
  },

  joinLobby: async (client: Client, message: JoinLobbyMessage) => {
    if (!client.isConnected()) {
      await client.send('action:error,message:Not connected')
      return
    }

    const lobby = message.code
    if (typeof lobby !== 'string') {
      await client.send('action:error,message:Missing lobby code')
      return
    }

    const targetLobby = Lobby.getLobby(lobby)
    if (!targetLobby) {
      await client.send('action:error,message:Lobby not found')
      return
    }

    const connectedClient = client as ConnectedClient
    targetLobby.addClient(connectedClient)
    
    // Notify host about the new joiner
    const host = targetLobby.getHost()
    await host.send(`action:joinLobby,code:${lobby}`, 'notify', client.getCode())
    
    await client.send('action:joinLobby_ack')
  },

  leaveLobby: async (client: Client) => {
    if (!client.isConnected()) {
      await client.send('action:error,message:Not connected')
      return
    }

    const connectedClient = client as ConnectedClient
    const currentLobby = connectedClient.getCurrentLobby()
    
    if (!currentLobby) {
      await client.send('action:error,message:Not in a lobby')
      return
    }

    connectedClient.leaveLobby()
    await client.send('action:leaveLobby_ack')
  }
}

export default ActionHandler