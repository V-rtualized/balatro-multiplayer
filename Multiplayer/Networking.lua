--- STEAMODDED HEADER
--- STEAMODDED SECONDARY FILE

----------------------------------------------
------------MOD NETWORKING--------------------
local Lobby = require "Lobby"
local Config = require "Config"
local socket = require "socket"

Networking = {}

function string_to_table(str)
  local tbl = {}
  for key, value in string.gmatch(str, '([^,]+):([^,]+)') do
      tbl[key] = value
  end
  return tbl
end

local function action_connected(id)
  sendDebugMessage("Client connected to multiplayer server")
  Lobby.user_id = id
  Lobby.update_connection_status()
  Networking.Client:send('action:authorize,username:'..Lobby.username)
end

local function action_registered(username)
  sendDebugMessage("Registered username with server")
end

local function action_joinedRoom(code)
  sendDebugMessage("Joining room " .. code)
  Lobby.code = code
  Lobby.update_connection_status()
  Networking.room_info(code)
end

local function action_roomInfo(players)
  Lobby.players = {}
  local player_usernames = Utils.string_split(players, '.')
  for i = 1, #player_usernames do
    table.insert(Lobby.players, { username = player_usernames[i] })
  end
  Lobby.update_player_usernames()
end

local function action_error(message)
  sendDebugMessage(message)

  Utils.overlay_message(message)
end

local game_update_ref = Game.update
function Game.update(arg_298_0, arg_298_1)
  if Networking.Client then
    repeat
      local data, error, partial = Networking.Client:receive()
      if data then
        local t = string_to_table(data)

        sendDebugMessage('Client got ' .. t.action .. ' message')

        if t.action == 'connected' then
          action_connected(t.id)
        elseif t.action == 'registered' then
          action_registered(t.username)
        elseif t.action == 'joinedRoom' then
          action_joinedRoom(t.code)
        elseif t.action == 'roomInfo' then
          action_roomInfo(t.players)
        elseif t.action == 'error' then
          action_error(t.message)
        end
      end
    until not data
  end

  game_update_ref(arg_298_0, arg_298_1)
end

function Networking.authorize()
  Networking.Client = socket.tcp()
  Networking.Client:settimeout(0)
  Networking.Client:connect(Config.URL, Config.PORT) -- Not sure if I want to make these values public yet
end

function Networking.create_lobby()
  if not Lobby.user_id then
    sendDebugMessage("Tried to create lobby before client initialized")
    return
  end

  Networking.Client:send('action:createLobby,auth:' .. Lobby.user_id)
end

function Networking.join_lobby(roomCode)
  if not Lobby.user_id then
    sendDebugMessage("Tried to create lobby before client initialized")
    return
  end
  
  Networking.Client:send('action:joinLobby,auth:' .. Lobby.user_id .. ',roomCode:' .. roomCode)
end

function Networking.room_info(roomCode)
  if not Lobby.user_id then
    sendDebugMessage("Tried to get lobby info before client initialized")
    return
  end
  
  Networking.Client:send('action:lobbyInfo,auth:' .. Lobby.user_id .. ',roomCode:' .. roomCode)
end

function Networking.leave_lobby()
  if not Lobby.user_id then
    sendDebugMessage("Tried to get lobby info before client initialized")
    return
  end

  Networking.Client:send('action:leaveLobby,auth:' .. Lobby.user_id)
end

return Networking

----------------------------------------------
------------MOD NETWORKING END----------------