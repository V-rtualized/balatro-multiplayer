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

export type BaseMessage = {
	id: string
	from: string
	action: string
}

export const MessageType = {
	keep_alive: [] as const,
	netaction_connect: ['username'] as const,
	netaction_connect_ack: ['username', 'code'] as const,
	netaction_set_username: ['username'] as const,
	netaction_set_username_ack: ['username'] as const,
	netaction_open_lobby: [] as const,
	netaction_open_lobby_ack: [] as const,
	netaction_join_lobby: ['code', 'checking'] as const,
	netaction_join_lobby_ack: ['code', 'players'] as const,
	netaction_player_joined: ['code', 'username'] as const,
	netaction_player_left: ['code'] as const,
	netaction_leave_lobby: [] as const,
	netaction_leave_lobby_ack: [] as const,
	netaction_host_migration: ['code'] as const,
	netaction_error: ['message'] as const,
}

export type MessageWithKeys<T extends keyof typeof MessageType> =
	& BaseMessage
	& {
		action: T
	}
	& {
		[P in (typeof MessageType)[T][number]]: string | object
	}

export type KeepAliveMessage = MessageWithKeys<'keep_alive'>
export type ConnectMessage = MessageWithKeys<'netaction_connect'>
export type ConnectAckMessage = MessageWithKeys<'netaction_connect_ack'>
export type SetUsernameMessage = MessageWithKeys<'netaction_set_username'>
export type SetUsernameAckMessage = MessageWithKeys<
	'netaction_set_username_ack'
>
export type OpenLobbyMessage = MessageWithKeys<'netaction_open_lobby'>
export type OpenLobbyAckMessage = MessageWithKeys<
	'netaction_open_lobby_ack'
>
export type JoinLobbyMessage = MessageWithKeys<'netaction_join_lobby'>
export type JoinLobbyAckMessage = MessageWithKeys<
	'netaction_join_lobby_ack'
>
export type PlayerJoinedMessage = MessageWithKeys<
	'netaction_player_joined'
>
export type PlayerLeftMessage = MessageWithKeys<'netaction_player_left'>
export type LeaveLobbyMessage = MessageWithKeys<'netaction_leave_lobby'>
export type LeaveLobbyAckMessage = MessageWithKeys<
	'netaction_leave_lobby_ack'
>
export type HostMigrationMessage = MessageWithKeys<
	'netaction_host_migration'
>
export type ErrorMessage = MessageWithKeys<'netaction_error'>

export type ToMessage = BaseMessage & {
	to: string
}

export type ActionMessage =
	& BaseMessage
	& (
		| KeepAliveMessage
		| ConnectMessage
		| ConnectAckMessage
		| SetUsernameMessage
		| SetUsernameAckMessage
		| OpenLobbyMessage
		| OpenLobbyAckMessage
		| JoinLobbyMessage
		| JoinLobbyAckMessage
		| PlayerJoinedMessage
		| PlayerLeftMessage
		| LeaveLobbyMessage
		| LeaveLobbyAckMessage
		| HostMigrationMessage
		| ErrorMessage
	)

export enum sendType {
	Sending = 'Sending',
	Broadcasting = 'Broadcasting',
	Direct = 'Direct',
	Ack = 'Ack',
	Error = 'Error',
	Received = 'Received',
}
