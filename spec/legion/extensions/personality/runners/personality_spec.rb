# frozen_string_literal: true

RSpec.describe Legion::Extensions::Personality::Runners::Personality do
  let(:client) { Legion::Extensions::Personality::Client.new }

  describe '#update_personality' do
    it 'returns update result' do
      result = client.update_personality(tick_results: {
                                           working_memory_integration: { intensity: 0.7 }
                                         })
      expect(result[:updated]).to be true
      expect(result).to include(:observation_count, :formed, :profile, :dominant_trait)
    end

    it 'handles empty tick results' do
      result = client.update_personality(tick_results: {})
      expect(result[:updated]).to be true
    end
  end

  describe '#personality_profile' do
    it 'returns profile with all traits' do
      result = client.personality_profile
      expect(result[:traits].keys.size).to eq(5)
      expect(result).to include(:formed, :stability, :dominant, :observations)
    end
  end

  describe '#describe_personality' do
    it 'returns description' do
      result = client.describe_personality
      expect(result[:description]).to be_a(String)
      expect(result).to have_key(:formed)
    end
  end

  describe '#trait_detail' do
    it 'returns detail for known trait' do
      result = client.trait_detail(trait: :openness)
      expect(result[:trait]).to eq(:openness)
      expect(result).to include(:value, :level, :description, :trend)
    end

    it 'returns error for unknown trait' do
      result = client.trait_detail(trait: :nonexistent)
      expect(result[:error]).to eq(:unknown_trait)
    end
  end

  describe '#personality_compatibility' do
    it 'scores compatibility with another profile' do
      other = { openness: 0.5, conscientiousness: 0.5, extraversion: 0.5,
                agreeableness: 0.5, neuroticism: 0.5 }
      result = client.personality_compatibility(other_profile: other)
      expect(result[:compatibility]).to be_a(Numeric)
      expect(result[:interpretation]).to be_a(Symbol)
    end
  end

  describe '#personality_stats' do
    it 'returns stats summary' do
      result = client.personality_stats
      expect(result).to include(:observation_count, :formed, :stability,
                                :dominant_trait, :profile, :trait_trends)
    end
  end
end
