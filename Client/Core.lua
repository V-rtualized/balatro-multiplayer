--- STEAMODDED HEADER
--- MOD_NAME: Multiplayer
--- MOD_ID: VirtualizedMultiplayer
--- MOD_AUTHOR: [virtualized, TGMM]
--- MOD_DESCRIPTION: Allows players to compete with their friends!

----------------------------------------------
------------MOD CORE--------------------------

local modPath = ""
local baseDirectory = love.filesystem.getSourceBaseDirectory() .. "\\"

local function loadModule(path)
	sendDebugMessage(path)
	if path:sub(-1) == "/" then
		files = NFS.getDirectoryItemsInfo(path)
		for fileName = 1, #files do
			loadModule(path .. files[fileName].name)
		end
	else
		local module = assert(load(NFS.read(path), "@" .. path))
		module()
	end
end

function SMODS.INIT.VirtualizedMultiplayer()
	for modsIndex = 1, #SMODS.MODS do
		if SMODS.MODS[modsIndex].id == "VirtualizedMultiplayer" then
			modPath = SMODS.MODS[modsIndex].path
		end
	end

	loadModule(string.format("%sUI/", modPath))

	local osString = love.system.getOS()
	local extern = "multiplayer-windows.dll"
	if osString == "OS X" then
		extern = "multiplayer-darwin.dylib"
	elseif osString == "Linux" then
		extern = "multiplayer-linux.so"
	end

	local ffi = require("ffi")
	local goLib = ffi.load(baseDirectory .. extern)
	ffi.cdef([[
	int luaEntryPoint();
	const char* getLobbyCode();
	const char* getUsername();
	]])

	local response = goLib.luaEntryPoint()
	sendDebugMessage("luaEntryPoint() returned: " .. tostring(response))

	local lobbyCode = ffi.string(goLib.getLobbyCode())
	sendDebugMessage("getLobbyCode() returned: " .. lobbyCode)

	local username = ffi.string(goLib.getUsername())
	sendDebugMessage("getUsername() returned: " .. username)
end

----------------------------------------------
------------MOD CORE END----------------------
