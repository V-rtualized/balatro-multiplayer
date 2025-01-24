import crypto from 'node:crypto'
import { ActionMessage, ClientSend, Socket } from "./types.ts"

const clients = new Map<Socket, Client>()
const codes = new Map<string, Socket>()

export const generateUniqueCode = (): string => {
  let code;
  do {
    code = crypto.randomBytes(3).toString("hex").toUpperCase();
  } while (codes.has(code));
  return code;
}

export const serializeMessage = (message: ActionMessage): string => {
  const message_parts = Object.entries(message).map(([key, value]) => `${key}:${value}`)
  return message_parts.join(",")
}

const sendMessage = (socket: Socket, code: string): ClientSend => (message, sendType, from) => {
  return new Promise<void>((resolve, reject) => {
    if (typeof message !== "string") {
      message = serializeMessage(message);
    }

    if (!message.endsWith("\n")) {
      message += "\n";
    }

    if (from) {
      console.log(`[${new Date().toISOString()}] [${sendType ?? "Sending"}] [${from}]->[${code}]: ${message}`);
    } else {
      console.log(`[${new Date().toISOString()}] [${sendType ?? "Sending"}] [${code}]: ${message}`);
    }

    socket.write(message, (err) => {
      if (err) {
        console.error("Error sending message:", err)
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
  _state: "connecting" | "connected"
  _username?: string
  _lobby?: string | null

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

  static getClientsInLobby(lobby: string) {
    return Array.from(clients.values()).filter((client: Client) => client.getLobby() === lobby)
  }

  constructor(socket: Socket) {
    this._code = generateUniqueCode()
    this.send = sendMessage(socket, this._code)
    this._state = "connecting"
    codes.set(this._code, socket)
    clients.set(socket, this)
  }

  getCode() {
    return this._code
  }

  setConnected(username: string): asserts this is ConnectedClient {
    this._state = "connected"
    this._username = username
    this._lobby = null
  }

  isConnected(): this is ConnectedClient {
    return this._state === "connected"
  }

  setUsername(username: string) {
    this._username = username
  }

  getUsername(): string | undefined {
    return this._username
  }

  setLobby(lobby: string | null) {
    this._lobby = lobby
  }

  getLobby(): string | null | undefined {
    return this._lobby
  }

  isHost(): this is ConnectedClient {
    return this._lobby === this._code
  }

  delete() {
    const socket = codes.get(this._code)
    if (socket) {
      clients.delete(socket)
      codes.delete(this._code)
    }
  }
}

export interface ConnectedClient extends Client {
  _state: "connected";
  _username: string;
  _lobby: string | null;
  getUsername(): string;
  getLobby(): string | null;
}
