require "fileutils"
require "pathname"
require "rubygems/package"
require "tempfile"
require "zlib"

module Tardotgz
  # Public: Create a gzipped archive with the contents of source_path.
  #
  # source_path  - Pathname or String path to files that need archived.
  # archive_path - Pathname or String path and filename for created archive.
  #
  # Returns Pathname or String archive_path.
  def create_archive(source_path, archive_path)
    unless File.readable?(source_path)
      raise Errno::ENOENT.new(source_path.to_s)
    end

    unless File.writable?(Pathname(archive_path).dirname)
      raise Errno::EACCES.new(archive_path.to_s)
    end

    tarfile = Tempfile.new(Pathname(archive_path).basename.to_s)

    Gem::Package::TarWriter.new(tarfile) do |tar|
      Dir[File.join(source_path.to_s, "**/*")].each do |file|
        mode = File.stat(file).mode
        relative_file = file.sub /^#{Regexp::escape source_path.to_s}\/?/, ''

        if File.directory?(file)
          tar.mkdir relative_file, mode
        else
          tar.add_file relative_file, mode do |tf|
            File.open(file, "rb") { |f| tf.write f.read }
          end
        end
      end
    end

    tarfile.rewind

    File.open(archive_path, "wb") do |gz|
      z = Zlib::GzipWriter.new(gz)
      z.write tarfile.read
      z.close
      tarfile.close
    end

    return archive_path
  end

  # Public: Read and return file(s) contents from archive or yield block
  # with each files contents as it is read.
  #
  # archive_path - Pathname or String path to archive.
  # pattern      - String relative file path or Regexp pattern for selecting
  #                multiple files.
  #
  # Returns a String (or NilClass if block given).
  def read_from_archive(archive_path, pattern)
    results = []

    Zlib::GzipReader.open(archive_path) do |gz|
      Gem::Package::TarReader.new(gz) do |tar|
        case pattern
        when String
          tarfile = tar.detect do |tarfile|
            tarfile.full_name == pattern
          end

          if tarfile
            if block_given?
              yield(tarfile)
              return nil
            else
              results << tarfile.read
            end
          end
        when Regexp
          tar.each do |tarfile|
            if tarfile.full_name =~ pattern
              if block_given?
                yield(tarfile)
              else
                results << tarfile.read
              end
            end
          end

          return nil if block_given?
        end
      end
    end

    if results.empty?
      message = pattern.is_a?(Regexp) ? pattern.inspect : pattern
      raise Errno::ENOENT.new(message)
    end

    results.join
  end

  # Public: Extract file(s) from archive to destination path and optionally
  # cleanup extracted files after yielding a block if it is provided.
  #
  # archive_path     - Pathname or String path to archive.
  # destination_path - Pathname or String destination path for files.
  # pattern          - String relative file path or Regexp pattern for
  #                    selecting multiple files.
  #
  # Returns Pathname or String destination_path (or NilClass if block given).
  def extract_from_archive(archive_path, destination_path, pattern=/.*/, &block)
    read_from_archive(archive_path, pattern) do |tarfile|
      destination_file = File.join(destination_path, tarfile.full_name)

      if tarfile.directory?
        FileUtils.mkdir_p(destination_file)
      else
        destination_directory = File.dirname(destination_file)
        FileUtils.mkdir_p(destination_directory) unless File.directory?(destination_directory)
        File.open(destination_file, "wb") do |f|
          f.write(tarfile.read)
        end
      end
    end

    if block_given? && File.exist?(destination_path)
      yield
      FileUtils.rm_rf(destination_path, :secure => true)
      return nil
    else
      return destination_path
    end
  end
end
