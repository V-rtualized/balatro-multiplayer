import express from 'express'
import cors from 'cors'
import bodyParser from 'body-parser'
import ws from 'express-ws'
import { v4 as uuidv4 } from 'uuid'

const app = express()
const PORT = 8080

const clients = new Map();
const rooms = new Map();

const { getWss } = ws(app)

app.use(cors())
app.use(bodyParser.json())

const sendToClient = (ws, data) => {
  ws.send(JSON.stringify(data));
};

const generateRoomCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < 5; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

const handleRoomJoinOrCreate = (client, roomCode = null) => {
  let room;
  if (roomCode) {
      room = rooms.get(roomCode);
      if (room && room.clients.length < 2) {
          room.clients.push(client.id);
      } else {
          sendToClient(client.ws, { error: 'Room is full or does not exist.' });
          return;
      }
  } else {
      roomCode = generateRoomCode();
      while (rooms.has(roomCode)) {
          roomCode = generateRoomCode();
      }
      room = { clients: [client.id], scores: {}, lives: {} };
      rooms.set(roomCode, room);
  }

  client.roomCode = roomCode;
  room.scores[client.id] = 0;
  room.lives[client.id] = 3;

  sendToClient(client.ws, { action: 'roomJoined', roomCode, room });
};

const wsOnMessage = (ws) => {
  ws.on('message', async (msg) => {
    let message;
    try {
      message = JSON.parse(msg);
    } catch (err) {
      sendToClient(ws, { error: 'Bad Request' })
      return
    }
      const action = message.action;
      const username = message.username;
      const roomCode = message.roomCode;

      if (!clients.has(ws) && action === 'register') {
        if (username) {
          const id = uuidv4()
          clients.set(id, { username, ws });
          sendToClient(ws, { action: 'registered', username, id });
          return
        } else {
          sendToClient(ws, { error: 'Username is required' });
          return
        }
      }

      const client = clients.get(ws);
      if (action === 'createRoom') {
        handleRoomJoinOrCreate(client);
        return
      }

      if (action === 'joinRoom') {
        if (roomCode) {
          handleRoomJoinOrCreate(client, roomCode);
          return
        } else {
          sendToClient(ws, { error: 'Room code is required' });
          return
        }
      }
  })
}

const wsOnClose = (ws) => {
  const client = clients.get(ws);
  if (client?.roomCode) {
    const room = rooms.get(client.roomCode);
    if (room) {
      room.clients = room.clients.filter(username => username !== client.username);
      if (room.clients.length === 0) {
        rooms.delete(client.roomCode);
      }
    }
  }
  clients.delete(ws);
}

app.ws('/', wsOnMessage)

getWss().addListener('connection', () => {
  console.log('Client connected!')
})

getWss().addListener('close', wsOnClose)

app.get('/*', (req, res) => {
  res.status(404).send()
})
app.post('/*', (req, res) => {
  res.status(404).send()
})

app.listen(PORT, '0.0.0.0', (error) => {
  if (!error) {
    console.log('Server started!')
  } else {
    console.error(error)
  }
})