require 'straight-line'
require 'test/unit'

class StraightLineTest < Test::Unit::TestCase
  def setup
    st = StraightLine.new
    @m = lambda {|line| st.do_execute("#{line}") }
  end
  
  def test_addition
    assert_equal( 10,  @m["(5 + 5)"])
    assert_equal( 4,   @m["(5 + -1)"])
    assert_equal( -2,  @m["(  -1  +  -1 )"])
  end
  
  def test_subtraction
    assert_equal( 1,   @m["(5 - 4)"])
    assert_equal( -1,  @m["(5 - 6)"])
    assert_equal( 6,   @m["(  -3   -   -9 )"])
  end
  
  def test_multiplication
    assert_equal(9,   @m["(3 * 3)"])
    assert_equal(100, @m["(10*10)"])
    assert_equal(-8,  @m[" (4           *                 -2)"])
  end
  
  def test_modulo
    assert_equal( 0,   @m["(5 % 5)"])
    assert_equal( 1,   @m["(5 % 4)"])
    assert_equal( 0,   @m["(100 % 2)"])
    assert_equal( 0,   @m["(100 % -2)"])
    assert_equal( -1,  @m["(101   %-2 ) "])
  end
  
  def test_the_at_symbol
    assert_equal( 5,   @m["(5 @ 5)"])
    assert_equal( 2,   @m["(5 @ -1)"])
    assert_equal( 1,   @m["(2 @ 1)"])
  end
  
  def test_compound_operator
    assert_equal( 20,   @m["((5 + 5) + (5 + 5))"])
    assert_equal( 20,   @m["(((1 + 1) + (1 + 2)) + ((1+ 1) + (1 + 2)))"])
    assert_equal( 125,  @m["((5 * 5) * 5)"])
    assert_equal( 336,  @m["(6 * (7 * 8))"])
    assert_equal( 5,    @m["(5 @ ( 5 @ (5 @ 5)))"])
    assert_equal( 2351, @m["((with x = 7 do (x <- (2 * x)) (x <- (2 * x)) (with y = 3 do (y <- (x * y)) (x * y))) - 1)"])
  end
  
  def test_assignment_and_var
    assert_equal( 5,   @m["(x <- 5)"])
    assert_equal( 10,  @m["(y <- 10)"])
    assert_equal( 50,  @m["(x * y)"])
    assert_equal( 5,   @m["x"])
    assert_equal( 6,   @m["(x <- 6)"])
    assert_equal( 6,   @m["x"])
    assert_equal( 15,  @m["(x <- (x + 9))"])
    assert_equal( 25,  @m["(x <- (y + x))"])
    assert_equal( 25,  @m["x"])
    assert_equal( 25,  @m["(y <- x)"])
    assert_equal( 2,   Expression.bound_vars)
    assert_equal(@m["x"] + 5, @m["(x + 5)"])
  end
  
  def test_with
    assert_equal( 3,     @m["(with x = 2 do (x <- (2 * x)) (x - 1))"])
    assert_equal( 2352,  @m["(with x = 7 do (x <- (2 * x)) (x <- (2 * x)) (with y = 3 do (y <- (x * y)) (x * y)))"])
  end
  
  def test_multiple
    compound = @m["(5 + 5) ( 6 + 6 )"]
    assert_equal 10, compound[0]
    assert_equal 12, compound[1]
  end
end