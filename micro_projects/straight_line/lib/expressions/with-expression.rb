class WithExpression < Expression
  def initialize(assignment, exps)
    @assignment = assignment
    @exps = exps
  end
  
  def vaild?
    @assignment.valid? && @exps.all?(&:valid?)
  end
  
  def execute
    @assignment.execute
    results = []
    @exps.each do |exp|
      results << exp.execute
    end
    results.last
  end
  
  def to_s
    "#<WithExpression: #{@assignment} <> #{@exps.join("|")}>"
  end
end