function luaFunction()
  print("Lua function called from Go")
  setState("Lua has changed the state")
  local currentState = getState()
  print("Current state in Go is: " .. currentState)
end
