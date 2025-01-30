import { Client, ConnectedClient } from './client.ts'
import { ActionMessage, ErrorMessage, sendType, ToMessage } from './types.ts'

const LOBBY_MAX_SIZE = 8

const lobbies = new Map<string, Lobby>()

export class Lobby {
	private code: string
	private host: ConnectedClient
	private clients: Set<ConnectedClient>
	private state: 'waiting' | 'playing'

	static getLobby(code: string): Lobby | undefined {
		return lobbies.get(code)
	}

	static getOrCreateLobby(host: ConnectedClient): Lobby {
		const existingLobby = Array.from(lobbies.values()).find(
			(lobby) => lobby.getHost()?.getCode() === host.getCode(),
		)

		if (existingLobby) {
			return existingLobby
		}

		return new Lobby(host)
	}

	static getLobbies(): Lobby[] {
		return Array.from(lobbies.values())
	}

	constructor(host: ConnectedClient) {
		this.code = host.getCode()
		this.host = host
		this.clients = new Set([host])
		this.state = 'waiting'
		host.joinLobby(this)
		lobbies.set(this.code, this)
	}

	getCode(): string {
		return this.code
	}

	getHost(): ConnectedClient {
		return this.host
	}

	getClients(): ConnectedClient[] {
		return Array.from(this.clients)
	}

	isPlaying(): boolean {
		return this.state == 'playing'
	}

	setPlaying(playing: boolean) {
		this.state = playing ? 'playing' : 'waiting'
	}

	addClient(client: ConnectedClient, forceJoin: boolean = false) {
		if (!client.isConnected()) {
			throw new Error('Client must be connected to join lobby')
		}

		const currentLobby = client.getCurrentLobby()
		if (currentLobby && currentLobby !== this) {
			client.leaveLobby()
		}

		if (this.clients.size >= LOBBY_MAX_SIZE && !forceJoin) {
			const lobbyFullResponse: ErrorMessage = {
				action: 'error',
				message: '[ERROR] Attempted to join lobby that is full',
			}
			client.send(lobbyFullResponse, sendType.Error, 'SERVER')
		}

		this.clients.add(client)
		client.joinLobby(this)
	}

	removeClient(client: Client) {
		if (this.clients.has(client as ConnectedClient)) {
			this.clients.delete(client as ConnectedClient)

			if (client === this.host) {
				const remainingClients = Array.from(this.clients)
				if (remainingClients.length > 0) {
					this.host = remainingClients[0]
				} else {
					this.close()
				}
			}
		}
	}

	close() {
		for (const client of this.clients) {
			client.leaveLobby()
		}
		this.clients.clear()
		lobbies.delete(this.code)
	}

	broadcast(message: string | ActionMessage, sender?: Client) {
		const promises = Array.from(this.clients).map((client) =>
			client.send(message, sendType.Broadcasting, sender?.getCode())
		)
		return Promise.all(promises)
	}

	async sendTo(to: string, message: ToMessage) {
		const toClient = Client.getClientFromCode(to)

		if (!toClient || !toClient.isConnected()) {
			return
		}

		if (this.clients.has(toClient)) {
			await toClient.send(message, sendType.Direct, message.from)
		}
	}
}
