import net from 'net'
import { v4 as uuidv4 } from 'uuid'

const PORT = 8080
const clients = new Map()
const rooms = new Map()

const generateRoomCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  let result = ''
  for (let i = 0; i < 5; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
};

const stringToJson = (str) => {
  const obj = {}
  str.split(',').forEach(part => {
      const [key, value] = part.split(':')
      obj[key] = value
  });
  return obj
}

const sendToClient = (socket, data) => {
  console.log('Responding with ' + data)
  if (!socket) return
  socket.write(data + '\n')
};

const authorize = (socket, username, clientId) => {
  if (username) {
    clients.get(clientId).username = username
    sendToClient(socket, `action:registered,username:${username}`)
  } else {
    sendToClient(socket, `action:error,message:Username is required`)
  }
}

const createLobby = (auth) => {
  const player = clients.get(auth)
  if (player) {
    let roomCode = generateRoomCode()
    while (rooms.has(roomCode)) {
        roomCode = generateRoomCode()
    }
    const room = { clients: [player.username], scores: {}, lives: {} }
    rooms.set(roomCode, room);
    sendToClient(player.ws, `action:joinedRoom,code:${roomCode}`)
  } else {
    sendToClient(player.ws, 'action:error,message:Client not found')
  }
}

const joinLobby = (auth, roomCode) => {
  const player = clients.get(auth)
  if (player) {
    const room = rooms.get(roomCode)
    if (room && room.clients.length < 2) {
      room.clients.push(player.id)
      sendToClient(player.ws, `action:joinedRoom,code:${roomCode}`)
    } else {
      sendToClient(player.ws, 'action:error,message:Room is full or does not exist.')
    }
  }
}

const clientLeaveRoom = (clientId) => {
  rooms.forEach(room => {
    if (room.clients.includes(clientId)) {
      return room.clients.filter(c => c.id !== clientId)
    }
    return room
  })
}

const server = net.createServer((socket) => {
  const clientId = uuidv4()
  const client = { id: clientId, socket }
  clients.set(clientId, client)
  console.log('Client connected')
  sendToClient(socket, `action:connected,id:${clientId}`)

  socket.on('data', (data) => {
    const messages = data.toString().split('\n')
    messages.forEach((msg) => {
      if (!msg) return
      console.log('Recieved message ' + msg)
      try {
        const message = stringToJson(msg)
        switch (message.action) {
          case 'authorize':
            authorize(socket, message.username, clientId)
            break
          case 'createLobby':
            createLobby(message.auth)
            break
          case 'joinLobby':
            joinLobby(message.auth, message.roomCode)
            break
        }
      } catch (error) {
        console.error('Failed to parse message', error)
        sendToClient(socket, `action:error,message:Failed to parse message`)
      }
    });
  });

  socket.on('end', () => {
    console.log('Client disconnected')
    clients.delete(clientId)
    clientLeaveRoom(clientId)
  });

  socket.on('error', (err) => {
    if (err.code === 'ECONNRESET') {
      console.warn('TCP connection reset by peer (client).')
    } else {
      console.error('An unexpected error occurred:', err)
    }
    clients.delete(clientId)
    clientLeaveRoom(clientId)
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on port ${PORT}`);
});