require_relative "../test_helper"

class TardotgzTest < Minitest::Test
  include Tardotgz

  def test_that_constant_is_defined
    assert_equal "constant", defined?(Tardotgz)
  end

  def test_that_it_is_a_module
    assert_equal Module, Tardotgz.class
  end

  def test_create_archive_creates_archive
    source_path = path_helper("lib")
    archive_path = path_helper("lib.tar.gz")
    assert_equal archive_path, create_archive(source_path, archive_path)

    assert File.exist?(archive_path)
    File.delete(archive_path)
  end

  def test_create_archive_raises_error_if_source_path_is_not_readable
    source_path = path_helper("foobarbaz")
    archive_path = path_helper("lib.tar.gz")

    assert_raises(Errno::ENOENT) do
      create_archive(source_path, archive_path)
    end
  end

  def test_create_archive_raises_error_if_archive_path_is_not_writable
    source_path = path_helper("lib")
    archive_path = "/foo.tar.gz"

    assert_raises(Errno::EACCES) do
      create_archive(source_path, archive_path)
    end
  end
end
