class VarExpression < Expression
  class VarNotBoundError < RuntimeError; end
    
  def initialize(name)
    @name = name.to_sym
  end
  
  def vaild?
    true
  end
  
  def register_with_value!(val)
    @@bindings.merge!( { @name => val } )
  end
  
  def execute
    val = @@bindings[@name]
    raise VarNotBoundError, "'#{@name}' has not been defined." if val.nil?
    val
  end
  
  def to_s
    "#<VarExpression: #{@name}>"
  end
end