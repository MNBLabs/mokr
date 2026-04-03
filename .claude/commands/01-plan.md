# /plan — Architecture Planning

Read `.claude/CLAUDE.md`, all three context files, before writing anything.

Your output: `docs/architecture.md`

---

## Required Sections

### 1. System Diagram
ASCII or Mermaid. Show data flow from developer call → seed hash → generator → model → widget.
Include: SlotRegistry, SharedPreferences, MokrImageProvider, debug logger.

### 2. The Seed Pipeline
Walk through exactly what happens for each of the four modes:
```
Mokr.user('seed')                         → Mode 1 (deterministic)
Mokr.randomUser(slot: 'x')               → Mode 2 (stable random)
Mokr.randomUser(slot: 'x', pin: true)    → Mode 3 (pinned)
Mokr.randomUser()                         → Mode 4 (fresh random)
```
For each: what is called, what is checked, what is written, what is returned.

### 3. SlotRegistry Design
How `Map<String, String>` and `Set<String>` are persisted.
SharedPreferences key names. Serialisation format.
Thread safety: is it safe to call randomUser() concurrently?
What happens if init() is not called — fail loudly or silently?

### 4. Hash Function Decision
Evaluate FNV-1a 32-bit vs djb2. Choose one. Justify.
Requirements: pure Dart, no FFI, fast (callable on every build()), good distribution.
Include: collision rate test plan across 10,000 sequential keys.

### 5. RNG Consumption Order
Document the exact field generation order for MockUser and MockPost.
This is a semver-stability contract. Once published, this order cannot change without a major bump.
Reference the draft in design-principles.md and finalise it here.

### 6. Data Generation Strategy
Name generation: word list approach. How diverse? How large?
Numeric distributions: power-law for followers, recency-weighted for timestamps.
Include the formula or approach for each distribution.

### 7. Image Provider Architecture
Class diagram: MokrImageProvider (abstract) → UnsplashMokrImageProvider / PicsumMokrImageProvider.
How the provider is stored and accessed globally.
How sig is derived from seed.

### 8. Widget Architecture
How MokrAvatar resolves which seed to use (seed vs slot vs fresh random).
How loading/error states are managed (StatefulWidget for image loading).
Why MokrShimmer is internal and not exported.

### 9. Debug Logger
What triggers a log. Format of each log line.
How kDebugMode guard is implemented.
Confirm: zero output in release (assert kills execution first anyway).

### 10. Dependency Decisions
List every external dependency with justification.
Target: `shared_preferences` only. Everything else: stdlib.
Confirm: no http package (URLs are constructed, not fetched).

### 11. Testing Strategy
How to verify determinism: same seed, 10,000 runs, assert identical output.
How to test SlotRegistry: mock SharedPreferences.
How to test widgets: flutter_test with pump().
