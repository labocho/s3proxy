# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3proxy/version'

Gem::Specification.new do |gem|
  gem.name          = "s3proxy"
  gem.version       = S3Proxy::VERSION
  gem.authors       = ["labocho"]
  gem.email         = ["labocho@penguinlab.jp"]
  gem.description   = %q{Response file on S3 via X-Sendfile / X-Accel-Redirect}
  gem.summary       = %q{Response file on S3 via X-Sendfile / X-Accel-Redirect}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "rails", "~> 4.0"
  gem.add_dependency "carrierwave", "~> 0.8.0"
  gem.add_dependency "fog"
end
