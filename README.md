# lex-personality

Emergent personality traits for LegionIO's cognitive architecture.

## Overview

Implements the Big Five (OCEAN) personality model as emergent properties rather than configuration. Personality traits develop over time from accumulated cognitive behavior: an agent that explores novel domains develops high Openness; one that maintains low error rates develops high Conscientiousness.

## The Big Five

- **Openness**: Curiosity, novelty seeking, domain breadth
- **Conscientiousness**: Reliability, error avoidance, consistency
- **Extraversion**: Social engagement, communication frequency, mesh activity
- **Agreeableness**: Cooperation, trust extension, conflict avoidance
- **Neuroticism**: Emotional volatility, anxiety frequency, stress sensitivity

## Usage

```ruby
client = Legion::Extensions::Personality::Client.new

# Update traits from tick behavior
client.update_personality(tick_results: { ... })

# Get personality profile
client.personality_profile
# => { openness: 0.72, conscientiousness: 0.85, ... }

# Get trait description
client.describe_personality
# => "Highly curious and open to new experiences. Very reliable and consistent..."
```
