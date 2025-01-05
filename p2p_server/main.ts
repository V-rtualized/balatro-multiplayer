import net from "node:net";
import { ActionMessage, ParsedMessage } from "./types.ts";
import { Client, ConnectedClient } from "./state_manager.ts";
import ActionHandler from "./action_handler.ts";

const PORT = 8788

const parseMessage = (message: string): ParsedMessage => {
  const parts = message.split(",");
  const data: Record<string, string> = {};
  for (const part of parts) {
    const [key, value] = part.split(":");
    data[key] = value;
  }
  return data;
};

const assertClientConnected = (client: Client): client is ConnectedClient  => {
  if (!client.isConnected()) {
    client.send("action:error,message:Not finished connecting to the server");
    return false
  }
  return true
}

const handleClientMessage = async (socket: net.Socket, data: string) => {
  const messages = data.toString().split("\n").filter((msg) => msg.length > 0);

  for (const message of messages) {
    const client = Client.getClientFromSocket(socket);
    if (!client) {
      console.log("Warning: Message received from unknown client");
      continue;
    }

    console.log(`[Received] [${client.getCode()}]: ${message}`);

    const parsedMessage = parseMessage(message);

    if (typeof parsedMessage.action !== "string") {
      await client.send("action:error,message:Message missing action");
      continue;
    }

    const actionMessage = parsedMessage as ActionMessage;

    switch (actionMessage.action) {
      case "keepAlive":
        await client.send("action:keepAlive_ack");
        break;
      case "connect":
        ActionHandler.connect(client, actionMessage);
        break;
      case "openLobby":
        if (assertClientConnected(client)) ActionHandler.openLobby(client);
        break;
      case "joinLobby":
        if (assertClientConnected(client)) ActionHandler.joinLobby(client, actionMessage);
        break;
      default:
        ActionHandler.relay(client, actionMessage);
    }
  }
};

const server = net.createServer((socket) => {
  socket.setKeepAlive(true, 1000);
  socket.setNoDelay(true);

  new Client(socket);

  let buffer = "";

  socket.on("data", (data) => {
    buffer += data.toString();

    const messages = buffer.split("\n");
    buffer = messages.pop() ?? "";

    if (messages.length > 0) {
      handleClientMessage(socket, messages.join("\n"));
    }
  });

  socket.on("end", () => {
    Client.getClientFromSocket(socket)?.delete()
  });

  socket.on("error", (err) => {
    const client = Client.getClientFromSocket(socket)
    if (!client) {
      console.error(`[Error]: ${err.message}`);
      return;
    }
    console.error(`[Error] [${client.getCode()}]: ${err.message}`);
    client.delete()
  })
})

if (import.meta.main) {
  server.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  })
}
