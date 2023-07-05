class OperatorExpression < Expression
  def initialize(left, operator, right)
    @left     = left
    @operator = operator
    @right    = right
  end
  
  def valid?
    @left.valid? && @right.valid? && valid_operator?
  end
  
  def execute
    left  = @left.execute
    right = @right.execute
    
    if @operator == "@"
      (left + right) / 2
    else
      left.send(@operator, right)
    end
  end
  
  def to_s
    "#<OperatorExpression: (#{@left} #{@operator} #{@right})>"
  end
  
  private
  
  def valid_operator?
    %w(+ - * / % @).include?(@operator)
  end
end