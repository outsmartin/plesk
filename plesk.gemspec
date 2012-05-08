# -*- encoding: utf-8 -*-
require File.expand_path('../lib/plesk/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Martin Schneider"]
  gem.email         = ["info@outsmartin.de"]
  gem.description   = %q{Plesk RPC API wrapper written in Ruby }
  gem.summary       = %q{You can communicate with your Plesk System through the RPC API. Sends XML and recieves XML for your pleasure.}
  gem.homepage      = "http://github.com/outsmartin/plesk"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "plesk"
  gem.require_paths = ["lib"]
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'gli'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.version       = Plesk::VERSION
end
