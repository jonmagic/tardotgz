# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "tardotgz"
  spec.version       = "1.0.0"
  spec.date          = "2015-02-22"
  spec.summary       = "Archive utility module"
  spec.description   = "Methods for creating, reading, and extracting gzipped tarballs."
  spec.authors       = ["Jonathan Hoyt"]
  spec.email         = "jonmagic@gmail.com"
  spec.files         = ["lib/tardotgz.rb"]
  spec.homepage      = "https://github.com/jonmagic/tardotgz"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.6"
  spec.add_development_dependency "rake",     "~> 10.4"
  spec.add_development_dependency "minitest", "~> 5.5"
end
