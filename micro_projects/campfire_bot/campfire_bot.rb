# campfire_bot.rb 1.0
#
# == Synopsis
#   This is a simple bot for use with Campfire. It has several included
#   functions, and has the ability to save its state on exit and load it
#   on initilization.
#
# == Notes
#   This program uses several arrays to maintain data associated with the bot.
#   Since there's no associated database, each time the array is created
#   (either by using the bot or by loading from disk) it takes a certain amount of
#   memory - in short, if you use this program for a long time, consider
#   it may take up a lot of memory, so consider restarting it with blank data.
#
#   Commands are executed as the only thing on a line. A command may be any word -
#   where a word is any sequence of non breaking spaces. To execute a command from
#   campfire, type a period then the command name, then any args seperated by spaces.
#   EX: .help
#       .shout Hey, this is a shout!
#       .quit
#
# == Flags
#   REGEX       - The regex that matches commands
#   SAVE_STATE  - if true, loads and saves its state to disk on init or quit.
#   FILENAME    - A string for the filename of the state saving.
#   COMMANDS    - A list of commands. To add a new command, simply add it to the
#                 list and specify the args it takes.
#
# == Usage
#   CampfireBot.new(address, email, password, rooms)
#   address     - the campfire address
#   email       - email address of the bot user
#   password    - password of the bot user
#   rooms       - names of the rooms the bot should join
#
# == Required Gems
#   tinder and dependencies
#
# == Author
#   Allyn Bauer
#   allyn.bauer@gmail.com

require 'rubygems'
require 'tinder'
require 'cgi'
require 'zlib'

# Patch the tinder gem because it's current implementation of users is broken
module Tinder
  class Campfire
    # List the users that are currently chatting in any room
    def users(*room_names)
      users = Hpricot(get.body).search("div.room").collect do |room|
        if room_names.empty? || room_names.include?((room/"h2/a").inner_html)
          room.search("//li.user .name").collect { |user| user.inner_html }
        end
      end
      users.flatten.compact.uniq.sort
    end
  end
end

