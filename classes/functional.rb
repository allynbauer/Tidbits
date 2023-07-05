# Provides a few methods that users of Scheme will appreciate.

module Functional
  def all_and(*ary)
    ary.inject do |total, obj|
      total && obj
    end
  end
  
  def all_or(*ary)
    ary.inject do |total, obj|
      total || obj
    end
  end
  
  private
  
  def all_enum(method, *ary)
    lambda { |ary| 
      ary.inject do |total, obj|
        
      end
    }
end




include Functional
a = true && true && true && true && true
b = all_and(true, true, true, true, true)
c = all_and(true, true, true, false, true, true, true)

puts a
puts b
puts c