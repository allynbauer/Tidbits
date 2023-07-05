# EXAMPLE RUN:
#
# ~/Desktop $> ruby file_inventory.rb . .rb m c h a
# EXTENSION        FILES        LINES          AVG LINES/FILE                      
# ---------------------------------------------------------------------------------
#      *.rb         5073        489642                      97                      
#       *.m         2619        612648                     234                      
#       *.c          107        71519                     668                      
#       *.h         5868        256127                      44                      
#       *.a           10        62543                    6254

module Kernel
  alias :gtfo :exit
end

class Symbol
  def to_proc
    proc { |obj, *args| obj.send(self, *args) }
  end
end

class FileInventory  
  TAB = 4 # length of 'tab'
  attr_accessor :dir, :extensions
  
  def initialize(args)
    usage("missing arguments") if args.length < 2
    @dir = File.expand_path(args.shift)
    usage("#{@dir} is not a directory") if not File.directory?(@dir)
    @extensions = args.collect { |e| e.gsub('.', '') } # remove the dot if its there
  end
  
  def usage(err = "")
    puts "\033[0;31m[ERROR]\033[0m #{err}" if not err.empty?
    puts "ruby file_inventory.rb $dir $extension1 [$extension2]"
    gtfo
  end
  
  def run
    counts = {}
    @extensions.each do |extension|
      files = Dir["#{@dir}/**/*.#{extension}"]
      files_count = files.collect { |f| File.new(f).readlines.count }.inject(0) { |t,n| t + n }
      counts[extension] = [files.length, files_count, files_count.to_f/files.length]
    end
    output(counts)
  end
  
  def output(hsh)
    headers = ["EXTENSION", "FILES", "LINES", "AVG LINES/FILE"]
    data_max = []
    data_max << hsh.keys.collect(&:length).sort.last + 2
    3.times do |t|
      data_max << hsh.values.collect { |v| v[t].to_s.length }.sort.last
    end
    row = ""
    headers.each_with_index do |header, i|
      row += header.ljust(data_max[i] + TAB + headers[i].length)
    end
    puts row
    puts "-" * row.length
    hsh.each do |k,v|
      print "*.#{k}".rjust(headers[0].length)
      print " " * (TAB + data_max[0])
      v.each_with_index do |val, i|
        if val.to_f.nan?
          val = 0
        end
        print val.to_f.round.to_s.rjust(headers[i+1].length)
        print " " * (TAB + data_max[i+1])
      end
      puts "\n"
      puts "-" * row.length
    end
  end
end

FileInventory.new(ARGV).run if __FILE__ == $0