/** Credit to Henrik Ilgen (https://stackoverflow.com/a/6081639) */
Utils.serialize_table = (
	val: AnyTable,
	name: string,
	skipNewLines: boolean,
	depth: number,
) => {
	// biome-ignore lint/style/noParameterAssign:
	skipNewLines = skipNewLines || false
	// biome-ignore lint/style/noParameterAssign:
	depth = depth || 0

	let tmp = ' '.repeat(depth)

	if (name) {
		tmp = `${tmp}${name} = `
	}

	if (type(val) === 'table') {
		tmp = `${tmp}{${!skipNewLines ? '\n' : ''}`

		for (const [k, v] of pairs(val)) {
			tmp =
				// biome-ignore lint/style/useTemplate:
				tmp +
				Utils.serialize_table(v, k, skipNewLines, depth + 1) +
				',' +
				(!skipNewLines ? '\n' : '')
		}

		tmp = `${tmp}${' '.repeat(depth)}}`
	} else if (type(val) === 'number') {
		tmp = tmp + tostring(val)
	} else if (type(val) === 'string') {
		tmp = `${tmp}${string.format('%q', val)}`
	} else if (type(val) === 'boolean') {
		tmp = tmp + (val ? 'true' : 'false')
	} else {
		tmp = `${tmp}"[inserializeable datatype:${type(val)}]"`
	}

	return tmp
}
