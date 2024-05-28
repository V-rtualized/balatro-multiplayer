package main

import (
	"C"
	"sync"
)

type State struct {
	LobbyCode string
	Username  string
}

var (
	state   State
	stateMu sync.Mutex
)

//export luaEntryPoint
func luaEntryPoint() int {
	stateMu.Lock()
	defer stateMu.Unlock()
	state = State{
		LobbyCode: "",
		Username:  "Player",
	}
	return 0
}

//export getLobbyCode
func getLobbyCode() *C.char {
	stateMu.Lock()
	defer stateMu.Unlock()
	return C.CString(state.LobbyCode)
}

//export getUsername
func getUsername() *C.char {
	stateMu.Lock()
	defer stateMu.Unlock()
	return C.CString(state.Username)
}

func main() {}
