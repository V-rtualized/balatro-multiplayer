interface Console {
	// biome-ignore lint/suspicious/noExplicitAny:
	log(...data: any[]): void
}

// biome-ignore lint/style/noVar:
declare var console: Console

export type LuaClassFn = (this: any, ...args: any[]) => any
