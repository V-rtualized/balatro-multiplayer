MP.send = {}

function MP.send.raw(msg)
	MP.networking.uiToNetworkChannel:push(msg)
end

function MP.send.joinLobby(code)
	MP.send.raw("action:joinLobby,code:" .. code)
end
