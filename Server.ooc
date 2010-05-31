import net/berkeley // for select
import net/[StreamSocket, ServerSocket] // for the rest

import structs/ArrayList

import Connection
import Channel

solSocket: extern(SOL_SOCKET) Int
soReuseAddr: extern(SO_REUSEADDR) Int

__set: extern(FD_SET) func(fd: Int, fdset: FdSet*)
__isSet: extern(FD_ISSET) func(fd: Int, fdset: FdSet*) -> Bool
__clr: extern(FD_CLR) func(fd: Int, fdset: FdSet*)
__zero: extern(FD_ZERO) func(fdset: FdSet*)

Server: class {
  listener := ServerSocket new()
  conns := ArrayList<Connection> new()
  channels := ArrayList<Channel> new()
  
  init: func (port: Int) {
    setsockopt(listener descriptor, solSocket, soReuseAddr, 1 as Int*, Int size)
    listener bind(port)
    listener listen(5)
  }
  
  check: func {
    tv : TimeVal
    tv tv_sec = 5
    tv tv_usec = 0 // 1000 * 500
    
    read_fds: FdSet
    
    __zero(read_fds&)
    __set(listener descriptor, read_fds&)
    
    biggest := listener descriptor
    
    for (conn in conns) {
      __set(conn socket descriptor, read_fds&)
      
      if (biggest < conn socket descriptor)
        biggest = conn socket descriptor
    }
    
    select(biggest + 1, read_fds&, null as FdSet*, null as FdSet*, tv&)
    
    if (read_fds isSet(listener descriptor))
      conns add(Connection new(this, listener accept()))
    
    for (conn in conns)
      if (read_fds isSet(conn socket descriptor))
        conn handle()
  }
  
  findChannel: func (name: String) -> Channel {
    for (channel in channels)
      if (name toLower() == channel name toLower()) return channel
    
    return null
  }
}
