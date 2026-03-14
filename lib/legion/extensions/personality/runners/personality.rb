# frozen_string_literal: true

module Legion
  module Extensions
    module Personality
      module Runners
        module Personality
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def update_personality(tick_results: {}, **)
            personality_store.update(tick_results)
            model = personality_store.model

            {
              updated:           true,
              observation_count: model.observation_count,
              formed:            model.formed?,
              profile:           model.profile,
              dominant_trait:    model.dominant_trait
            }
          end

          def personality_profile(**)
            model = personality_store.model
            {
              traits:       model.profile,
              formed:       model.formed?,
              stability:    model.stability,
              dominant:     model.dominant_trait,
              observations: model.observation_count,
              history_size: model.history.size
            }
          end

          def describe_personality(**)
            {
              description: personality_store.full_description,
              formed:      personality_store.model.formed?
            }
          end

          def trait_detail(trait:, **)
            model = personality_store.model
            value = model.trait(trait)
            return { trait: trait.to_sym, error: :unknown_trait } unless value

            {
              trait:       trait.to_sym,
              value:       value.round(3),
              level:       model.trait_level(trait),
              description: model.describe(trait),
              trend:       model.trend(trait)
            }
          end

          def personality_compatibility(other_profile:, **)
            score = personality_store.compatibility_score(other_profile)
            {
              compatibility:  score,
              interpretation: interpret_compatibility(score)
            }
          end

          def personality_stats(**)
            model = personality_store.model
            {
              observation_count: model.observation_count,
              formed:            model.formed?,
              stability:         model.stability,
              dominant_trait:    model.dominant_trait,
              profile:           model.profile,
              history_size:      model.history.size,
              trait_trends:      Helpers::Constants::TRAITS.to_h { |t| [t, model.trend(t)] }
            }
          end

          private

          def interpret_compatibility(score)
            return :unknown unless score.is_a?(Numeric)

            if score >= 0.85
              :highly_compatible
            elsif score >= 0.7
              :compatible
            elsif score >= 0.5
              :neutral
            elsif score >= 0.3
              :divergent
            else
              :incompatible
            end
          end
        end
      end
    end
  end
end
