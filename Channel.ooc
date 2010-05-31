import structs/ArrayList

import Connection
import Server

Channel: class {
  server: Server
  name: String
  clients := ArrayList<Connection> new()

  init: func (=server, =name) {}

  add: func (client: Connection) {
    if (clients contains(client)) return
    
    clients add(client)
    
    sendToAll(":" + client nick + "!a@a JOIN " + name)
    
    client send(":home.danopia 332 " + client nick + " " + name + " :This server is written in ooc.")
    // client send(":home.danopia.net 333 " + client nick + " " + name + " zc00gii!zc00gii@Byte/1ntrusion/zc00gii 1275258273")
    
    names := ""
    for (member in clients)
      names += member nick + " "
    
    client send(":home.danopia.net 353 " + client nick + " = " + name + " :" + names)
    client send(":home.danopia.net 366 " + client nick + " " + name + " :End of /NAMES list.")
  }

  remove: func~noMesage (client: Connection) {
    if (!clients contains(client)) return
    
    sendToAll(":" + client nick + "!a@a PART " + name)
    clients remove(client)
  }

  remove: func (client: Connection, message: String) {
    if (!clients contains(client)) return
    
    sendToAll(":" + client nick + "!a@a PART " + name + " :" + message)
    clients remove(client)
  }
  
  sendToAll: func (packet: String) {
    for (client in clients)
      client send(packet)
  }
  
  sendToAllExcept: func (packet: String, butnot: Connection) {
    for (client in clients)
      if (client != butnot)
        client send(packet)
  }
}
