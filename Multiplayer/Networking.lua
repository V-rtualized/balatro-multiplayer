--- STEAMODDED HEADER
--- STEAMODDED SECONMDARY FILE

----------------------------------------------
------------MOD NETWORKING--------------------
local Lobby = require "Lobby"
local Utils = require "Utils"


Networking = {}

-- We assume this is happening at startup because Balatro uses luasteam already
--luasteam.init()

-- Callbacks require modifying the original game loop, this could be danergous or damaging
local gameUpdateRef = Game.update
function Game.update(arg_298_0, arg_298_1)
  G.STEAM.runCallbacks()
  sendDebugMessage(Utils.serialize_table(G.STEAM))

  gameUpdateRef(arg_298_0, arg_298_1)
end

function Networking.create_steam_lobby()
  --Steam.networkingSockets.createListenSocketP2P(0)
  Lobby.connected = true
  sendDebugMessage("Lobby: " .. Utils.serialize_table(Lobby))
end

---function G.STEAM.networkingSockets.onConnectionChanged(data)
  --sendDebugMessage("Connection: " .. Utils.serialize_table(data))
  --G.STEAM.networkingSockets.acceptConnection(data.connection)
--end

--function G.STEAM.networkingSockets.onAuthenticationStatus(data)
  --sendDebugMessage("Authentication: " .. Utils.serialize_table(data))
--end

return Networking

----------------------------------------------
------------MOD NETWORKING END----------------