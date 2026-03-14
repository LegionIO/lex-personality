# frozen_string_literal: true

require_relative 'lib/legion/extensions/personality/version'

Gem::Specification.new do |spec|
  spec.name          = 'legion-extensions-personality'
  spec.version       = Legion::Extensions::Personality::VERSION
  spec.authors       = ['Matthew Iverson']
  spec.email         = ['matt@legionIO.com']
  spec.summary       = 'Emergent personality traits for LegionIO cognitive agents'
  spec.description   = 'Big Five personality model emerging from accumulated cognitive behavior patterns'
  spec.homepage      = 'https://github.com/LegionIO/lex-personality'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
