require 'zlib'

class CachedQueue
  attr_reader :data
  
  def initialize(name = 'queue.cache')
    @name = name
    load
  end
  
  def enqueue(*objs)
    objs.flatten.each do |obj|
      @data << obj
    end
    save
  end
  
  # If the internal data array contains >0 items, it returns the first
  # one and removes it. If the data array contains 0 items, nil is returned.
  def dequeue
    obj = @data.shift
    save
    obj
  end
  
  def method_missing(name, *args, &block)
    @data.send(name, *args, &block)
  end
  
  private
  
  # Save the data array to a gzip'd file. This occurs on every enqueue or dequeue
  def save
    File.open(@name, 'w') do |f|
      g = Zlib::GzipWriter.new(f)
      g.write(Marshal.dump(@data))
      g.close
    end
  end
  
  # Load the data array. This occurs when the queue is initialized
  def load
    data = []
    unless File.exists?(@name)
      @data = data
      return
    end
    
    Zlib::GzipReader.open(@name) do |g|
      data = g.read
    end
    @data = Marshal.load(data)
  end
end