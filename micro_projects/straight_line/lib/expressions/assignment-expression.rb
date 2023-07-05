class AssignmentExpression < Expression
  def initialize(var, val)
    @var = var
    @val = val
  end
  
  def vaild?
    @var.valid? && @val.valid?
  end
  
  def execute
    @var.register_with_value! @val.execute
    @var.execute
  end
  
  def to_s
    "#<AssignmentExpression: (#{@var} = #{@val})>"
  end
end