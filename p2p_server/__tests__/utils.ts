import { assertEquals } from 'jsr:@std/assert'
import { ActionMessage } from '../src/types.ts'
import { serializeMessage, parseMessage } from '../src/utils.ts'

Deno.test('Message Handling', async (t) => {
  await t.step('should serialize action messages correctly', () => {
    const message: ActionMessage = {
      action: 'connect',
      username: 'testUser',
    }

    const serialized = serializeMessage(message)
    assertEquals(serialized, 'action:connect,username:testUser')
  })

  await t.step('should parse messages correctly', () => {
    const messageStr = 'action:connect,username:testUser'
    const parsed = parseMessage(messageStr)

    assertEquals(parsed.action, 'connect')
    assertEquals(parsed.username, 'testUser')
  })
})