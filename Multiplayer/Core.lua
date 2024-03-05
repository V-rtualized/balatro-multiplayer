--- STEAMODDED HEADER
--- MOD_NAME: Multiplayer
--- MOD_ID: VirtualizedMultiplayer
--- MOD_AUTHOR: [virtualized]
--- MOD_DESCRIPTION: Allows players to compete with their friends! Contact @virtualized on discord for mod assistance.

----------------------------------------------
------------MOD CORE--------------------------

-- Credit to Nyoxide for this custom loader
local moduleCache = {}

local function customLoader(moduleName)
    local filename = moduleName:gsub("%.", "/") .. ".lua"
    if moduleCache[filename] then
        return moduleCache[filename]
    end

    local filePath = "Mods/Multiplayer/" .. filename
    sendDebugMessage("Virtualized: " .. filePath)
    local fileContent = love.filesystem.read(filePath)
    if fileContent then
        local moduleFunc = assert(load(fileContent, "@"..filePath))
        moduleCache[filename] = moduleFunc
        return moduleFunc
    end

    return "\nNo module found: " .. moduleName
end

function SMODS.INIT.VirtualizedMultiplayer()
    table.insert(package.loaders, 1, customLoader)
    require "Main_Menu"
end

----------------------------------------------
------------MOD CORE END----------------------