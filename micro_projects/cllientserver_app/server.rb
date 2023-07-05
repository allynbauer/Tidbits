# == Synopsis
#   A simple server that implements a simpletalk based protocol.
#   The server is multithreaded so it can accept multiple clients.
#   A mixin called Networkable keeps some generic functionality out of
#   this file, which is also shared by a Client class.
#
# == Flags
#   Server has no default command line flags - all of its configuration is
#   provided by settings.
#
# == Author
#   Allyn Bauer
#   29 September 2008
#   22 October 2008

class Server
  require 'socket'
  require 'networkable'
  include Networkable
  
  def initialize
    load_settings
    @server    = TCPServer.open(port)
    @sockets   = [@server]
    @log       = STDOUT
    @running   = true
    @processed = 0
    @commands  = %w(HELLO CLIENT_BYE)
  end
  
  def listen
    while @running
      ready = select(@sockets) # get active connections
      readable = ready[0]
      readable.each do |socket|
        if socket == @server
          client = @server.accept
          @sockets << client
          write_log "Accepted connection from #{client.peeraddr[2]}."
        else
          input = socket.gets
          if !input
            write_log "Client at #{socket.peeraddr[2]} disconnected."
            @sockets.delete(socket)
            socket.close
            next
          end
          process(socket, input)
        end
      end
    end
  end
  
  def write_log(msg)
    @log.puts "#{@processed += 1}@[#{Time.now}]: #{msg}"
  end
  
  def quit
    @running = false
    write_log "Server is shutting down."
  end
  
  # methods that support server commands
  def process_hello(id, name, socket)
    write_log "Received HELLO from #{socket.peeraddr[2]}."
    transmit_status(socket)
  end
  
  def process_client_bye(cookie, socket)
    write_log "Received CLIENT_BYE from #{socket.peeraddr[2]}."
    transmit_server_bye(socket)
  end
  
  def transmit_status(socket)
    write_log "Transmitting STATUS to #{socket.peeraddr[2]}."
    info = socket.peeraddr
    construct_transmit(socket, magic_string, "STATUS", rand(1_000), "#{info[3]}:#{info[1]}")
  end
  
  def transmit_server_bye(socket)
    write_log "Transmitting SERVER_BYE to #{socket.peeraddr[2]}."
    construct_transmit(socket, magic_string, "SERVER_BYE")
  end
end

if __FILE__ == $0
  if ARGV.empty?
    Server.new.listen
  else
    puts "Server accepts no arguments."
    exit 1
  end
end