class CommandShell
  def initialize(options = nil)
    @options = options
  end
  
  def process_loop
    puts "Type 'quit' or 'exit' to quit.".colorify(@options.color, 
                                                   Color::RED, 6,  Color::NC, 10,
                                                   Color::RED, 16, Color::NC, 20)
    count = 0
    loop do
      data = ask("> ")
      
      if %w(quit exit).include?(data.strip)
        puts "Processed #{count} expressions." if @options.verbose
        exit
      end
      
      yield(data)
      puts "Bound variables: #{Expression.bound_vars}".
                    colorify(@options.color, Color::PURPLE, 17) if @options.verbose
      count += 1
    end
  end
  
  def ask(msg)
    print "#{msg}".colorify(@options.color, Color::NC, 0, Color::YELLOW, msg.length)
    line = gets
    print "".colorify(@options.color, Color::NC, 0)
    
    return line
  end
end