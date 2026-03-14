# frozen_string_literal: true

module Legion
  module Extensions
    module Personality
      module Helpers
        class TraitModel
          attr_reader :traits, :observation_count, :history

          def initialize
            @traits = Constants::TRAITS.to_h do |trait|
              [trait, Constants::DEFAULT_TRAIT_VALUE]
            end
            @observation_count = 0
            @history = []
          end

          def update(signals)
            observations = extract_observations(signals)
            return if observations.empty?

            apply_observations(observations)
            @observation_count += 1
            record_snapshot
          end

          def trait(name)
            @traits[name.to_sym]
          end

          def formed?
            @observation_count >= Constants::FORMATION_THRESHOLD
          end

          def dominant_trait
            @traits.max_by { |_k, v| (v - 0.5).abs }&.first
          end

          def trait_level(name)
            value = @traits[name.to_sym]
            return nil unless value

            if value >= Constants::HIGH_THRESHOLD
              :high
            elsif value <= Constants::LOW_THRESHOLD
              :low
            else
              :mid
            end
          end

          def describe(name)
            level = trait_level(name)
            return nil unless level

            Constants::TRAIT_DESCRIPTORS.dig(name.to_sym, level)
          end

          def profile
            @traits.transform_values { |v| v.round(3) }
          end

          def stability
            return 0.0 if @history.size < 5

            recent = @history.last(10)
            variances = Constants::TRAITS.map do |t|
              values = recent.map { |h| h[:traits][t] }
              mean = values.sum / values.size.to_f
              values.map { |v| (v - mean)**2 }.sum / values.size.to_f
            end
            avg_variance = variances.sum / variances.size.to_f
            (1.0 - (avg_variance * 10)).clamp(0.0, 1.0)
          end

          def trend(name)
            return :insufficient_data if @history.size < 5

            values = @history.last(10).map { |h| h[:traits][name.to_sym] }
            first_half = values[0...(values.size / 2)]
            second_half = values[(values.size / 2)..]
            diff = (second_half.sum / second_half.size.to_f) - (first_half.sum / first_half.size.to_f)

            if diff > 0.02
              :increasing
            elsif diff < -0.02
              :decreasing
            else
              :stable
            end
          end

          def to_h
            {
              traits:            profile,
              observation_count: @observation_count,
              formed:            formed?,
              stability:         stability,
              dominant_trait:    dominant_trait,
              history_size:      @history.size
            }
          end

          private

          def extract_observations(signals)
            observations = Hash.new { |h, k| h[k] = [] }

            Constants::SIGNAL_MAP.each do |signal_key, (trait, direction, weight)|
              value = signals[signal_key]
              next unless value.is_a?(Numeric)

              effective = direction == :positive ? value : 1.0 - value
              observations[trait] << { value: effective, weight: weight }
            end

            observations
          end

          def apply_observations(observations)
            observations.each do |trait, obs_list|
              weighted_sum = obs_list.sum { |o| o[:value] * o[:weight] }
              total_weight = obs_list.sum { |o| o[:weight] }
              next if total_weight.zero?

              target = (weighted_sum / total_weight).clamp(0.0, 1.0)
              @traits[trait] = ema(@traits[trait], target, Constants::TRAIT_ALPHA)
            end
          end

          def ema(current, observed, alpha)
            (current * (1.0 - alpha)) + (observed * alpha)
          end

          def record_snapshot
            @history << { traits: @traits.dup, at: Time.now.utc }
            @history.shift while @history.size > Constants::MAX_HISTORY
          end
        end
      end
    end
  end
end
