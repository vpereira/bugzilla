# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bugzilla/version'

Gem::Specification.new do |spec|
  spec.name          = 'bugzilla'
  spec.version       = Bugzilla::VERSION
  spec.authors       = ['Victor Pereira']
  spec.email         = ['vpereirabr@gmail.com']

  spec.summary       = 'Ruby gem to access bugzilla'
  spec.description   = 'My work is a revamp from ruby-bugzilla from Akira TAGOH'
  spec.homepage      = 'https://github.com/vpereira/bugzilla'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
  # spec.add_runtime_dependency 'gruff'
  spec.add_runtime_dependency 'highline'
  spec.add_runtime_dependency 'xmlrpc'
end
