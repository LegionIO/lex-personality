# frozen_string_literal: true

RSpec.describe Legion::Extensions::Personality::Helpers::Constants do
  it 'defines 5 traits (OCEAN)' do
    expect(described_class::TRAITS.size).to eq(5)
  end

  it 'includes all Big Five traits' do
    expect(described_class::TRAITS).to contain_exactly(
      :openness, :conscientiousness, :extraversion, :agreeableness, :neuroticism
    )
  end

  it 'has default trait value of 0.5' do
    expect(described_class::DEFAULT_TRAIT_VALUE).to eq(0.5)
  end

  it 'has a very low trait alpha for stability' do
    expect(described_class::TRAIT_ALPHA).to be < 0.1
  end

  it 'defines descriptors for every trait' do
    described_class::TRAITS.each do |trait|
      expect(described_class::TRAIT_DESCRIPTORS).to have_key(trait)
      expect(described_class::TRAIT_DESCRIPTORS[trait]).to include(:high, :mid, :low)
    end
  end

  it 'maps signals to traits' do
    expect(described_class::SIGNAL_MAP).not_to be_empty
    described_class::SIGNAL_MAP.each_value do |trait, direction, weight|
      expect(described_class::TRAITS).to include(trait)
      expect(%i[positive negative]).to include(direction)
      expect(weight).to be_between(0.0, 1.0)
    end
  end

  it 'has HIGH_THRESHOLD > LOW_THRESHOLD' do
    expect(described_class::HIGH_THRESHOLD).to be > described_class::LOW_THRESHOLD
  end
end
