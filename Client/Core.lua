--- STEAMODDED HEADER
--- MOD_NAME: Multiplayer
--- MOD_ID: VirtualizedMultiplayer
--- MOD_AUTHOR: [virtualized, TGMM]
--- MOD_DESCRIPTION: Allows players to compete with their friends!

----------------------------------------------
------------MOD CORE--------------------------

-- Credit to Nyoxide for this custom loader
local moduleCache = {}
local relativeModPath = "Mods/Multiplayer/"
local function customLoader(moduleName)
	local filename = moduleName:gsub("%.", "/") .. ".lua"
	if moduleCache[filename] then
		return moduleCache[filename]
	end

	local filePath = relativeModPath .. filename
	local fileContent = love.filesystem.read(filePath)
	if fileContent then
		local moduleFunc = assert(load(fileContent, "@" .. filePath))
		moduleCache[filename] = moduleFunc
		return moduleFunc
	end

	return "\nNo module found: " .. moduleName
end

function SMODS.INIT.VirtualizedMultiplayer()
	---@diagnostic disable-next-line: deprecated
	table.insert(package.loaders, 1, customLoader)
	
	G.MP = require("multipalyer-windows")
	G.MP.Init(relativeModPath)
end

function luaFunction()
  sendDebugMessage("Lua function called from Go")
	G.MP.setState("Lua has changed the state")
  local currentState = G.MP.getState()
  sendDebugMessage("Current state in Go is: " .. currentState)
end

----------------------------------------------
------------MOD CORE END----------------------
