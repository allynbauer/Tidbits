# == Synopsis
#   A simple client that implements a simpletalk based protocol.
#   A mixin called Networkable keeps some generic functionality out of
#   this file.
#
# == Flags
#   [<hostname>[ <port>]] <login id> <first name>
#
# == Author
#   Allyn Bauer
#   29 September 2008
#   22 October 2008

class Client
  require 'socket'
  require 'networkable'
  include Networkable
  
  attr_accessor :socket
  def initialize(args, settings)
    load_settings(args, *settings)
    @socket   = TCPSocket.open(host, port)
    @running  = true
    @commands = %w(STATUS SERVER_BYE)
    puts "Connection to #{host} on port #{port} with " +
      "login id #{login_id} and name #{first_name} established."
  end
  
  def self.usage
    "Usage: ruby client.rb [<hostname>[ <port>]] <login id> <first name>"
  end
  
  def listen
    while @running
      input = @socket.gets
      if !input
        @socket.close
        next
      end
      if not process(@socket, input)
        raise SocketMessageError.new("Message received (#{input}) is invalid.")
      end
    end
  end
  
  def transmit_hello
    construct_transmit(@socket, magic_string, "HELLO", login_id, first_name)
    listen
  end
  
  def transmit_client_bye(cookie)
    construct_transmit(@socket, magic_string, "CLIENT_BYE", cookie)
    listen
  end
  
  def process_status(cookie, ip, socket)
    transmit_client_bye(cookie)
  end
  
  def process_server_bye(socket)
    @running = false
  end
end

if __FILE__ == $0
  length = ARGV.length
  # handle bounds
  if length < 2 || length > 4
    puts Client.usage
    exit 1
  end
  
  # figure params
  params = [:login_id, :first_name]
  if length == 3
    params.unshift(:hostname)
  elsif length == 4
    params.unshift(:hostname, :port)
  end
  client = Client.new(ARGV, params)
  client.transmit_hello
end