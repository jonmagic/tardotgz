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
end
