import { Socket } from '../src/types.ts'

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