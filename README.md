# Tardotgz

Tardotgz is an extraction of a few archive utility methods I wrote while working on a project at GitHub. These methods simplify the creation of gzipped tarball archives and the reading and extraction of files from those archives.

One of the unique features of the #read_from_archive and #extract_from_archive utility methods is the ability to pass them a block (in fact `#extract_from_archive` just calls `#read_from_archive` and passes it a block).

And in case you were wondering, I've been pronouncing it "tar-dot-jeez" :grin:

## Usage

Start by including the module into the class where you'll use it.

```ruby
class FruitRollup
  include Tardotgz
end
```

### Create an archive

Create an archive from a folder by calling `#create_archive` with the source path (the directory or file you want to archive) and the target path (the path and filename for the archive that it creates).

```ruby
> fr = FruitRollup.new
=> #<FruitRollup:0x007fc0e4acf538>
> source_path = File.expand_path("~/Notes")
=> "/Users/jonmagic/Notes"
> archive_path = File.expand_path("~/Dropbox/notes.tar.gz")
=> "/Users/jonmagic/Dropbox/notes.tar.gz"
> fr.create_archive(source_path, archive_path)
=> "/Users/jonmagic/Dropbox/notes.tar.gz"
```

### Read file(s) from an archive

You can read the contents of a file (or files) in an archive without unzipping or untarring the archive by using the `#read_from_archive` method. It's use is also fairly flexible.

#### Read the contents of a single file

```ruby
> fr.read_from_archive(archive_path, "testing1.md")
=> "hello world\n"
```

#### Read the contents of files matching a pattern

```ruby
> fr.read_from_archive(archive_path, /testing\d.md/) # read all files matching pattern
=> "hello world\nfoobarbaz\n"
```

#### Passing a block yields the block with each tarfile that matches the pattern

```ruby
> fr.read_from_archive(archive_path, /testing\d.md/) do |tarfile| # pass a block
*   puts tarfile.read.upcase
* end
HELLO WORLD

FOOBARBAZ

=> nil
```

### Extract file(s) from an archive

You can extract the contents of an archive with #extract_from_archive.

#### Extract a single file

```ruby
> destination_path = File.expand_path("~/Restored notes")
=> "/Users/jonmagic/Restored notes"
> fr.extract_from_archive(archive_path, destination_path, "testing1.md")
=> "/Users/jonmagic/Restored notes"
> File.exist?("#{destination_path}/testing1.md")
=> true
> File.exist?("#{destination_path}/testing2.md")
=> false
```

#### Extract all files matching a pattern

```ruby
> fr.extract_from_archive(archive_path, destination_path, /testing\d\.md/)
=> "/Users/jonmagic/Restored notes"
> File.exist?("#{destination_path}/testing1.md")
=> true
> File.exist?("#{destination_path}/testing2.md")
=> true
```

#### Passing a block cleans up extracted files after extracting and then yielding the block

```ruby
> fr.extract_from_archive(archive_path, destination_path, /testing\d\.md/) do
*   puts File.exist?("#{destination_path}/testing1.md")
*   puts File.exist?("#{destination_path}/testing2.md")
* end
true
true
=> nil
> File.exist?(destination_path)
=> false
```

## Contribute

If you'd like to hack on Tardotgz, start by forking the repo on GitHub:

https://github.com/jonmagic/tardotgz

The best way to get your changes merged back into core is as follows:

1. Clone down your fork
1. Create a thoughtfully named topic branch to contain your change
1. Hack away
1. If you are adding new functionality, document it in the README
1. If necessary, rebase your commits into logical chunks, without errors
1. Push the branch up to GitHub
1. Send a pull request for your branch

## LICENSE

The MIT License (MIT)

Copyright (c) 2015 Jonathan Hoyt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
