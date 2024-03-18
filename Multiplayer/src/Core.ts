import type { Thread } from 'love.thread'

/** Credit to Nyoxide for this custom loader */
const moduleCache: Record<string, () => unknown> = {}
const relativeModPath = 'Mods/Multiplayer/'
function customLoader(moduleName: string) {
	const fileName = `${string.gsub(moduleName, '%.', '/')[0]}.lua`

	if (moduleCache[fileName]) {
		return moduleCache[fileName]
	}

	const filePath = `${relativeModPath}${fileName}`
	const [fileContent] = love.filesystem.read(filePath)

	if (fileContent) {
		// biome-ignore lint/suspicious/noExplicitAny: The lua version also has this error
		const [unassertedModuleFunc] = load(fileContent as any, `@${filePath}`)
		const moduleFunc = assert(unassertedModuleFunc)

		if (!moduleFunc) {
			throw `Could not load module: ${moduleName}}`
		}

		moduleCache[fileName] = moduleFunc
		return moduleFunc
	}

	return `\nNo module found: ${moduleName}`
}

// biome-ignore lint/style/noVar: Global
declare var CONFIG: AnyTable
// biome-ignore lint/style/noVar: Global
declare var NETWORKING_THREAD: Thread

SMODS.INIT.VirtualizedMultiplayer = () => {
	// @ts-ignore
	// biome-ignore lint/suspicious/noExplicitAny: This is how the loader does it
	table.insert(globalThis.package.loaders, 1, customLoader as any)

	require('Items.Blind')
	require('Items.Deck')
	require('Lobby')
	require('Networking.Action_Handlers')
	require('Utils').get_username()
	require('UI.Lobby_UI')
	require('UI.Main_Menu')
	require('UI.Mod_Description').load_description_gui()
	require('UI.Game_UI')

	CONFIG = require('Config')
	NETWORKING_THREAD = love.thread.newThread(
		`${relativeModPath}Networking/Socket.lua`,
	)
	NETWORKING_THREAD.start(CONFIG.URL, CONFIG.PORT)
	G.MULTIPLAYER.connect()
}
