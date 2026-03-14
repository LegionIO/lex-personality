# lex-personality

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-personality`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::Personality`

## Purpose

Big Five (OCEAN) personality model that emerges from observed behavior over time. Trait values start neutral at 0.5 and drift via EMA (`TRAIT_ALPHA = 0.02`, very slow) as signals from tick results are observed. After 100 observations the personality is considered "formed". Supports trait-level description, trend analysis, and compatibility scoring with other profiles.

## Gem Info

- **Homepage**: https://github.com/LegionIO/lex-personality
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/personality/
  version.rb
  client.rb
  helpers/
    constants.rb          # TRAITS, TRAIT_ALPHA, SIGNAL_MAP, descriptors, thresholds
    trait_model.rb        # TraitModel — EMA updates, stability, trend, profile
    personality_store.rb  # PersonalityStore — wraps TraitModel + compatibility scoring
  runners/
    personality.rb        # Runner module
spec/
  helpers/constants_spec.rb
  helpers/trait_model_spec.rb
  helpers/personality_store_spec.rb
  runners/personality_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `TRAITS = %i[openness conscientiousness extraversion agreeableness neuroticism]`
- `DEFAULT_TRAIT_VALUE = 0.5`, `TRAIT_ALPHA = 0.02`, `FORMATION_THRESHOLD = 100`, `MAX_HISTORY = 200`
- `HIGH_THRESHOLD = 0.65`, `LOW_THRESHOLD = 0.35`
- `TRAIT_DESCRIPTORS`: per-trait descriptors for `:high`, `:mid`, `:low` levels
- `SIGNAL_MAP`: maps tick_result keys to `[trait, direction, weight]` triples:
  - `curiosity_intensity` -> `[:openness, :positive, 0.3]`
  - `novel_domains` -> `[:openness, :positive, 0.4]`
  - `prediction_accuracy` -> `[:conscientiousness, :positive, 0.3]`
  - `habit_automatic_ratio` -> `[:conscientiousness, :positive, 0.3]`
  - `error_rate` -> `[:conscientiousness, :negative, 0.4]`
  - `mesh_message_count` -> `[:extraversion, :positive, 0.4]`
  - `cooperation_ratio` -> `[:agreeableness, :positive, 0.4]`
  - `conflict_frequency` -> `[:agreeableness, :negative, 0.3]`
  - `emotional_volatility` -> `[:neuroticism, :positive, 0.4]`
  - `mood_stability` -> `[:neuroticism, :negative, 0.3]`

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `update_personality` | `tick_results: {}` | `{ updated:, observation_count:, formed:, profile:, dominant_trait: }` |
| `personality_profile` | — | `{ traits:, formed:, stability:, dominant:, observations:, history_size: }` |
| `describe_personality` | — | `{ description: (full text), formed: }` |
| `trait_detail` | `trait:` | `{ trait:, value:, level:, description:, trend: }` |
| `personality_compatibility` | `other_profile: {}` | `{ compatibility:, interpretation: }` |
| `personality_stats` | — | full stats including trait trends |

## Helpers

### `Helpers::TraitModel`
Core EMA model. `update(signals)` extracts from `SIGNAL_MAP`, computes weighted average per trait, applies EMA. `formed?` = `observation_count >= FORMATION_THRESHOLD`. `dominant_trait` = trait with largest deviation from 0.5. `stability` = 1 - (10 * average variance over last 10 snapshots), clamped 0–1. `trend(name)` = `:increasing`, `:decreasing`, or `:stable` based on first-half vs second-half average over last 10 snapshots.

### `Helpers::PersonalityStore`
Wraps `TraitModel`. `full_description` builds a prose description from all trait descriptors. `compatibility_score(other_profile)` computes mean absolute difference across traits and returns 1 - avg_diff.

## Integration Points

- `update_personality` consumes `tick_results` directly from `lex-tick`
- `curiosity_intensity` signal sourced from `lex-tick`'s working memory or curiosity phase
- `mesh_message_count` signal sourced from `lex-mesh` activity
- `emotional_volatility` signal sourced from `lex-emotion` stability output
- `personality_compatibility` can inform `lex-trust` scoring when evaluating new agents
- `dominant_trait` can bias `lex-planning` toward certain action styles

## Development Notes

- `TRAIT_ALPHA = 0.02` is intentionally very slow: personality changes require hundreds of observations
- Negative signals: `:negative` direction computes `effective = 1.0 - value` before EMA update
- `SIGNAL_MAP` extraction skips non-numeric signal values
- Compatibility: `1.0 - mean_abs_diff`; interpretation: `:highly_compatible` (>=0.85), `:compatible`, `:neutral`, `:divergent`, `:incompatible`
- State is fully in-memory; reset on process restart
