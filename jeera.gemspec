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

  gem.add_dependency 'thor'
  gem.add_dependency 'faraday', '~> 0.8.8'
  gem.add_dependency 'faraday_middleware', '~> 0.8.8'
  gem.add_dependency 'activesupport', '~> 4.0.1'
  gem.add_dependency 'terminal-table'
  # gem.add_dependency 'command_line_reporter', '~> 3.2.1'
  # gem.add_dependency 'rainbow'
  # gem.add_dependency 'oj'

  gem.add_development_dependency 'pry-stack_explorer', '~> 0.4.9'
  gem.add_development_dependency 'pry-debugger', '~> 0.2.2'
  gem.add_development_dependency 'awesome_print', '~> 1.2.0'
  # gem.add_development_dependency 'minitest'
  # gem.add_development_dependency 'minitest-matchers'
  # gem.add_development_dependency 'mocha'
  # gem.add_development_dependency 'webmock'
  # gem.add_development_dependency 'turn'

  gem.version = Jeera::VERSION
end
