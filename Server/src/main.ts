import net from 'node:net'
import Client from './Client.js'
import Lobby from './Lobby.js'

const PORT = 8080

// biome-ignore lint/suspicious/noExplicitAny: Object is parsed from string
const stringToJson = (str: string): any => {
  // biome-ignore lint/suspicious/noExplicitAny: Object is parsed from string
  const obj: any = {}
  for(const part of str.split(',')) {
    const [key, value] = part.split(':')
    obj[key] = value
  }
  return obj
}

const sendToSocket = (socket: net.Socket) => (data: string) => {
  //console.log('Responding with ' + data)
  if (!socket) {
    //console.log('Socket is undefined')
    return
  }
  socket.write(`${data}\n`)
}

const usernameAction = (client: Client, username: string) => {
  client.setUsername(username)
}

const createLobbyAction = (client: Client) => {
  new Lobby(client)
}

const joinLobbyAction = (client: Client, code: string) => {
  const newLobby = Lobby.get(code)
  if (!newLobby) {
    client.send('action:error,message:Lobby is full or does not exist.')
    return
  }
  newLobby.join(client)
}

const leaveLobbyAction = (client: Client) => {
  client.lobby?.leave(client)
}

const lobbyInfoAction = (client: Client) => {
  client.lobby?.broadcast()
}

const server = net.createServer((socket) => {
  const client = new Client(sendToSocket(socket))
  //console.log('Client connected')
  client.send("action:connected")

  socket.on('data', (data) => {
    const messages = data.toString().split('\n')

    for(const msg of messages) {
      if (!msg) return
      //console.log('Recieved message ' + msg)
      try {
        const message = stringToJson(msg)
        switch (message.action) {
          case 'username':
            usernameAction(client, message.username)
            break
          case 'createLobby':
            createLobbyAction(client)
            break
          case 'joinLobby':
            joinLobbyAction(client, message.code)
            break
          case 'leaveLobby':
            leaveLobbyAction(client)
            break
          case 'lobbyInfo':
            lobbyInfoAction(client)
            break
        }
      } catch (error) {
        console.error('Failed to parse message', error)
        client.send("action:error,message:Failed to parse message")
      }
    }
  })

  socket.on('end', () => {
    //console.log('Client disconnected')
    leaveLobbyAction(client)
  })

  socket.on('error', (err: Error & {
    errno: number,
    code: string,
    syscall: string
  }) => {
    if (err.code === 'ECONNRESET') {
      console.warn('TCP connection reset by peer (client).')
    } else {
      console.error('An unexpected error occurred:', err)
    }
    leaveLobbyAction(client)
  })
})

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on port ${PORT}`);
})