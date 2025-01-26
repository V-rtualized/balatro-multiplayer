import crypto from 'node:crypto'
import { ActionMessage, ParsedMessage, sendType, ToMessage } from './types.ts'
import { Lobby } from './lobby.ts'

export const generateUniqueCode = (): string => {
	let code
	do {
		code = crypto.randomBytes(3).toString('hex').toUpperCase()
	} while (Lobby.getLobby(code) && code !== 'SERVER')
	return code
}

export const serializeMessage = (
	message: ActionMessage | ToMessage,
): string => {
	const message_parts = Object.entries(message).map(([key, value]) =>
		`${key.toString().replaceAll(',', '')}:${
			value.toString().replaceAll(',', '')
		}`
	)
	return message_parts.join(',')
}

export const parseMessage = (message: string): ParsedMessage => {
	const parts = message.split(',')
	const data: Record<string, string> = {}
	for (const part of parts) {
		const [key, value] = part.split(':')
		data[key.trim()] = value.trim()
	}
	return data
}

export const sendTraceMessage = (sendType: sendType | undefined, from: string = "SERVER", to: string = "SERVER", message: string) => {
	const safeSendType = sendType ?? 'Sending'
	const paddedSendType = safeSendType.padEnd(10)
	console.log(
		`${
			new Date().toISOString()
		} :: ${paddedSendType} :: ${from}->${to} :: ${message.trim()}`,
	)
}