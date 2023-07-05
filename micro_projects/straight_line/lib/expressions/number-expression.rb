class NumberExpression < Expression
  def initialize(num)
    @number = num
  end
  
  def valid?
    @number.integer?
  end
  
  def execute
    @number
  end
  
  def to_s
    "#<NumberExpression: #{@number}>"
  end
end