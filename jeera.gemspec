# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jeera/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ["Seth Bro"]
  gem.email = ["seth@sethbro.com"]
  gem.description = %q{Command line interface for the JIRA REST API}
  gem.summary = %q{}
  gem.homepage = "http://github.com/sethbro/jeera"

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(spec)/})
  gem.name = "jeera"
  gem.require_paths = ["lib"]

  gem.add_dependency 'her', '~> 0.6.8'
  gem.add_dependency 'faraday_middleware', '~> 0.8.8'
  gem.add_dependency 'activesupport'

  gem.add_development_dependency 'debugger'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-matchers'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'turn'

  gem.version = Jeera::VERSION
end
