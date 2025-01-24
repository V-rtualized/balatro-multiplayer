import { assertEquals, assertNotEquals } from "jsr:@std/assert";
import { Client, serializeMessage } from "./state_manager.ts";
import { Socket, ActionMessage } from "./types.ts";
import ActionHandler from "./action_handler.ts";
import { parseMessage } from "./main.ts";

class MockSocket implements Partial<Socket> {
  public writtenData: string[] = [];

  write(data: string, callback?: ((err?: Error) => void) | string): boolean {
    this.writtenData.push(data);
    if (typeof callback !== "string") callback?.();
    return true;
  }

  async toArray(): Promise<string[]> {
    return await this.writtenData
  }

  uncork(): void {
    
  }
}

const getMockSocket = (): Socket => {
  return new MockSocket() as unknown as Socket
}

Deno.test("Client - Basic Operations", async (t) => {
  await t.step("should generate unique codes", () => {
    const socket1 = getMockSocket();
    const socket2 = getMockSocket();
    const client1 = new Client(socket1);
    const client2 = new Client(socket2);

    assertNotEquals(client1.getCode(), client2.getCode());
    assertEquals(client1.getCode().length, 6);
    assertEquals(client2.getCode().length, 6);
  });

  await t.step("should handle client connect  ion state", () => {
    const socket = getMockSocket();
    const client: Client = new Client(socket);

    assertEquals(client._state, "connecting");
    client.setConnected("testUser");
    assertEquals(client._state, "connected");
    assertEquals(client.getUsername(), "testUser");
  });

  await t.step("should manage lobby state", () => {
    const socket = getMockSocket();
    const client: Client = new Client(socket);
    client.setConnected("testUser");

    assertEquals(client.getLobby(), null);
    client.setLobby("TEST123");
    assertEquals(client.getLobby(), "TEST123");
  });
});

Deno.test("ActionHandler - Message Handling", async (t) => {
  await t.step("should handle connect message", async () => {
    const socket = getMockSocket();
    const client = new Client(socket);
    const connectMessage = {
      action: "connect",
      username: "testUser",
    } as const;

    await ActionHandler.connect(client, connectMessage);
    const writtenData = await socket.toArray()
    const lastMessage = writtenData[writtenData.length - 1];
    
    assertEquals(client._state, "connected");
    assertEquals(client.getUsername(), "testUser");
    assertTrue(lastMessage.includes("action:connect_ack"));
  });

  await t.step("should reject invalid connect message", async () => {
    const socket = getMockSocket();
    const client = new Client(socket);
    const invalidMessage = {
      action: "connect",
      username: "",
    } as const;

    await ActionHandler.connect(client, invalidMessage);
    const writtenData = await socket.toArray()
    const lastMessage = writtenData[writtenData.length - 1];
    
    assertEquals(client._state, "connecting");
    assertTrue(lastMessage.includes("action:error"));
  });

  await t.step("should handle lobby creation", async () => {
    const socket = getMockSocket();
    const client: Client = new Client(socket);
    client.setConnected("testUser");

    await ActionHandler.openLobby(client);
    const writtenData = await socket.toArray()
    const lastMessage = writtenData[writtenData.length - 1];

    assertEquals(client.getLobby(), client.getCode());
    assertTrue(lastMessage.includes("action:openLobby_ack"));
  });
});

Deno.test("Message Handling", async (t) => {
  await t.step("should serialize action messages correctly", () => {
    const message: ActionMessage = {
      action: "connect",
      username: "testUser",
    };

    const serialized = serializeMessage(message);
    assertEquals(serialized, "action:connect,username:testUser");
  });

  await t.step("should parse messages correctly", () => {
    const messageStr = "action:connect,username:testUser";
    const parsed = parseMessage(messageStr);

    assertEquals(parsed.action, "connect");
    assertEquals(parsed.username, "testUser");
  });
});

Deno.test("Lobby Operations", async (t) => {
  await t.step("should handle joining lobby", async () => {
    const hostSocket = getMockSocket();
    const host: Client = new Client(hostSocket);
    host.setConnected("hostUser");
    await ActionHandler.openLobby(host);

    const clientSocket = getMockSocket();
    const client: Client = new Client(clientSocket);
    client.setConnected("joinUser");

    const joinMessage = {
      action: "joinLobby",
      code: host.getCode(),
    } as const;

    await ActionHandler.joinLobby(client, joinMessage);
    
    assertEquals(client.getLobby(), host.getCode());
    const hostWrittenData = await hostSocket.toArray()
    const lastHostMessage = hostWrittenData[hostWrittenData.length - 1];
    const clientWrittenData = await clientSocket.toArray()
    const lastClientMessage = clientWrittenData[clientWrittenData.length - 1];

    assertTrue(lastHostMessage.includes("action:joinLobby") && lastHostMessage.includes(host.getCode()));
    assertTrue(lastClientMessage.includes("action:joinLobby_ack"));
  });

  await t.step("should reject joining non-existent lobby", async () => {
    const socket = getMockSocket();
    const client: Client = new Client(socket);
    client.setConnected("testUser");

    const joinMessage = {
      action: "joinLobby",
      code: "INVALID",
    } as const;

    await ActionHandler.joinLobby(client, joinMessage);
    const writtenData = await socket.toArray()
    const lastMessage = writtenData[writtenData.length - 1];
    
    assertEquals(client.getLobby(), null);
    assertTrue(lastMessage.includes("action:error"));
    assertTrue(lastMessage.includes("Lobby not found"));
  });
});

function assertTrue(condition: boolean) {
  assertEquals(condition, true);
}