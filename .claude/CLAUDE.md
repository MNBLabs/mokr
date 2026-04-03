# mokr — Flutter UI Mocking Toolkit
## Claude Code Master Context

---

## What This Is

**mokr** is a Flutter package that provides realistic mock data and images for UI development.
It is a **frontend-first UI simulation toolkit** — not a random generator, not a test framework.

**The developer experience goal:**
> Drop one line anywhere in a widget tree. Get something realistic. Ship the prototype.

Publisher: MNBLabs (https://github.com/MNBLabs)
Collaborator: nishanbhuinya (https://github.com/nishanbhuinya)
Future home: DynShift org (if promoted)

---

## ⚠️ Non-Negotiable Constraints

### 1. Development Only
mokr must NEVER run in release builds. Hard guard in the entry point:
```dart
assert(() {
  // all mokr logic here
  return true;
}());
```
Or: `assert(!kReleaseMode, 'mokr must not be used in production builds.')` at Mokr.init().
README and pub.dev description must state this clearly upfront.

### 2. Determinism is the Foundation
Same input → same output, always. No flicker on hot reload. No changing data on rebuild.
This is not a feature. It is the law every piece of code must respect.

### 3. Simple API Over Clever Architecture
The internals can be as sophisticated as needed.
The API the developer touches must be dead simple.
If a feature requires more than one line to use, question whether the design is right.

### 4. No Redundancy
Every API method, parameter, and widget must have a unique job.
If two things do the same thing in slightly different ways, cut one.

---

## The Four Modes — Source of Truth

This is the complete behavioural model of mokr. Every design decision maps back here.

### Mode 1 — Fresh Random
```dart
Mokr.randomUser()
```
- No seed, no slot
- Generates a different result every call / every rebuild
- Nothing stored anywhere
- Use case: throwaway prototyping, browsing results quickly

### Mode 2 — Slot (Stable Random)
```dart
Mokr.randomUser(slot: 'card_1')
```
- Developer names this slot
- First call: generates a random seed → writes to disk via SharedPreferences
- Every call after: reads from disk → same result across hot reload, hot restart, phone restart
- Clearable: `Mokr.clearSlot('card_1')` or `Mokr.clearAll()`
- Use case: "This slot should stop flickering. I don't care which result, just freeze one."

### Mode 3 — Pinned Slot (Protected Stable Random)
```dart
Mokr.randomUser(slot: 'card_1', pin: true)
```
- Same as Mode 2, but protected from `Mokr.clearAll()`
- Only removable explicitly via `Mokr.clearPin('card_1')`
- Use case: "I like this result. Keep it even if I reset everything else."

### Mode 4 — Deterministic (Graduation Destination)
```dart
Mokr.user('mokr_a7Be')
```
- Developer owns the seed — baked directly into code
- No disk, no map, no init() required
- Same result across app installs, devices, forever
- Use case: "I want exactly this result, always, with zero runtime dependency."

### The Graduation Flow
```
Mode 1 (fresh random)
  → developer sees a result they like
  → console logs: [mokr] 🎲 fresh → seed: 'mokr_a7Be'  (debug only)
  → developer copies seed, swaps to Mode 4
  → OR: developer adds slot: 'name' → Mode 2 (result persists)
  → OR: developer adds pin: true → Mode 3 (result persists + protected)
```

---

## Package Identity

| Property | Value |
|---|---|
| Package name | `mokr` |
| Tagline | *Realistic mock data and images for Flutter UI.* |
| Fits DynShift naming | Yes — `layr`, `mokr` (short, lowercase, ends in r) |
| Primary audience | Flutter developers prototyping UI-heavy apps |
| Pub.dev topics | mock, ui, flutter, fake-data, testing |
| License | MIT |
| Min Flutter SDK | 3.10.0 |
| Min Dart SDK | 3.0.0 |

---

## Public API Shape (locked)

### Entry Point
```dart
// Required once in main()
await Mokr.init();
```

### Data Methods
```dart
// Deterministic
Mokr.user('seed')
Mokr.post('seed')
Mokr.feedPage('feed_seed', page: 0, pageSize: 20)

// With slot/pin
Mokr.randomUser()
Mokr.randomUser(slot: 'card_1')
Mokr.randomUser(slot: 'card_1', pin: true)

Mokr.randomPost()
Mokr.randomPost(slot: 'feed_hero')
```

### URL Methods (sync strings, no await)
```dart
Mokr.avatarUrl('seed', size: 80)
Mokr.imageUrl('seed', category: MokrCategory.nature, width: 400, height: 300)
Mokr.bannerUrl('seed', width: 800, height: 300)
```

### Slot Management
```dart
Mokr.clearSlot('card_1')   // wipe one unpinned slot → it will re-randomise
Mokr.clearPin('card_1')    // wipe one pinned slot → explicit intent required
Mokr.clearAll()            // wipe all unpinned slots → pinned ones survive
```

### Widgets
```dart
// Deterministic
MokrAvatar(seed: 'user_42', size: 48)
MokrImage(seed: 'post_1', category: MokrCategory.nature)
MokrPostCard(seed: 'post_0')
MokrUserTile(seed: 'user_42')

// Slot-based
MokrAvatar(slot: 'card_1', size: 48)
MokrImage(slot: 'hero', category: MokrCategory.travel)

// Fresh random
MokrAvatar(size: 48)
MokrImage(category: MokrCategory.food)
```

### Loading Awareness
```dart
MokrImage(
  seed: 'post_1',
  loadingBuilder: (context) => MyShimmer(),    // optional — mokr has default
  errorBuilder: (context) => MyErrorWidget(),  // optional — mokr has default
)
```

---

## Image Categories (all 15)
```dart
enum MokrCategory {
  // Social / content
  face,       // portraits — for avatars
  nature,
  travel,
  food,
  fashion,
  fitness,
  art,
  // Dev / tech
  technology,
  office,
  abstract_,  // trailing _ — 'abstract' is a Dart keyword
  // Product / commerce
  product,
  interior,
  // Other
  architecture,
  automotive,
  pets,
}
```

---

## Widget Composability Rules
All Mokr widgets are standard Flutter widgets.
They work as `child:` anywhere without wrappers:
```dart
// Inside Container
Container(child: MokrAvatar(seed: 'u1', size: 20))

// Inside Card
Card(child: MokrImage(slot: 'hero'))

// Inside ListView.builder
ListView.builder(
  itemBuilder: (ctx, i) => MokrPostCard(seed: 'feed_$i'),
)

// As NetworkImage source (URL mode)
CircleAvatar(
  backgroundImage: NetworkImage(Mokr.avatarUrl('user_42', size: 48)),
)
```

---

## Debug Console Behaviour
Only active in debug mode (`kDebugMode`).
Every fresh random logs its seed:
```
[mokr] 🎲 fresh → seed: 'mokr_a7Be'  (MokrAvatar)
[mokr] 📌 slot:'card_1' → seed: 'mokr_f2Dc' (from disk)
[mokr] 🔒 pin:'card_1' → seed: 'mokr_f2Dc' (protected)
```
Zero logs in release (the assert guard stops execution entirely).

---

## File Structure (target)
```
mokr/
├── lib/
│   ├── mokr.dart                        # Public barrel export ONLY
│   └── src/
│       ├── core/
│       │   ├── seed_hash.dart           # FNV-1a hash engine
│       │   ├── seeded_rng.dart          # Seeded Random wrapper
│       │   ├── distribution.dart        # Power-law, recency-weighted etc.
│       │   └── slot_registry.dart       # SharedPreferences slot map
│       ├── data/
│       │   ├── models/
│       │   │   ├── mock_user.dart
│       │   │   ├── mock_post.dart
│       │   │   └── mock_comment.dart
│       │   ├── generators/
│       │   │   ├── user_generator.dart
│       │   │   ├── post_generator.dart
│       │   │   └── feed_generator.dart
│       │   └── tables/
│       │       ├── first_names.dart
│       │       ├── last_names.dart
│       │       ├── bio_phrases.dart
│       │       ├── caption_phrases.dart
│       │       └── hashtags.dart
│       ├── images/
│       │   ├── mokr_image_provider.dart # Abstract interface
│       │   ├── unsplash_provider.dart   # Primary (no auth)
│       │   └── picsum_provider.dart     # Fallback
│       ├── widgets/
│       │   ├── mokr_avatar.dart
│       │   ├── mokr_image.dart
│       │   ├── mokr_post_card.dart
│       │   ├── mokr_user_tile.dart
│       │   └── internal/
│       │       └── mokr_shimmer.dart    # Internal only, not exported
│       └── mokr_impl.dart              # Internal singleton
├── example/
├── test/
└── .claude/
```

---

## Context Files
- `.claude/context/design-principles.md` — Four modes, graduation, anti-patterns
- `.claude/context/image-strategy.md` — Unsplash URL patterns, categories, fallback
- `.claude/context/api-contracts.md` — Complete locked API with signatures and dartdoc
