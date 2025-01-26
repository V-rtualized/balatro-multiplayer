import net from 'node:net'

export type Socket = net.Socket

export type ClientSend = (
	message: string | ActionMessage | ToMessage,
	type?: sendType,
	from?: string,
) => Promise<void>

export type ParsedMessage = {
	[key: string]: string
}

export const MessageType = {
	keep_alive: [] as const,
	connect: ['username'] as const,
	set_username: ['username'] as const,
	open_lobby: [] as const,
	join_lobby: ['code'] as const,
	error: ['message'] as const,
}

export type MessageWithKeys<T extends keyof typeof MessageType> =
	& {
		action: T
	}
	& {
		[P in (typeof MessageType)[T][number]]: string
	}

export type KeepAliveMessage = MessageWithKeys<'keep_alive'>
export type ConnectMessage = MessageWithKeys<'connect'>
export type SetUsernameMessage = MessageWithKeys<'set_username'>
export type OpenLobbyMessage = MessageWithKeys<'open_lobby'>
export type JoinLobbyMessage = MessageWithKeys<'join_lobby'>
export type ErrorMessage = MessageWithKeys<'error'>

export type ToMessage = {
	action: string
	to: string
	from: string
}

export type ActionMessage =
	| KeepAliveMessage
	| ConnectMessage
	| SetUsernameMessage
	| OpenLobbyMessage
	| JoinLobbyMessage
	| ErrorMessage

export enum sendType {
	Sending = 'Sending',
	Broadcasting = 'Broadcasting',
	Direct = 'Direct',
	Ack = 'Ack',
	Error = 'Error',
	Received = 'Received',
}
