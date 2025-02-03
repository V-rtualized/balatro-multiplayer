import { assertEquals } from 'jsr:@std/assert'
import { ParsedMessage, Socket } from '../src/types.ts'
import { parseMessage } from '../src/utils.ts'

class MockSocket implements Partial<Socket> {
	public writtenData: string[] = []

	write(data: string, callback?: ((err?: Error) => void) | string): boolean {
		this.writtenData.push(data)
		if (typeof callback !== 'string') callback?.()
		return true
	}

	async toArray(): Promise<string[]> {
		return await this.writtenData
	}

	uncork(): void {
	}
}

export const getMockSocket = (): Socket => {
	return new MockSocket() as unknown as Socket
}

export const assertTrue = (condition: boolean) => {
	assertEquals(condition, true)
}

export const assertAction = (
	message: string | ParsedMessage,
	action: string,
) => {
	if (typeof message === 'string') {
		message = parseMessage(message)
	}

	assertEquals(message?.action, action)
}
