# /agent:seed — Seed Engine Specialist

Focus: `lib/src/core/` only. Do not touch anything else.

Read `.claude/context/design-principles.md` Consumption Order Contract before writing.

Deliverables:
- `lib/src/core/seed_hash.dart` — FNV-1a 32-bit, pure Dart
- `lib/src/core/seeded_rng.dart` — seeded Random wrapper with pick<T>, pickMany<T>
- `lib/src/core/distribution.dart` — powerLawInt, recencyDate, normalInt
- `lib/src/core/slot_registry.dart` — SharedPreferences-backed slot map
- `test/core/` — full test coverage

Quality gates:
- 10,000 sequential seeds → 0 hash collisions
- Same seed → identical MockUser across 10,000 generations
- Consumption order documented in `docs/consumption-order.md`
- `dart test test/core/` all passing
