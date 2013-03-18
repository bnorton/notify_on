# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'notify_on/version'

Gem::Specification.new do |spec|
  spec.name          = 'notify_on'
  spec.version       = NotifyOn::VERSION
  spec.authors       = ['Brian Norton']
  spec.email         = ['brian.nort@gmail.com']
  spec.description   = 'Notifications (webhooks) for model attribute changes'
  spec.summary       = ''
  spec.homepage      = 'http://github.com/bnorton/notify_on'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency             'micro_q', '~> 0.8'
  spec.add_dependency             'typhoeus', '~> 0.6'
  spec.add_dependency             'activerecord', '~> 3.2'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'sqlite3'
end
