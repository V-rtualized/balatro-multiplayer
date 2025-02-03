import net from 'node:net'
import { ActionMessage, sendType, ToMessage } from './types.ts'
import { Client, ConnectedClient } from './client.ts'
import ActionHandler from './action_handler.ts'
import { parseMessage, sendTraceMessage } from './utils.ts'

const PORT = 6858

const assertClientConnected = (client: Client): client is ConnectedClient => {
	if (!client.isConnected()) {
		client.send(
			'action:error,message:Not finished connecting to the server',
			sendType.Error,
			'SERVER',
		)
		return false
	}
	return true
}

const handleClientMessage = async (client: Client, data: string) => {
	const messages = data.toString().split('\n').filter((msg) => msg.length > 0)

	for (const message of messages) {
		if (!client) {
			sendTraceMessage(
				sendType.Error,
				undefined,
				undefined,
				'Warning: Message received from unknown client',
			)
			continue
		}

		if (message !== 'action:keep_alive') {
			sendTraceMessage(sendType.Received, client.getCode(), undefined, message)
		}

		const parsedMessage = parseMessage(message)

		if (typeof parsedMessage.action !== 'string') {
			await client.send(
				'action:error,message:Message missing action',
				sendType.Error,
				'SERVER',
			)
			continue
		}

		if (
			typeof (parsedMessage.to) === 'string' &&
			typeof (parsedMessage.from) === 'string'
		) {
			const toMessage = parsedMessage as ToMessage
			ActionHandler.sendTo(client, toMessage, toMessage.to)
			return
		}

		const actionMessage = parsedMessage as ActionMessage

		switch (actionMessage.action) {
			case 'keep_alive':
				await client.send('action:keep_alive_ack', sendType.Ack, 'SERVER')
				break
			case 'connect':
				ActionHandler.connect(client, actionMessage)
				break
			case 'set_username':
				ActionHandler.setUsername(client, actionMessage)
				break
			case 'open_lobby':
				if (assertClientConnected(client)) ActionHandler.openLobby(client)
				break
			case 'join_lobby':
				if (assertClientConnected(client)) {
					ActionHandler.joinLobby(client, actionMessage)
				}
				break
			case 'leave_lobby':
				if (assertClientConnected(client)) {
					ActionHandler.leaveLobby(client)
				}
				break
			default:
				if (assertClientConnected(client)) {
					ActionHandler.broadcast(client, actionMessage)
				}
		}
	}
}

const server = net.createServer((socket) => {
	try {
			socket.setKeepAlive(true, 1000)
			socket.setNoDelay(true)

			const client = new Client(socket)
			let buffer = ''

			socket.on('data', (data) => {
					try {
							buffer += data.toString()

							const messages = buffer.split('\n')
							buffer = messages.pop() ?? ''

							if (messages.length > 0) {
									handleClientMessage(client, messages.join('\n'))
							}
					} catch (err) {
							const clientCode = client?.getCode() || 'Unknown'
							sendTraceMessage(sendType.Error, clientCode, undefined, `Data handling error: ${err.message}`)
							
							try {
									client?.delete()
							} catch (cleanupErr) {
									sendTraceMessage(sendType.Error, clientCode, undefined, `Cleanup error: ${cleanupErr.message}`)
							}
					}
			})

			socket.on('end', () => {
					try {
							client.delete()
					} catch (err) {
							sendTraceMessage(sendType.Error, client?.getCode() || 'Unknown', undefined, `End event error: ${err.message}`)
					}
			})

			socket.on('error', (err) => {
					try {
							if (!client) {
									sendTraceMessage(sendType.Error, 'Unknown', undefined, `Socket error: ${err.message}`)
									return
							}
							sendTraceMessage(sendType.Error, client.getCode(), undefined, `Socket error: ${err.message}`)
							client.delete()
					} catch (handlingErr) {
							sendTraceMessage(sendType.Error, 'Unknown', undefined, `Error handling error: ${handlingErr.message}`)
					}
			})
	} catch (err) {
			sendTraceMessage(sendType.Error, 'Unknown', undefined, `Server initialization error: ${err.message}`)
			
			try {
					socket.destroy()
			} catch (destroyErr) {
					sendTraceMessage(sendType.Error, 'Unknown', undefined, `Socket destroy error: ${destroyErr.message}`)
			}
	}
})

// Add error handling for the server itself
server.on('error', (err) => {
	sendTraceMessage(sendType.Error, 'Server', undefined, `Server error: ${err.message}`)
})

if (import.meta.main) {
	server.listen(PORT, () => {
		console.log(`Server listening on port ${PORT}`)
	})
}
