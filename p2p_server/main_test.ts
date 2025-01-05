import { assertEquals, assertNotEquals } from "@std/assert";
import { Client, ConnectedClient } from "./state_manager.ts";
import { Socket, ActionMessage } from "./types.ts";
import ActionHandler from "./action_handler.ts";

// Mock Socket implementation
class MockSocket implements Partial<Socket> {
  private buffer = "";
  public writtenData: string[] = [];

  write(data: string, callback?: ((err?: Error) => void) | string): boolean {
    this.writtenData.push(data);
    if (typeof callback !== "string") callback?.();
    return true;
  }

  uncork(): void {}
}

// Test suite for Client class
Deno.test("Client - Basic Operations", async (t) => {
  await t.step("should generate unique codes", () => {
    const socket1 = new MockSocket();
    const socket2 = new MockSocket();
    const client1 = new Client(socket1 as unknown as Socket);
    const client2 = new Client(socket2 as unknown as Socket);

    assertNotEquals(client1.getCode(), client2.getCode());
    assertEquals(client1.getCode().length, 6);
    assertEquals(client2.getCode().length, 6);
  });

  await t.step("should handle client connect  ion state", () => {
    const socket = new MockSocket();
    const client = new Client(socket as unknown as Socket);

    assertEquals(client._state, "connecting");
    client.setConnected("testUser");
    assertEquals(client._state, "connected");
    assertEquals(client.getUsername(), "testUser");
  });

  await t.step("should manage lobby state", () => {
    const socket = new MockSocket();
    const client: Client = new Client(socket as unknown as Socket);
    client.setConnected("testUser");

    assertEquals(client.getLobby(), null);
    client.setLobby("TEST123");
    assertEquals(client.getLobby(), "TEST123");
  });
});

// Test suite for ActionHandler
Deno.test("ActionHandler - Message Handling", async (t) => {
  await t.step("should handle connect message", async () => {
    const socket = new MockSocket();
    const client = new Client(socket as Socket);
    const connectMessage = {
      action: "connect",
      username: "testUser",
    } as const;

    await ActionHandler.connect(client, connectMessage);
    const lastMessage = socket.writtenData[socket.writtenData.length - 1];
    
    assertEquals(client._state, "connected");
    assertEquals(client.getUsername(), "testUser");
    assertTrue(lastMessage.includes("action:connect_ack"));
  });

  await t.step("should reject invalid connect message", async () => {
    const socket = new MockSocket();
    const client = new Client(socket as Socket);
    const invalidMessage = {
      action: "connect",
      username: "",
    } as const;

    await ActionHandler.connect(client, invalidMessage);
    const lastMessage = socket.writtenData[socket.writtenData.length - 1];
    
    assertEquals(client._state, "connecting");
    assertTrue(lastMessage.includes("action:error"));
  });

  await t.step("should handle lobby creation", async () => {
    const socket = new MockSocket();
    const client = new Client(socket as Socket);
    client.setConnected("testUser");

    await ActionHandler.openLobby(client as ConnectedClient);
    const lastMessage = socket.writtenData[socket.writtenData.length - 1];

    assertEquals(client.getLobby(), client.getCode());
    assertTrue(lastMessage.includes("action:openLobby_ack"));
  });
});

// Test suite for message parsing and serialization
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

// Test suite for lobby operations
Deno.test("Lobby Operations", async (t) => {
  await t.step("should handle joining lobby", async () => {
    // Create host
    const hostSocket = new MockSocket();
    const host = new Client(hostSocket as Socket);
    host.setConnected("hostUser");
    await ActionHandler.openLobby(host as ConnectedClient);

    // Create joining client
    const clientSocket = new MockSocket();
    const client = new Client(clientSocket as Socket);
    client.setConnected("joinUser");

    const joinMessage = {
      action: "joinLobby",
      code: host.getCode(),
    } as const;

    await ActionHandler.joinLobby(client as ConnectedClient, joinMessage);
    
    assertEquals(client.getLobby(), host.getCode());
    const lastHostMessage = hostSocket.writtenData[hostSocket.writtenData.length - 1];
    const lastClientMessage = clientSocket.writtenData[clientSocket.writtenData.length - 1];
    
    assertTrue(lastHostMessage.includes("[Join]"));
    assertTrue(lastClientMessage.includes("action:joinLobby_ack"));
  });

  await t.step("should reject joining non-existent lobby", async () => {
    const socket = new MockSocket();
    const client = new Client(socket as Socket);
    client.setConnected("testUser");

    const joinMessage = {
      action: "joinLobby",
      code: "INVALID",
    } as const;

    await ActionHandler.joinLobby(client as ConnectedClient, joinMessage);
    const lastMessage = socket.writtenData[socket.writtenData.length - 1];
    
    assertEquals(client.getLobby(), null);
    assertTrue(lastMessage.includes("action:error"));
    assertTrue(lastMessage.includes("Lobby not found"));
  });
});

// Helper functions from your server code
function serializeMessage(message: ActionMessage): string {
  const message_str = "action:" + message.action;
  return message_str + Object.entries({ ...message, action: undefined })
    .filter(([_, value]) => value !== undefined)
    .map(([key, value]) => `${key}:${value}`)
    .join(",");
}

function parseMessage(message: string) {
  const parts = message.split(",");
  const data: Record<string, string> = {};
  for (const part of parts) {
    const [key, value] = part.split(":");
    data[key] = value;
  }
  return data;
}

function assertTrue(condition: boolean) {
  assertEquals(condition, true);
}