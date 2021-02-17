
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "arel_helpers/version"

Gem::Specification.new do |spec|
  spec.name          = "arel_helpers"
  spec.version       = ArelHelpers::VERSION
  spec.authors       = ["John Ratcliff"]
  spec.email         = ["johnr@mammothhr.com"]

  spec.summary       = "A series of helpers for Arel and ActiveRecord"
  spec.homepage      = "http://github.com/mammothhr/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'arel', '~> 9'
  spec.add_dependency 'dux'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.5.3'
  spec.add_development_dependency 'factory_girl', '~> 4.7.0'
  spec.add_development_dependency 'generator_spec', '~> 0.9.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.8.0'
end
