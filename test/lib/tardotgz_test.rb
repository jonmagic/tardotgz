require_relative "../test_helper"

class TardotgzTest < Minitest::Test
  def test_that_constant_is_defined
    assert_equal "constant", defined?(Tardotgz)
  end

  def test_that_it_is_a_module
    assert_equal Module, Tardotgz.class
  end
end
