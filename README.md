# lex-personality

Big Five personality model for the LegionIO cognitive architecture. Traits emerge from observed behavior over time rather than being configured statically.

## What It Does

Maintains an OCEAN (openness, conscientiousness, extraversion, agreeableness, neuroticism) personality profile that evolves through observed cognitive signals. Trait values start neutral at 0.5 and drift very slowly via exponential moving average as the agent accumulates experience. After 100 observations the personality is considered "formed" and descriptive labels become reliable.

## The Big Five

- **Openness**: Curiosity, novelty seeking, domain breadth
- **Conscientiousness**: Reliability, error avoidance, consistency
- **Extraversion**: Social engagement, communication frequency, mesh activity
- **Agreeableness**: Cooperation, trust extension, conflict avoidance
- **Neuroticism**: Emotional volatility, anxiety frequency, stress sensitivity

## Usage

```ruby
client = Legion::Extensions::Personality::Client.new

# Update from tick results (observed behavior signals)
client.update_personality(tick_results: {
  curiosity_intensity:  0.8,
  prediction_accuracy:  0.7,
  mesh_message_count:   12,
  cooperation_ratio:    0.6
})

# Get full profile
client.personality_profile
# => {
#   traits: { openness: 0.52, conscientiousness: 0.54, extraversion: 0.51, ... },
#   formed: false,
#   stability: 0.98,
#   dominant: :openness
# }

# Describe in human terms
client.describe_personality
# => { description: "moderately exploratory, reasonably organized...", formed: false }

# Inspect a single trait
client.trait_detail(trait: :openness)
# => { value: 0.52, level: :mid, description: "moderately exploratory", trend: :increasing }

# Compare with another agent's profile
client.personality_compatibility(other_profile: { openness: 0.7, conscientiousness: 0.5,
                                                  extraversion: 0.4, agreeableness: 0.6,
                                                  neuroticism: 0.3 })
# => { compatibility: 0.82, interpretation: :compatible }
```

## Observed Signals (extracted from tick_results)

`curiosity_intensity`, `novel_domains`, `prediction_accuracy`, `habit_automatic_ratio`, `error_rate`, `mesh_message_count`, `empathy_model_count`, `cooperation_ratio`, `trust_extension_rate`, `conflict_frequency`, `emotional_volatility`, `anxiety_frequency`, `mood_stability`

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
