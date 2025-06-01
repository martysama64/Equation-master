require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/Equation_master_gem/solver'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

class TestSolver < Minitest::Test
  def setup
    @solver = EquationMaster::Solver
  end

  def test_linear_equation
    result = @solver.solve("2x + 4 = 0")
    assert_equal [-2.0], result[:roots]
    assert_equal "Линейное уравнение", result[:type]
  end

  def test_quadratic_equation_two_roots
    result = @solver.solve("x^2 - 5x + 6 = 0")
    assert_equal [3.0, 2.0], result[:roots]
    assert_equal "Квадратное уравнение", result[:type]
    assert result[:discriminant] > 0
  end

  def test_cubic_equation_one_real_root
    result = @solver.solve("x^3 - 3x^2 + 9x - 27 = 0")
    assert_in_delta 3.0, result[:roots].first.real, 0.001
    assert_equal 2, result[:roots].grep(Complex).size
    assert_equal "Кубическое уравнение", result[:type]
  end

  def test_equation_parsing
    assert_raises(RuntimeError) { @solver.solve("x^4 + 1 = 0") }
    assert_raises(RuntimeError) { @solver.solve("invalid equation") }
  end
end