class CampfireBot                           
  attr_reader   :afk_users,        :notes,      :quotes, 
                :room_names,       :rooms,      :campfire,
                :address,          :email,      :password,
                :num_processed             
                                            
  REGEX = /^\.{1}[\w]{1,}/
  SAVE_STATE = true
  FILENAME = 'campfire_bot.dump'
  COMMANDS = {
    #command =>   args (or nil if there are not any)
    "quit"   =>   nil,
    "time"   =>   :room,
    "note"   =>   :room,
    "quote"  =>   :room,
    "list"   =>   :room,
    "afk"    =>   :user,
    "topic"  =>   [:room, :args],
    "help"   =>   [:room, :args],
    "shout"  =>   [:user, :args],
    "record" =>   [:room, :user, :args]
  }
  
  COMMANDS_HELP = {
    "quit"   =>  "Quits the bot.",
    "time"   =>  "Prints the current server time.",
    "note"   =>  "",
    "quote"  =>  "Prints out a random quote from the list, as saved by record.",
    "list"   =>  "List all users that are currently afk.",
    "afk"    =>  "Set yourself as away from the keyboard.",
    "topic"  =>  "Change the room topic to the provided argument.",
    "help"   =>  "Print out help messages.",
    "shout"  =>  "Shout a message to every room the Bot is in.",
    "record" =>  "Save a quote - either the last message, or the last message of the username provided."
  }
  
  def initialize(address, email, password, *rooms)
    @address    = address
    @email      = email
    @password   = password
    @room_names = rooms
    
    if SAVE_STATE
      unless load
        reset
      end
    else
      reset
    end
  end
  
  # reset the bot, either to defaults or a previous bot's data
  def reset(previous = nil)
    @rooms          =                                      []
    @afk_users      = previous ? previous.afk_users      : []
    @notes          = previous ? previous.notes          : []
    @quotes         = previous ? previous.quotes         : []
    @rooms_names    = previous ? previous.room_names     : []
    @num_processed  = previous ? previous.num_processed  : 0
    
    # sit around the campfire..
    @campfire = Tinder::Campfire.new(@address)
    @campfire.login email, password
    
    # setup rooms and threads
    threads = []
    @room_names.each do |name|
      room = @campfire.find_room_by_name(name)
      @rooms  << room
      threads << RoomThread.new(room, self)
    end
    threads.each(&:join)
    
    # yay, time for play
    puts "Ready in all rooms - processing."
  end
  
  # write the bot state to disk
  def save
    dump = Marshal.dump(self)
    file = File.new(FILENAME, 'w')
    file = Zlib::GzipWriter.new(file)
    file.write(dump)
    file.close
    puts "Bot state saved."
  end
  
  # load the state from teh disk
  def load
    return false unless File.file?(FILENAME)
    file = File.new(FILENAME, 'r')
    file = Zlib::GzipReader.new(file)
    state = Marshal.load(file.read)
    file.close
    reset(state)
    puts "Bot state loaded."
  end

  # gets called each time a message is sent
  def parse_message(msg, user, room)
    if msg =~ REGEX
      execute_command(msg, user, room)
    elsif @afk_users.any?{ |i| msg =~ /#{i}/ }
      room.speak("[Status] #{user}: user #{@afk_users.select{ |i| msg =~ /#{i}/ }.first} is afk.")
    end
  end
  
  # execute the command given, or an error message
  def execute_command(cmd, user, room)
    cmd  = cmd.split                    # split the array
    args = cmd.last(cmd.length - 1)     # get the args (everything that's not the first entry)
    cmd  = cmd.first.reverse.chop.reverse.downcase # remove the dot from the command
    
    # if this command is actually a command..
    if COMMANDS.keys.any?{|p| p == cmd }
      method = self.method(cmd) # get the method assoicated with the command
      opts = COMMANDS[cmd]      # get the options
      opts = opts.to_s.to_a if not opts.is_a? Array

      # ensure we have the proper amount of options to pass to the method
      if method.arity == opts.length
        inputs = []
        opts.each do |opt| # build the params list
          inputs << case opt.to_sym
            when :room then room
            when :args then args
            when :user then user
          end
        end
        # execute it
        puts "#{@num_processed += 1}@[#{Time.now}] Command processed: #{cmd}"
        send(cmd, *inputs)
      else
        room.speak("Fatal error - configuration error")
        quit
        raise "fatal error - wrong number of inputs in COMMANDS hash. Had #{opts.length} needed #{method.arity}"
      end
    else
      room.speak("Unknown command: #{cmd}")
    end
  end
  
  protected
  # THESE METHODS ARE COMMAND METHODS
  def time(room)
    room.speak("It is currently #{Time.now.strftime("%A, %B %d %I:%M %p")}")
  end
  
  def quit
    save if SAVE_STATE
    @rooms.each(&:leave)
    @rooms.clear
    @campfire.logout
    exit
  end
  
  def topic(room, args)
    room.topic = args.join(" ")
  end

  def note(room)
    room.speak("Feature coming soon")
  end
  
  def help(room, args)
    if args.empty?
      room.speak("Commands are: #{COMMANDS.keys.sort.join(", ")}")
      room.speak("For information on individual commands, do .help $command_name")
    elsif COMMANDS_HELP[args.first.downcase].nil?
      room.speak("[help] No help data.")
    else
      room.speak("[help] #{COMMANDS_HELP[args.first.downcase]}")
    end
  end
  
  def shout(user, args)
    @rooms.each do |room|
      room.speak("[shout] from #{user}: #{CGI::unescapeHTML(args.join(" "))}")
    end
  end
  
  def record(room, user, args)
    messages = room.transcript(room.available_transcripts.first)
    find_for = (args and args.join(" ").empty? ? messages.last[:person] : args.join(" "))
    message  = false
    messages.reverse.each do |msg|
      if msg[:person] == find_for
        message = msg
        break
      end
    end
    
    if message
      @quotes << message
      room.speak(CGI::unescapeHTML("Quote recorded: \"#{message[:message]}\""))
    else
      room.speak(CGI::unescapeHTML("Can not find any messages from user '#{find_for}'."))
    end
  end
  
  def quote(room)
    if @quotes.empty?
      room.speak("No quotes to choose from!")
    else
      rand_quote = @quotes.rand
      room.speak(CGI::unescapeHTML("[quote]: \"#{rand_quote[:message]}\" - #{rand_quote[:person]}"))
    end
  end
  
  def list(room)
    if @afk_users.empty?
      room.speak("No users are currently afk.")
    else
      room.speak("Currently afk users are: #{@afk_users.join(", ")}")
    end
  end
  
  def afk(user)
    if @afk_users.include?(user)
      @afk_users.delete(user)
      @rooms.each do |room|
        room.speak("[Status] #{user} is no longer away.") if room.users.any?{|u| u =~ /^#{user}/}
      end
    else
      @afk_users << user
      @rooms.each do |room|
        room.speak("[Status] #{user} is away.") if room.users.any?{|u| u =~ /^#{user}/}
      end
    end
  end
end

class RoomThread < Thread
  def initialize(room, bot)
    puts "Joined Room: #{room}"
    super(room, bot) do
      catch(:stop_listening) do
        room.listen do |msg|
          bot.parse_message(msg[:message], msg[:person], room)
        end
      end
    end
  end
  
  class Note
    attr_reader :read, :time
    
    def initialize(owner, receiver, message, time)
      @owner      = owner
      @receiver   = receiver
      @message    = message
      @time       = time
      @read       = false
    end
    
    def <=>(other)
      time <=> other.time
    end
    
    def read
      @read = true
      "(Message received from #{owner} at #{@time.strftime("%A, %B %d %I:%M %p")}) #{message}"
    end
  end
end