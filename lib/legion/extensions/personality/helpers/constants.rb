# frozen_string_literal: true

module Legion
  module Extensions
    module Personality
      module Helpers
        module Constants
          # The Big Five personality dimensions (OCEAN)
          TRAITS = %i[openness conscientiousness extraversion agreeableness neuroticism].freeze

          # Starting values — neutral personality (0.5 = average on each trait)
          DEFAULT_TRAIT_VALUE = 0.5

          # EMA alpha for trait updates — very slow (personality is stable)
          TRAIT_ALPHA = 0.02

          # Minimum observations before personality is considered "formed"
          FORMATION_THRESHOLD = 100

          # Maximum trait history entries
          MAX_HISTORY = 200

          # Trait descriptors for each level
          TRAIT_DESCRIPTORS = {
            openness:          {
              high: 'highly curious and open to new experiences',
              mid:  'moderately exploratory',
              low:  'preferring familiar approaches and known domains'
            },
            conscientiousness: {
              high: 'very reliable, consistent, and detail-oriented',
              mid:  'reasonably organized and dependable',
              low:  'flexible but sometimes inconsistent'
            },
            extraversion:      {
              high: 'socially engaged, frequently communicating with other agents',
              mid:  'balanced between collaboration and independent work',
              low:  'preferring independent work with minimal social interaction'
            },
            agreeableness:     {
              high: 'cooperative, trusting, and conflict-averse',
              mid:  'balanced between cooperation and independent judgment',
              low:  'assertive and willing to challenge others'
            },
            neuroticism:       {
              high: 'emotionally sensitive, prone to anxiety under stress',
              mid:  'moderately resilient to emotional fluctuation',
              low:  'emotionally stable and stress-resistant'
            }
          }.freeze

          # Signal extraction: maps tick_results keys to trait influences
          # Each entry: [trait, direction, weight]
          # direction: :positive means high signal increases trait, :negative means high signal decreases it
          SIGNAL_MAP = {
            curiosity_intensity:   [:openness, :positive, 0.3],
            novel_domains:         [:openness, :positive, 0.4],
            prediction_accuracy:   [:conscientiousness, :positive, 0.3],
            habit_automatic_ratio: [:conscientiousness, :positive, 0.3],
            error_rate:            [:conscientiousness, :negative, 0.4],
            mesh_message_count:    [:extraversion, :positive, 0.4],
            empathy_model_count:   [:extraversion, :positive, 0.3],
            cooperation_ratio:     [:agreeableness, :positive, 0.4],
            trust_extension_rate:  [:agreeableness, :positive, 0.3],
            conflict_frequency:    [:agreeableness, :negative, 0.3],
            emotional_volatility:  [:neuroticism, :positive, 0.4],
            anxiety_frequency:     [:neuroticism, :positive, 0.3],
            mood_stability:        [:neuroticism, :negative, 0.3]
          }.freeze

          # Threshold for "high" trait descriptor
          HIGH_THRESHOLD = 0.65

          # Threshold for "low" trait descriptor
          LOW_THRESHOLD = 0.35
        end
      end
    end
  end
end
