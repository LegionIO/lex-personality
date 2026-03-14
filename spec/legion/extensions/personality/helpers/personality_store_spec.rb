# frozen_string_literal: true

RSpec.describe Legion::Extensions::Personality::Helpers::PersonalityStore do
  subject(:store) { described_class.new }

  describe '#update' do
    it 'delegates to the trait model' do
      store.update(curiosity: { intensity: 0.8 })
      expect(store.model.observation_count).to be >= 0
    end

    it 'extracts signals from tick results' do
      store.update(
        working_memory_integration: { intensity: 0.8, wonder_count: 5 },
        prediction_engine:          { accuracy: 0.9 },
        mesh_interface:             { message_count: 10 },
        emotional_evaluation:       { volatility: 0.3 },
        mood:                       { stability: 0.8 }
      )
      expect(store.model.observation_count).to eq(1)
    end
  end

  describe '#full_description' do
    it 'returns not-formed message before threshold' do
      desc = store.full_description
      expect(desc).to include('not yet formed')
    end

    it 'returns trait descriptions after formation' do
      Legion::Extensions::Personality::Helpers::Constants::FORMATION_THRESHOLD.times do
        store.update(
          working_memory_integration: { intensity: 0.9, wonder_count: 8 },
          prediction_engine:          { accuracy: 0.95 }
        )
      end
      desc = store.full_description
      expect(desc).not_to include('not yet formed')
      expect(desc).to be_a(String)
    end
  end

  describe '#compatibility_score' do
    it 'returns nil for non-hash input' do
      expect(store.compatibility_score('invalid')).to be_nil
    end

    it 'returns 1.0 for identical profiles' do
      profile = store.model.profile
      score = store.compatibility_score(profile)
      expect(score).to eq(1.0)
    end

    it 'returns lower score for divergent profiles' do
      opposite = {
        openness:          0.0,
        conscientiousness: 0.0,
        extraversion:      0.0,
        agreeableness:     0.0,
        neuroticism:       0.0
      }
      score = store.compatibility_score(opposite)
      expect(score).to be < 1.0
    end
  end
end
