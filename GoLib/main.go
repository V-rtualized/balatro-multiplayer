package main

import (
	"fmt"
	lua "github.com/Shopify/go-lua"
	"sync"
)

// Global state variable
var state string
var mu sync.Mutex

func setState(L *lua.State) int {
	mu.Lock()
	defer mu.Unlock()
	state = lua.CheckString(L, 1)
	return 0
}

func getState(L *lua.State) int {
	mu.Lock()
	defer mu.Unlock()
	L.PushString(state)
	return 1
}

func main() {
	L := lua.NewState()
	lua.OpenLibraries(L)

	// Register Go functions in Lua
	L.Register("setState", setState)
	L.Register("getState", getState)

	// Load and execute the Lua script
	if err := lua.DoFile(L, "script.lua"); err != nil {
		fmt.Println("Error executing Lua script:", err)
	}

	// Call a Lua function from Go
	L.Global("luaFunction")
	L.Call(0, 0)
}