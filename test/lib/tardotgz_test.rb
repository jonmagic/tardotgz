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

  def test_read_from_archive_returns_contents_of_file_matching_pattern_string
    archive_path = path_helper("test/fixtures/archive.tar.gz")
    pattern      = "testing1.md"

    assert_equal "hello world\n", read_from_archive(archive_path, pattern)
  end

  def test_read_from_archive_returns_contents_of_files_matching_pattern_regexp
    archive_path     = path_helper("test/fixtures/archive.tar.gz")
    pattern          = /testing\d\.md/

    assert_equal "hello world\nfoobarbaz\n", read_from_archive(archive_path, pattern)
  end

  def test_read_from_archive_yields_block_for_each_file_matching_pattern
    archive_path     = path_helper("test/fixtures/archive.tar.gz")
    pattern          = /testing\d\.md/
    expected_results = [
      "hello world\n",
      "foobarbaz\n"
    ]

    result = read_from_archive(archive_path, pattern) do |tarfile|
      assert expected_results.include?(tarfile.read)
    end

    assert_nil result
  end

  def test_read_from_archive_raises_error_if_archive_does_not_exist
    archive_path = path_helper("foobarbaz.tar.gz")

    assert_raises(Errno::ENOENT) do
      read_from_archive(archive_path, "foo")
    end
  end

  def test_read_from_archive_raises_error_if_pattern_does_not_match_any_files
    archive_path = path_helper("test/fixtures/archive.tar.gz")

    assert_raises(Errno::ENOENT) do
      read_from_archive(archive_path, "foobarbaz")
    end

    assert_raises(Errno::ENOENT) do
      read_from_archive(archive_path, /drunken\/noodle/)
    end
  end
end
