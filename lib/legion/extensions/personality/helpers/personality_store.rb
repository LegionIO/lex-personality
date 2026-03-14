# frozen_string_literal: true

module Legion
  module Extensions
    module Personality
      module Helpers
        class PersonalityStore
          attr_reader :model

          def initialize
            @model = TraitModel.new
          end

          def update(tick_results)
            signals = extract_signals(tick_results)
            @model.update(signals)
          end

          def full_description
            return 'Personality not yet formed — insufficient observations.' unless @model.formed?

            parts = Constants::TRAITS.filter_map do |trait|
              @model.describe(trait)
            end
            "#{parts.join('. ')}."
          end

          def compatibility_score(other_profile)
            return nil unless other_profile.is_a?(Hash)

            diffs = Constants::TRAITS.map do |trait|
              mine = @model.trait(trait) || 0.5
              theirs = other_profile[trait] || 0.5
              (mine - theirs).abs
            end
            avg_diff = diffs.sum / diffs.size.to_f
            (1.0 - avg_diff).round(3)
          end

          private

          def extract_signals(tick_results)
            signals = {}

            signals[:curiosity_intensity] = extract_curiosity(tick_results)
            signals[:novel_domains] = extract_novelty(tick_results)
            signals[:prediction_accuracy] = extract_prediction(tick_results)
            signals[:error_rate] = extract_error_rate(tick_results)
            signals[:mesh_message_count] = extract_mesh(tick_results)
            signals[:empathy_model_count] = extract_empathy(tick_results)
            signals[:cooperation_ratio] = extract_cooperation(tick_results)
            signals[:conflict_frequency] = extract_conflict(tick_results)
            signals[:emotional_volatility] = extract_volatility(tick_results)
            signals[:mood_stability] = extract_mood_stability(tick_results)

            signals.compact
          end

          def extract_curiosity(tick_results)
            tick_results.dig(:working_memory_integration, :intensity) ||
              tick_results.dig(:curiosity, :intensity)
          end

          def extract_novelty(tick_results)
            count = tick_results.dig(:working_memory_integration, :wonder_count) ||
                    tick_results.dig(:curiosity, :wonder_count)
            return nil unless count.is_a?(Numeric)

            (count / 10.0).clamp(0.0, 1.0)
          end

          def extract_prediction(tick_results)
            tick_results.dig(:prediction_engine, :accuracy) ||
              tick_results.dig(:prediction, :accuracy)
          end

          def extract_error_rate(tick_results)
            accuracy = extract_prediction(tick_results)
            return nil unless accuracy.is_a?(Numeric)

            1.0 - accuracy
          end

          def extract_mesh(tick_results)
            count = tick_results.dig(:mesh_interface, :message_count) ||
                    tick_results.dig(:mesh, :message_count)
            return nil unless count.is_a?(Numeric)

            (count / 20.0).clamp(0.0, 1.0)
          end

          def extract_empathy(tick_results)
            count = tick_results.dig(:empathy, :model_count)
            return nil unless count.is_a?(Numeric)

            (count / 10.0).clamp(0.0, 1.0)
          end

          def extract_cooperation(tick_results)
            tick_results.dig(:empathy, :cooperation_ratio)
          end

          def extract_conflict(tick_results)
            count = tick_results.dig(:conflict, :active_count)
            return nil unless count.is_a?(Numeric)

            (count / 5.0).clamp(0.0, 1.0)
          end

          def extract_volatility(tick_results)
            tick_results.dig(:emotional_evaluation, :volatility) ||
              tick_results.dig(:emotion, :volatility)
          end

          def extract_mood_stability(tick_results)
            tick_results.dig(:mood, :stability)
          end
        end
      end
    end
  end
end
