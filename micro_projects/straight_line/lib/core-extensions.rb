class String
  def colorify(has_color = false, *color)
    require 'enumerator'
    unless has_color
      return self
    end
  
    str   = ""
    last  = 0
    
    color.each_slice(4) do |code|
      if code.length != 4
        code[2] = Color::NC
        code[3] = self.length
      end
      
      str += self.substr(last, code[1])
      str += code[0]
      str += self.substr(code[1], code[3])
      str += code[2]
      last = code[3]
    end
    str += self.substr(last, self.length)
    return str
  end
  
  def substr(from, to)
    self.slice(from, to - from)
  end
end