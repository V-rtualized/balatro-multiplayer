go build -o ./bin/multiplayer-windows-msvc.a -buildmode=c-archive main.go
cl /MD /c multiplayer-windows-msvc.c /Fobin\ /link ./bin/multiplayer-windows-msvc.a
cl /LD /MD /Fe"./bin/multiplayer-windows-msvc.dll" /Fo"./bin/multiplayer-windows-msvc.obj" multiplayer-windows-msvc.c /link /DEF:multiplayer-windows-msvc.def ./bin/multiplayer-windows-msvc.a