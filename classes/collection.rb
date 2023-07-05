# A collection is a list (or an array, if you will) of symbols. This class is somewhat modeled after
# Ada 95's Enumeration Types. A collection may be used like an array in many ways, 
# but there are several key differences:
#
# This class maintains an internal pointer, which points to the current symbol in the collection.
# Other stuff

class Collection
  # Items is a list or an Array of the items this method will contain. These items not changeable.
  def initialize(*items)
    if items.first.is_a? Array # if items is an array
      @collection = *items
    else
      @collection = items    
    end
    
    @collection.collect! { |item| item.to_sym }
    @collection.freeze # Collection does not allow changes to its data
    
    @pointer = nil # Our internal pointer
    
    rescue NoMethodError => exc # A collection maintains symbols.
      raise ArgumentError.new("Cannot instatiate Collection because an item can't be made into a symbol.\n#{exc}")
  end

  # Advances the pointer and returns the element, wrapping.
  def next
    @pointer = -1 if not @pointer
    @pointer = up
    current
  end
  
  # Reduces the pointer and return the previous element, wrapping.
  def prev
    @pointer = 0 if not @pointer
    @pointer = down
    current
  end
  
  # Return the item that is before object
  def predecessor_of(object)
    if object.is_a? Fixnum or object.is_a? Integer
      item_at(down(object))
    else
      item_at(down(@collection.index(object.to_sym)))
    end
  end
  
  # Return the item that is after object
  def successor_of(object)
    if object.is_a? Fixnum or object.is_a? Integer
      item_at(up(object))
    else
      item_at(up(@collection.index(object.to_sym)))
    end
  end
  
  # Sets the internal pointer to the position provided, or the position of the object provided
  # If the provided input is invalid, @pointer is reset
  def set_to(pos)
    if pos.is_a? Fixnum or pos.is_a? Integer and not item_at(pos).nil?
      @pointer = pos
    elsif @collection.include?(pos)
      @pointer = @collection.index(pos)
    else
      reset
    end
  end
  
  # Returns the current pointer location as an integer
  def pos
    @pointer || 0
  end
  
  # Return the current element without advancing the pointer
  def current
    item_at pos
  end
  
  # The item at position
  def item_at(position)
    @collection[position]
  end
  
  # Reset the internal pointer to the beginning.
  def reset
    @pointer = nil
  end
  
  def to_s
    @collection.join(" ") 
  end
  
  protected
  
  # If we can't find a method here, give it to the array.
  def method_missing(*args, &block)
    @collection.send(*args, &block)
  end
  
  private
  
  # Return an wrapped integer, which is @pointer++ or from++
  def up(from = @pointer)
    (from + 1) % @collection.length
  end
  
  # Up in reverse, yo.
  def down(from = @pointer)
    (from - 1) % @collection.length
  end
end