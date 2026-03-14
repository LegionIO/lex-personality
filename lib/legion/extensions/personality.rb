# frozen_string_literal: true

require_relative 'personality/version'
require_relative 'personality/helpers/constants'
require_relative 'personality/helpers/trait_model'
require_relative 'personality/helpers/personality_store'
require_relative 'personality/runners/personality'
require_relative 'personality/client'

module Legion
  module Extensions
    module Personality
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
