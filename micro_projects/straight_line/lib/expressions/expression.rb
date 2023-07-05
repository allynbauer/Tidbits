class Expression
  class MethodNotImplementedError < RuntimeError; end
  @@bindings = {}
  
  def self.bounds
    @@bindings
  end
  
  def self.bound_vars
    @@bindings.keys.length
  end
  
  def type
    self.class.to_s
  end
  
  def expression?
    true
  end
  
  def initialize
    raise MethodNotImplementedError, "#{self.class} must know how to initialize"
  end
  
  def valid?
    raise MethodNotImplementedError, "#{self.class} must know how to validate"
  end
  
  def execute
    raise MethodNotImplementedError, "#{self.class} must know how to execute"
  end
  
  # these methods could be alias'd, except it seems that Ruby doesn't
  # traverse the object stack with alias'd methods. so, we do this.
  def eval
    execute
  end
  
  def evaluate
    execute
  end
end
