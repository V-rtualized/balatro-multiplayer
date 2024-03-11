import { v4 as uuidv4 } from 'uuid'

class Client {
  constructor(send) {
    this.id = uuidv4()
    this.lobby = null
    this.username = 'Guest'
    this.send = send
  }

  setUsername = (username) => {
    this.username = username
    this.lobby?.broadcast()
  }

  setLobby = (lobby) => {
    this.lobby = lobby
  }
}

export default Client