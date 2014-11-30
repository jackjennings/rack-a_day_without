# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/a_day_without/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-a_day_without"
  spec.version       = Rack::ADayWithout::VERSION
  spec.authors       = ["Jack Jennings"]
  spec.email         = ["j@ckjennin.gs"]
  spec.summary       = %q{Rack middleware for serving alternate content on a given day}
  spec.homepage      = "http://github.com/jackjennings/rack-a_day_without"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 1.4"
  spec.add_dependency "tzinfo", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "minitest", "~> 5.4"
end
