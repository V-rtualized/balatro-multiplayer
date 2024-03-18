import type ts from 'typescript'
import type * as tstl from 'typescript-to-lua'

const plugin: tstl.Plugin = {
	beforeEmit(
		program: ts.Program,
		options: tstl.CompilerOptions,
		emitHost: tstl.EmitHost,
		result: tstl.EmitFile[],
	) {
		// Add a header to the emitted files
		for (const file of result) {
			const fileSeparator = file.outputPath.includes('\\') ? '\\' : '/'
			const fileName = file.outputPath.split('.')[0].split(fileSeparator).pop()

			// Do not emit to a src folder, emit to root instead
			if (file.outputPath.includes('src')) {
				file.outputPath = file.outputPath
					.split(fileSeparator)
					.filter((part) => part !== 'src')
					.join(fileSeparator)
			}

			if (fileName?.toLowerCase().includes('core')) {
				// _G.package doesn't work the same as normal package
				file.code = file.code.replace('_G.package', 'package')

				file.code = [
					'--- STEAMODDED HEADER',
					'--- MOD_NAME: Multiplayer',
					'--- MOD_ID: VirtualizedMultiplayer',
					'--- MOD_AUTHOR: [virtualized, TGMM]',
					'--- MOD_DESCRIPTION: Allows players to compete with their friends! Contact @virtualized on discord for mod assistance.',
					'',
					'----------------------------------------------',
					'------------MOD CORE--------------------------',
					'',
					file.code,
					'----------------------------------------------',
					'------------MOD CORE END----------------------',
				].join('\n')
			} else {
				file.code = `-- Comment added by beforeEmit plugin\n${file.code}`
			}
		}
	},
	moduleResolution(
		moduleIdentifier: string,
		requiringFile: string,
		options: tstl.CompilerOptions,
		emitHost: tstl.EmitHost,
	) {
		const req = requiringFile.toLowerCase()

		// Resolve all files as root
		if (req.includes('multiplayer')) {
			return `../${moduleIdentifier.replace('.', '/')}`
		}
	},
}

export default plugin
