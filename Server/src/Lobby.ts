import type Client from "./Client"

const Lobbies = new Map()

const generateUniqueLobbyCode = (): string => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  let result = ''
  for (let i = 0; i < 5; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return Lobbies.get(result) ? generateUniqueLobbyCode() : result
}

class Lobby {
  code: string;
  host: Client | null;
  guest: Client | null;

  constructor(host: Client) {
    do {
      this.code = generateUniqueLobbyCode()
    } while (Lobbies.get(this.code))
    Lobbies.set(this.code, this)
    this.host = host
    this.guest = null
    host.setLobby(this)
    host.send(`action:joinedLobby,code:${this.code}`)
  }

  static get = (code: string) => {
    return Lobbies.get(code)
  }

  leave = (client: Client) => {
    if (this.host?.id === client.id) {
      this.host = this.guest
      this.guest = null
    }
    if (this.guest?.id === client.id) {
      this.guest = null
    }
    client.setLobby(null)
    if (this.host === null) {
      Lobbies.delete(this.code)
    } else {
      this.broadcast()
    }
  }

  join = (client: Client) => {
    if (this.guest) {
      client.send('action:error,message:Lobby is full or does not exist.')
      return
    }
    this.guest = client
    client.setLobby(this)
    client.send(`action:joinedLobby,code:${this.code}`)
    this.broadcast()
  }

  broadcast = () => {
    if(!this.host) {
      return;
    }

    let message = `action:lobbyInfo,host:${this.host.username}`
    if (this.guest?.username) {
      message += `,guest:${this.guest.username}`
      this.guest.send(message)
    }
    this.host.send(message)
  }
}

export default Lobby