const net = require('net');

const TOTAL_CLIENTS = 10000; // Adjust based on your system's capability
const PORT = 8788;
const HOST = 'virtualized.dev'; // Change to your server's IP address if not local

let clients = 0
let latency = []

const responseToJson = (response) => {
  const jsonObj = {};
  response.split(',').forEach(part => {
    const [key, value] = part.split(':');
    jsonObj[key.trim()] = value?.trim();
  });
  return jsonObj;
}

const connectClient = (code) => {
  const socket = new net.Socket()
  let start
  
  socket.connect(PORT, HOST, () => {
    clients++
  });

  socket.on('data', (data) => {
    const dataJson = responseToJson(data.toString().trim())
    if (dataJson.action === 'connected') {
      socket.write('action:username,username:123\n')
    }
    if (dataJson.action === 'confirmed') {
      start = Date.now()
      if (!code) {
        socket.write('action:createLobby\n')
      } else {
        socket.write('action:joinLobby,code:' + code + '\n')
      }
    }
    if (dataJson.action === 'joinedLobby') {
      if (!code) {
        connectClient(dataJson.code)
      }
      if (start) {
        latency.push(Date.now() - start)
      }
      setTimeout(() => {
        socket.write('action:leaveLobby\n')
        setTimeout(() => {
          socket.end()
        }, 5000)
      }, 10000)
    }
    if (dataJson.action === 'error') {
      console.log(dataJson.message)
    }
  });

  socket.on('error', (err) => {
    console.error(`Client (${clients}) error: ${err.message}`);
    socket.destroy();
  });

  socket.on('close', () => {
    clients--;
    if (clients === 0) {
      console.log(`All clients have disconnected.`);
      console.log(`Failed clients: ${TOTAL_CLIENTS - latency.length}`)
      console.log(`First 10 latency:`);
      for (let i = 0; i < 10; i++) {
        console.log(`${latency.shift()}`);
      }
      console.log(`Last 10 latency:`);
      for (let i = 0; i < 10; i++) {
        console.log(`${latency.pop()}`);
      }
      console.log(`Average latency: ${latency.reduce((acc, curr, _, { length }) => acc + curr / length, 0)}`);
    }
  });
};

for (let i = 0; i < TOTAL_CLIENTS / 2; i++) {
  connectClient(null);
  if (i === TOTAL_CLIENTS / 2) console.log('Last initialized')
}

console.log(`All clients have connected.`);