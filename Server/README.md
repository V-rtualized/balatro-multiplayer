# Server API Documentation

This server is written using good faith, there is no verification of data sent from the client, we have to assume there has been no tampering. That being said, it would be possible to maliciously manipulate other's games if you can impersonate another socket connection, though I am not sure how possible/easy this is. I would love to implement TLS but at this moment I don't think it is possible for me to add lua packages (such as an SSL package) without including the full source code. A security-based C module for the mod might be nessesary in the future.

For ease of parsing in lua, communications between the client and server are in CSV, where the "action" column is manditory with every socket message. The rest of the columns are action-specific. Columns do not need to be in any particular order.

## Actions

example_action_name: param1, param2?
- description of action
- param1: description of param1
- param2?: description of optional param2

### Server to Client

connected
- Client successfully connected

---

error: message
- An error, this should only be used when needed since it is very intrusive

---

joinedLobby: code
- Client should act as if in a lobby with given code
- code: 5 letter code acting as a lobby ID

---

lobbyInfo: host, guest?
- Gives clients info on the lobby state
- host: Lobby host's username
- guest?: Lobby guest's username

*This will obviously need reworking for 8 players but it is the simplest way of doing it for now

### Client to Server

username: username
- Set the client's username
- username: The value

---

createLobby
- Request to make a lobby and be given a code. Response should be a 'joinedLobby' action

---

joinLobby: code
- Request to join an existing lobby, by given code. Response should be a 'joinedLobby' action, or 'error' if the lobby cannot be joined
- code: 5 letter code acting as a lobby ID

---

leaveLobby
- Leave the joined lobby, this is also called on client connection destruction so it needs to be functional without providing a code

---

lobbyInfo
- Request for an accurate 'lobbyInfo' response, for the lobby the client is connected to