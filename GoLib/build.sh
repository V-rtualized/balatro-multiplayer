env CGO_ENABLED=1 go build -buildmode=c-shared -o ./bin/multiplayer-linux.so main.go
env GOOS=windows GOARCH=386 CGO_ENABLED=1 CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc go build -buildmode=c-shared -o ./bin/multiplayer-windows.dll main.go