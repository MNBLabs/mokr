# /implement — Core Implementation

Read `docs/architecture.md`, `docs/api-design.md`, and all context files before writing code.

Implement in this exact order. Do not skip ahead. Each step depends on the previous.

---

## Step 1 — Scaffold
```bash
flutter create --template=package mokr
```
Set up `pubspec.yaml`:
```yaml
name: mokr
description: >-
  Realistic mock data and images for Flutter UI development.
  Stable users, posts, feeds, and images — no backend needed.
  For development and prototyping only.
version: 0.1.0
homepage: https://mokr.dynshift.com
repository: https://github.com/MNBLabs/mokr
issue_tracker: https://github.com/MNBLabs/mokr/issues
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.0
```

---

## Step 2 — `lib/src/core/seed_hash.dart`
Implement FNV-1a 32-bit hash in pure Dart.
Returns non-negative int from any String.
Must be a static utility class — no instantiation.
```dart
// Must pass:
assert(SeedHash.hash('user_0') != SeedHash.hash('user_1'));
assert(SeedHash.hash('') >= 0);
assert(SeedHash.hash('a' * 10000) >= 0);  // handles long strings
assert(SeedHash.hash('x') == SeedHash.hash('x'));  // stable
```

## Step 3 — `lib/src/core/seeded_rng.dart`
Wrap `dart:math` Random with a seeded constructor.
```dart
class SeededRng {
  SeededRng(String seed) : _rng = Random(SeedHash.hash(seed));

  int nextInt(int max);
  int nextIntInRange(int min, int max);
  double nextDouble();
  bool nextBool({double probability = 0.5});
  T pick<T>(List<T> list);        // picks deterministically from list
  List<T> pickMany<T>(List<T> list, int count); // picks n unique items
}
```

## Step 4 — `lib/src/core/distribution.dart`
Statistical helpers. All take a SeededRng instance.
```dart
// Power-law: most values low, some very high — for followers
int powerLawInt(SeededRng rng, {int min, int max, double exponent = 2.0});

// Recency-weighted: more likely to be recent — for timestamps
DateTime recencyDate(SeededRng rng, {int maxDaysAgo = 365});

// Normal approximation: bell curve around mean — for like counts
int normalInt(SeededRng rng, {required int mean, required int stddev});
```

## Step 5 — `lib/src/core/slot_registry.dart`
The persistence layer for slot/pin system.
```dart
class SlotRegistry {
  static SlotRegistry? _instance;
  static SlotRegistry get instance => _instance!;

  static Future<void> init() async { ... }  // loads from SharedPreferences

  String getOrCreate(String slot);          // returns existing or generates new seed
  void pin(String slot);                    // marks slot as pinned
  Future<void> clear(String slot);          // removes unpinned slot
  Future<void> clearPin(String slot);       // removes pinned slot explicitly
  Future<void> clearAll();                  // removes all unpinned slots
  bool isPinned(String slot);
}
```
SharedPreferences keys: `'mokr_slots'` (JSON), `'mokr_pins'` (JSON list).
Write to disk on every mutation. Read once on init.

## Step 6 — Data Tables (`lib/src/data/tables/`)
All are `const List<String>`. No logic.
- `first_names.dart` — 300+ names, diverse (English, Japanese, Spanish, Arabic, Indian, African)
- `last_names.dart` — 300+ surnames, diverse
- `bio_phrases.dart` — 100+ sentence fragments for bios
- `caption_phrases.dart` — 150+ caption starters and middles
- `hashtags.dart` — 150+ hashtags grouped by theme

## Step 7 — `lib/src/data/models/`
Implement `MockUser`, `MockPost`, `MockComment` as `@immutable` classes.
All fields `final`. Const constructors where possible.
Include all computed getters (`formattedFollowers`, `relativeTime`, etc.)

## Step 8 — `lib/src/data/generators/`
`UserGenerator.generate(String seed)` → `MockUser`
`PostGenerator.generate(String seed)` → `MockPost`
`FeedGenerator.page(String seed, int page, int pageSize)` → `List<MockPost>`

Each generator creates a `SeededRng(seed)` internally.
Consumes fields in the exact order defined in `docs/architecture.md`.
Never deviates from consumption order.

## Step 9 — `lib/src/images/`
Implement abstract `MokrImageProvider` + `UnsplashMokrImageProvider` + `PicsumMokrImageProvider`.
All URL methods are sync. All return valid HTTPS strings. Never throw.
`sig = SeedHash.hash(seed) % 9999`

## Step 10 — `lib/src/mokr_impl.dart`
Internal singleton. Holds: SlotRegistry reference, MokrImageProvider instance.
Implements all four modes for user/post:
```dart
MockUser resolveUser({String? seed, String? slot, bool pin = false}) {
  if (seed != null) return UserGenerator.generate(seed);
  if (slot != null) {
    final resolvedSeed = SlotRegistry.instance.getOrCreate(slot);
    if (pin) SlotRegistry.instance.pin(slot);
    return UserGenerator.generate(resolvedSeed);
  }
  // fresh random
  final freshSeed = _generateFreshSeed();
  _debugLog('🎲 fresh → seed: $freshSeed');
  return UserGenerator.generate(freshSeed);
}
```

## Step 11 — `lib/mokr.dart`
Public facade. Static methods only. All delegate to MokrImpl.
This is the ONLY file developers import.
```dart
import 'package:mokr/mokr.dart';
```

---

## Quality Gates Before Phase Complete
```bash
dart analyze lib/
dart format --set-exit-if-changed lib/
dart test test/core/ test/data/ test/images/
```
Zero warnings. Zero format issues. All tests pass.
