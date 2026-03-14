# frozen_string_literal: true

module Legion
  module Extensions
    module Personality
      class Client
        include Runners::Personality

        attr_reader :personality_store

        def initialize(personality_store: nil, **)
          @personality_store = personality_store || Helpers::PersonalityStore.new
        end
      end
    end
  end
end
