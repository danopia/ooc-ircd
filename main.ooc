import Server

server := Server new(6667)

while (true) {
  server check()
}
