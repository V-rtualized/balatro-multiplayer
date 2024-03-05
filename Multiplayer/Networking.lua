----------------------------------------------
------------MOD NETWORKING--------------------
local Steam = require "luasteam"
local Lobby = require "Lobby"
local Utils = require "Utils"

Networking = {}

-- We assume this is happening at startup because Balatro uses luasteam already
--luasteam.init()

function Networking.create_steam_lobby()
  Steam.networkingSockets.createListenSocketP2P(0)
  Lobby.connected = true
  sendDebugMessage("Lobby: " .. Utils.serialize_table(Lobby))
end

function Steam.networkingSockets.onConnectionChanged(data)
  sendDebugMessage("Connection: " .. Utils.serialize_table(data))
  Steam.networkingSockets.acceptConnection(data.connection)
end

function Steam.networkingSockets.onAuthenticationStatus(data)
  sendDebugMessage("Authentication: " .. Utils.serialize_table(data))
end

return Networking

----------------------------------------------
------------MOD NETWORKING END----------------