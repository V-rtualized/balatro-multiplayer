import { Socket } from './types.ts'
import { generateUniqueCode, serializeMessage } from './utils.ts'
import { Lobby } from './lobby.ts'
import { ClientSend } from './types.ts'

const clients = new Map<Socket, Client>()
const codes = new Map<string, Socket>()

const sendMessage =
  (socket: Socket, code: string): ClientSend => (message, sendType, from) => {
    return new Promise<void>((resolve, reject) => {
      if (typeof message !== 'string') {
        message = serializeMessage(message)
      }
      if (!message.endsWith('\n')) {
        message += '\n'
      }
      if (from) {
        console.log(
          `[${new Date().toISOString()}] [${
            sendType ?? 'Sending'
          }] [${from}]->[${code}]: ${message}`,
        )
      } else {
        console.log(
          `[${new Date().toISOString()}] [${
            sendType ?? 'Sending'
          }] [${code}]: ${message}`,
        )
      }
      socket.write(message, (err) => {
        if (err) {
          console.error('Error sending message:', err)
          reject(err)
        } else {
          socket.uncork()
          resolve()
        }
      })
    })
  }

export class Client {
  _code: string
  _state: 'connecting' | 'connected'
  _username?: string
  _currentLobby?: Lobby | null
  send: ClientSend

  static getClientFromCode(code: string) {
    const socket = codes.get(code)
    if (socket) {
      return clients.get(socket)
    }
  }

  static getClientFromSocket(socket: Socket) {
    return clients.get(socket)
  }

  constructor(socket: Socket) {
    this._code = generateUniqueCode()
    this.send = sendMessage(socket, this._code)
    this._state = 'connecting'
    this._currentLobby = null
    codes.set(this._code, socket)
    clients.set(socket, this)
  }

  getCode() {
    return this._code
  }

  setConnected(username: string): asserts this is ConnectedClient {
    this._state = 'connected'
    this._username = username
  }

  isConnected(): this is ConnectedClient {
    return this._state === 'connected'
  }

  setUsername(username: string) {
    this._username = username
  }

  getUsername(): string | undefined {
    return this._username
  }

  joinLobby(lobby: Lobby) {
    this._currentLobby = lobby
  }

  leaveLobby() {
    if (this._currentLobby) {
      this._currentLobby.removeClient(this)
      this._currentLobby = null
    }
  }

  getCurrentLobby(): Lobby | null | undefined {
    return this._currentLobby
  }

  isHost(): boolean {
    return this._currentLobby?.getHost()?.getCode() === this._code
  }

  delete() {
    this.leaveLobby()
    const socket = codes.get(this._code)
    if (socket) {
      clients.delete(socket)
      codes.delete(this._code)
    }
  }
}

export interface ConnectedClient extends Client {
  _state: 'connected'
  _username: string
  _currentLobby: Lobby | null
  getUsername(): string
  getCurrentLobby(): Lobby | null
}