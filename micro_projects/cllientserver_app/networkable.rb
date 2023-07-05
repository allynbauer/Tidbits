# == Synopsis
#   Networkable is a mixin module for Server and Client. It shares
#   common functionality between the two.
#
# == Author
#   Allyn Bauer
#   29 September 2008
#   22 October 2008

module Networkable
  class SocketMessageError < StandardError; end
  SETTINGS_FILE = 'settings.yaml'
  
  # redefine so we can get options by just calling them as a method
  def method_missing(symbol, *args, &block)
    if @options.key?(symbol)
      @options[symbol]
    else
      super(symbol, *args, &block)
    end
  end
  
  # Populate an options hash with settings provided first by the command line
  # then from a settings file. The settings file serves as a default in the event
  # custom settings are not provided. It also serves to keep metadata out of this file.
  def load_settings(args = [], *names)
    raise "no setting names provided" if not args.empty? and names.empty?
    require 'yaml'
    @options = {}
    args.reverse.each do |val|
      @options[names.pop] = val
    end
    
    # import and clean up options from the yaml
    imports = YAML.load_file(SETTINGS_FILE)
    imports.each_pair do |key, value|
      if not key.is_a? Symbol
        imports[key.to_sym] = value
        imports.delete(key)
      end
    end

    # combine the hashes
    @options = imports.merge(@options)
  end
  
  # Process an input for a socket. Returns false if the input is invalid,
  # true if everything went smoothly.
  def process(socket, input)
    data = input.chomp.split
    # verify the data
    if not data.shift == magic_string
      return false
    elsif not @commands.include?(data.first)
      raise SocketMessageError.new("#{data.first} is not a valid command.")
      return false
    else
      send("process_" + data.shift.downcase, *data << socket)
    end
    return true
  end
  
  # Send the +data+ to the +socket+, spaced with the delimiter in @options.
  def construct_transmit(socket, *data)
    socket.puts(data.join(delimiter))
  end
end