class Parser
  class UnknownExpressionError < RuntimeError; end
  require 'ostruct'
  require 'strscan'
  
  def self.regexes
    regexes = OpenStruct.new
    regexes.number     = /^\-?\d+$/
    regexes.varref     = /^\w+$/
    regexes.with       = /\(\s?with\s?([a-zA-Z]+)\s?=\s?(.+?)\s?do\s?(.+)\s?\)/
    regexes.operator   = /\(\s?([a-zA-Z]+|.+?\)|\-?\d+)\s?([+|\-|\/|\*|@|%]{1})\s?(.+)\s?\)/
    regexes.assignment = /\(\s?([a-zA-Z]+)\s?<-\s?(.+)\s?\)/
    regexes
  end
  
  def self.parse(str)
    str = str.strip.squeeze(" ")
    
    if str =~ regexes.number
      return NumberExpression.new(str.to_i)

    elsif str =~ regexes.varref
      return VarExpression.new(str)

    else # it's not so simple..
      scanner = StringScanner.new(str)

      if scanner.scan(regexes.with)
        assignment = AssignmentExpression.new(VarExpression.new(scanner[1]), parse(scanner[2]))
        list = parse_list(scanner[3])
        return WithExpression.new(assignment, list)

      elsif scanner.scan(regexes.operator)
        return OperatorExpression.new(parse(scanner[1]), scanner[2], parse(scanner[3]))

      elsif scanner.scan(regexes.assignment)
        return AssignmentExpression.new(VarExpression.new(scanner[1]), parse(scanner[2]))
      end
    end
    raise UnknownExpressionError, "unable to determine expression from \"#{str}\""
  end
  
  def self.parse_list(str)
    level = 0 
    compound = false
    str.split(//).each_with_index do |token, index|
      if token == "("
        level += 1
        compound = true
      elsif token == ")"
        level -= 1
      end
      
      unless compound || !str.empty?
        return parse(str)
      end
      
      if level == 0
        exp = str[0, index + 1].strip
        if not exp.empty?
          return [parse(exp)] + parse_list(str[index + 1, str.length]).flatten
        end
      end
    end
  end
end