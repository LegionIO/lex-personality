# frozen_string_literal: true

RSpec.describe Legion::Extensions::Personality::Helpers::TraitModel do
  subject(:model) { described_class.new }

  describe '#initialize' do
    it 'starts all traits at 0.5' do
      Legion::Extensions::Personality::Helpers::Constants::TRAITS.each do |trait|
        expect(model.trait(trait)).to eq(0.5)
      end
    end

    it 'starts with zero observation count' do
      expect(model.observation_count).to eq(0)
    end

    it 'starts with empty history' do
      expect(model.history).to be_empty
    end
  end

  describe '#update' do
    it 'increments observation count' do
      model.update(curiosity_intensity: 0.8)
      expect(model.observation_count).to eq(1)
    end

    it 'shifts openness with curiosity signals' do
      10.times { model.update(curiosity_intensity: 0.9, novel_domains: 0.8) }
      expect(model.trait(:openness)).to be > 0.5
    end

    it 'shifts conscientiousness with accuracy signals' do
      10.times { model.update(prediction_accuracy: 0.95, habit_automatic_ratio: 0.7) }
      expect(model.trait(:conscientiousness)).to be > 0.5
    end

    it 'shifts neuroticism with volatility signals' do
      10.times { model.update(emotional_volatility: 0.9, anxiety_frequency: 0.8) }
      expect(model.trait(:neuroticism)).to be > 0.5
    end

    it 'ignores nil values' do
      model.update(curiosity_intensity: nil)
      expect(model.observation_count).to eq(0)
    end

    it 'records snapshots in history' do
      model.update(curiosity_intensity: 0.8)
      expect(model.history.size).to eq(1)
    end
  end

  describe '#formed?' do
    it 'returns false before formation threshold' do
      expect(model.formed?).to be false
    end

    it 'returns true after enough observations' do
      Legion::Extensions::Personality::Helpers::Constants::FORMATION_THRESHOLD.times do
        model.update(curiosity_intensity: 0.7)
      end
      expect(model.formed?).to be true
    end
  end

  describe '#dominant_trait' do
    it 'returns the trait furthest from neutral' do
      20.times { model.update(curiosity_intensity: 0.95, novel_domains: 0.9) }
      expect(model.dominant_trait).to eq(:openness)
    end
  end

  describe '#trait_level' do
    it 'returns :mid for default trait values' do
      expect(model.trait_level(:openness)).to eq(:mid)
    end

    it 'returns :high for elevated traits' do
      50.times { model.update(curiosity_intensity: 0.99, novel_domains: 0.99) }
      expect(model.trait_level(:openness)).to eq(:high)
    end

    it 'returns nil for unknown trait' do
      expect(model.trait_level(:nonexistent)).to be_nil
    end
  end

  describe '#describe' do
    it 'returns descriptor string for known trait' do
      desc = model.describe(:openness)
      expect(desc).to be_a(String)
    end

    it 'returns nil for unknown trait' do
      expect(model.describe(:nonexistent)).to be_nil
    end
  end

  describe '#profile' do
    it 'returns all 5 traits' do
      p = model.profile
      expect(p.keys.size).to eq(5)
      Legion::Extensions::Personality::Helpers::Constants::TRAITS.each do |t|
        expect(p).to have_key(t)
      end
    end

    it 'rounds values to 3 decimal places' do
      model.update(curiosity_intensity: 0.8)
      p = model.profile
      p.each_value do |v|
        expect(v.to_s.split('.').last&.length || 0).to be <= 3
      end
    end
  end

  describe '#stability' do
    it 'returns 0.0 with insufficient history' do
      expect(model.stability).to eq(0.0)
    end

    it 'returns high stability with consistent inputs' do
      10.times { model.update(curiosity_intensity: 0.7) }
      expect(model.stability).to be > 0.5
    end
  end

  describe '#trend' do
    it 'returns :insufficient_data with few entries' do
      expect(model.trend(:openness)).to eq(:insufficient_data)
    end

    it 'detects increasing trend' do
      20.times { model.update(curiosity_intensity: 0.1, novel_domains: 0.1) }
      20.times { model.update(curiosity_intensity: 0.99, novel_domains: 0.99) }
      expect(model.trend(:openness)).to eq(:increasing)
    end
  end

  describe '#to_h' do
    it 'returns complete state hash' do
      h = model.to_h
      expect(h).to include(:traits, :observation_count, :formed, :stability,
                           :dominant_trait, :history_size)
    end
  end
end
