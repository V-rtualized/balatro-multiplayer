import net from "node:net";

export type Socket = net.Socket;

export type ClientSend = (
  message: string | ActionMessage,
  sendType?: string,
  from?: string,
) => Promise<void>;

export type ParsedMessage = {
  [key: string]: string;
};

export const MessageType = {
  keepAlive: [] as const,
  connect: ["username"] as const,
  openLobby: [] as const,
  joinLobby: ["code"] as const,
}

export type MessageWithKeys<T extends keyof typeof MessageType> = {
  action: T;
} & {
  [P in (typeof MessageType)[T][number]]: string;
};

export type KeepAliveMessage = MessageWithKeys<"keepAlive">;
export type ConnectMessage = MessageWithKeys<"connect">;
export type OpenLobbyMessage = MessageWithKeys<"openLobby">;
export type JoinLobbyMessage = MessageWithKeys<"joinLobby">;

export type ActionMessage =
  | KeepAliveMessage
  | ConnectMessage
  | OpenLobbyMessage
  | JoinLobbyMessage;

