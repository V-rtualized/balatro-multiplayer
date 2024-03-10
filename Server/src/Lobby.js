const Lobbies = new Map()

const generateUniqueRoomCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  let result = ''
  for (let i = 0; i < 5; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return Lobbies.get(result) ? generateUniqueRoomCode() : result
}

class Lobby {
  constructor(host) {
    do {
      this.code = generateUniqueRoomCode()
    } while (Lobbies.get(this.code))
    Lobbies.set(this.code, this)
    this.host = host
    this.guest = null
    host.setLobby(this)
    host.send(`action:joinedLobby,code:${this.code}`)
  }

  static get = (code) => {
    return Lobbies.get(code)
  }

  leave = (client) => {
    if (this.host === client._id) {
      this.host = this.guest
      this.guest = null
    }
    if (this.guest === client._id) {
      this.guest = null
    }
    client.setLobby(null)
    if (this.host === null) {
      Lobbies.delete(this.code)
    } else {
      this.broadcast()
    }
  }

  join = (client) => {
    if (this.guest) {
      client.send('action:error,message:Room is full or does not exist.')
      return
    }
    this.guest = client
    client.setLobby(this)
    client.send(`action:joinedLobby,code:${this.code}`)
    this.broadcast()
  }

  broadcast = () => {
    let message = `action:lobbyInfo,host:${this.host.username}`
    if (this.guest?.username) {
      message += `,guest:${this.guest.username}`
      this.guest.send(message)
    }
    this.host.send(message)
  }
}

export default Lobby