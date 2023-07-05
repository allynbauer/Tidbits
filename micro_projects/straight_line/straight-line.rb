#!/usr/bin/env ruby
# == Synopsis
#   This is a simple compiler/parser program. It may be run either
#   in interactive mode, wherein the user manually enters values to
#   execute, or passed a file to process.
# 
# == Examples
#   ruby straight_line.rb -i
#   ruby straight_line.rb -e '(5 + 5)'
#   ruby straight_line.rb filename
#
# == Usage
#   ruby straight_line.rb [options]
# 
#   For help, do: ruby straight_line.rb -h
#
# == Options
#   -h, --help            Display the help message and exit
#   -v, --verbose         Verbose output
#   -V, --version         Display the version and exit
#   -i, --interactive     Run interactively
#   -e, --execute exp     Run the given exp, print it's result, then exit
#   -t, --tests           Execute an example script
#   -c, --color           Run program with colors..!
#
# == Author
#   Allyn Bauer
#   allyn.bauer@gmail.com
#   http://www.allynbauer.com
#
# == BNF Details
# The interpreter process expressions based on the following BNF diagram:
# <exp> ::= <number>
#        | <variable-ref>
#        | ( <exp> <operator> <exp> )
#        | ( with <var> = <exp> do <exp>+ )
#        | ( <var> <- <exp> )
# 
# <operator> ::= + | - | * | / | % | @

require 'optparse'
require 'ostruct'

require './lib/parser.rb'
require './lib/command-shell.rb'
require './lib/color.rb'
require './lib/core-extensions.rb'

require './lib/expressions/expression.rb'
require './lib/expressions/assignment-expression.rb'
require './lib/expressions/operator-expression.rb'
require './lib/expressions/number-expression.rb'
require './lib/expressions/with-expression.rb'
require './lib/expressions/var-expression.rb'

class StraightLine
  
  VERSION = '1.0.0'
  
  attr_reader :options
  
  def initialize(arguments = "")
    @arguments = arguments
    
    @options = OpenStruct.new
    @options.verbose      = false
    @options.interactive  = false
    @options.color        = false
  end
  
  def run
    if parsed_options?
      output_options if @options.verbose
      process_command
    else
      output_usage
    end
  end
  
  protected
  
  def parsed_options?
    opts = OptionParser.new
    opts.on('-V', '--version')      {  output_version; exit         }
    opts.on('-h', '--help')         {  output_help                  }
    opts.on('-t', '--tests')        {  output_tests                 }
    opts.on('-v', '--verbose')      {  @options.verbose     = true  }
    opts.on('-i', '--interactive')  {  @options.interactive = true  }
    opts.on('-e', '--execute')      {  @options.execute     = true  }
    opts.on('-c', '--colors')       {  @options.color       = true  }
    
    opts.parse!(@arguments) rescue return false
    
    @options.verbose = false if @options.execute
    true
  end
  
  def color?
    @options.color
  end
  
  def output_options
    puts "Options:"
    @options.marshal_dump.each do |name, val|
      puts " #{name} = #{val}"
    end
  end
  
  def output_help
    output_version
   # puts RDoc::usage()
  end
  
  def output_usage
   # RDoc::usage('usage') # gets usage from comments above
  end
  
  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end
  
  def output_tests
    #@arguments.unshift(TEST_FILE_NAME)
    #do_file
    exit
  end
  
  def process_command
    if @options.interactive
      do_shell
    elsif @options.execute
      puts do_execute
    else
      do_file
    end
  end
  
  private
  
  def do_shell
    shell = CommandShell.new(@options)
    shell.process_loop do |input|
      begin
        exp = Parser.parse(input)
        puts exp if @options.verbose
        puts "#{exp.eval}".colorify(color?, Color::GREEN, 0)
      rescue Parser::UnknownExpressionError
        puts "That expression is invalid."
      rescue VarExpression::VarNotBoundError => e
        puts e
      end
    end
  end
  
  def do_file
    unless @arguments.empty?
      file = File.open(@arguments.first, 'r')
      data = Parser.parse_list(file.read)
      data.each do |exp|
        if exp.is_a? Expression
          puts exp if @options.verbose
          puts exp.eval
        end
      end
    else
      output_help
    end
  end
  
  public
  
  def do_execute(data = @arguments)
    data = data.join(" ") if data.is_a? Array
    Parser.parse(data).eval
  end
end

if __FILE__ == $0
  sl = StraightLine.new(ARGV)
  sl.run
end