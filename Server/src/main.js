import net from 'net'
import Client from './Client.js'
import Lobby from './Lobby.js'

const PORT = 8080

const stringToJson = (str) => {
  const obj = {}
  str.split(',').forEach(part => {
    const [key, value] = part.split(':')
    obj[key] = value
  })
  return obj
}

const sendToSocket = (socket) => (data) => {
  //console.log('Responding with ' + data)
  if (!socket) {
    //console.log('Socket is undefined')
    return
  }
  socket.write(data + '\n')
}

const usernameAction = (client, username) => {
  client.setUsername(username)
}

const createLobbyAction = (client) => {
  new Lobby(client)
}

const joinLobbyAction = (client, code) => {
  const newLobby = Lobby.get(code)
  if (!newLobby) {
    client.send('action:error,message:Room is full or does not exist.')
    return
  }
  newLobby.join(client)
}

const leaveLobbyAction = (client) => {
  client.lobby?.leave(client)
}

const lobbyInfoAction = (client) => {
  client.lobby?.broadcast()
}

const server = net.createServer((socket) => {
  const client = new Client(sendToSocket(socket))
  //console.log('Client connected')
  client.send(`action:connected`)

  socket.on('data', (data) => {
    const messages = data.toString().split('\n')
    messages.forEach((msg) => {
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
        client.send(socket, `action:error,message:Failed to parse message`)
      }
    })
  })

  socket.on('end', () => {
    //console.log('Client disconnected')
    leaveLobbyAction(client)
  })

  socket.on('error', (err) => {
    if (err.code === 'ECONNRESET') {
      console.warn('TCP connection reset by peer (client).')
    } else {
      console.error('An unexpected error occurred:', err)
    }
    leaveLobbyAction(client)
  })
})

server.listen(PORT, '0.0.0.0', () => {
  //console.log(`Server listening on port ${PORT}`);
})