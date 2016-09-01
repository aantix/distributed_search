# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'distributed_search/version'

Gem::Specification.new do |spec|
  spec.name          = 'distributed_search'
  spec.version       = DistributedSearch::VERSION
  spec.authors       = ['Jim Jones']
  spec.email         = ['jim.jones1@gmail.com']

  spec.summary       = %q{Does a Google websearch, distributed across a list of Searx search proxies.}
  spec.description   = %q{Does a Google websearch, distributed across a list of Searx search proxies.}
  spec.homepage      = 'https://www.github.com/aantix/distributed_search'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
