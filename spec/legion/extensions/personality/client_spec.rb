# frozen_string_literal: true

RSpec.describe Legion::Extensions::Personality::Client do
  it 'creates default personality store' do
    client = described_class.new
    expect(client.personality_store).to be_a(Legion::Extensions::Personality::Helpers::PersonalityStore)
  end

  it 'accepts injected personality store' do
    store = Legion::Extensions::Personality::Helpers::PersonalityStore.new
    client = described_class.new(personality_store: store)
    expect(client.personality_store).to equal(store)
  end

  it 'includes Personality runner methods' do
    client = described_class.new
    expect(client).to respond_to(:update_personality, :personality_profile,
                                 :describe_personality, :personality_stats)
  end
end
