# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gracefully/version'

Gem::Specification.new do |spec|
  spec.name          = "gracefully"
  spec.version       = Gracefully::VERSION
  spec.authors       = ["Yusuke KUOKA"]
  spec.email         = ["yusuke.kuoka@crowdworks.co.jp"]
  spec.summary       = %q{ensures features gracefully degrade based on error rate or turnaround time.}
  spec.homepage      = "https://github.com/crowdworks/gracefully"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
