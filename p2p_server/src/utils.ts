import crypto from 'node:crypto'
import { ActionMessage } from './types.ts'
import { Lobby } from './lobby.ts'

export const generateUniqueCode = (): string => {
  let code
  do {
    code = crypto.randomBytes(3).toString('hex').toUpperCase()
  } while (Lobby.getLobby(code))
  return code
}

export const serializeMessage = (message: ActionMessage): string => {
  const message_parts = Object.entries(message).map(([key, value]) =>
    `${key}:${value}`
  )
  return message_parts.join(',')
}