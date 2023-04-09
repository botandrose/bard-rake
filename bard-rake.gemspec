lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bard/rake/version'

Gem::Specification.new do |spec|
  spec.name          = "bard-rake"
  spec.version       = Bard::Rake::VERSION
  spec.authors       = ["Micah Geisel"]
  spec.email         = ["micah@botandrose.com"]
  spec.description   = "Rake tasks for all bard projects.\n* Bootstrap projects\n* Database backup"
  spec.summary       = "Rake tasks for all bard projects."
  spec.homepage      = "http://github.com/botandrose/bard-rake"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency "backhoe", ">=0.6.0"
  spec.add_dependency "railties"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency(%q<rspec>, [">= 1.2.9"])
end

