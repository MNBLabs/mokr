# mokr — API Design Validation

**Version:** 0.1.0  
**Date:** 2026-04-04  
**Status:** Pre-implementation validation

This document validates and finalises the API before code is written.
All conflicts, ambiguities, and edge cases are resolved here.

---

## 1. Conflict Check

### 1.1 Seed vs Slot Mutual Exclusion

Every widget and method that accepts both `seed` and `slot` must enforce mutual exclusion.

| Symbol | seed | slot | pin | Assertion required |
|---|---|---|---|---|
| `Mokr.user(seed)` | required | n/a | n/a | `assert(seed.isNotEmpty)` |
| `Mokr.randomUser({slot, pin})` | n/a | optional | optional | `assert(slot == null || slot.isNotEmpty)` |
| `Mokr.post(seed)` | required | n/a | n/a | `assert(seed.isNotEmpty)` |
| `Mokr.randomPost({slot, pin})` | n/a | optional | optional | `assert(slot == null || slot.isNotEmpty)` |
| `MokrAvatar({seed, slot, pin})` | optional | optional | optional | `assert(seed == null \|\| slot == null)` |
| `MokrImage({seed, slot, pin})` | optional | optional | optional | `assert(seed == null \|\| slot == null)` |
| `MokrPostCard({seed, slot, pin})` | optional | optional | optional | `assert(seed == null \|\| slot == null)` |
| `MokrUserTile({seed, slot, pin})` | optional | optional | optional | `assert(seed == null \|\| slot == null)` |

**Finding:** `MokrImage`, `MokrPostCard`, and `MokrUserTile` in api-contracts.md are missing
the `assert(seed == null || slot == null)` that `MokrAvatar` has.

**Resolution:** Add the assert to all four widget constructors:

```dart
const MokrImage({
  // ...
}) : assert(
       seed == null || slot == null,
       'Provide either seed or slot, not both.',
     );
```

### 1.2 Pin Only With Slot

`pin: true` is meaningless without `slot`. Assert this in every widget constructor:

```dart
const MokrAvatar({
  // ...
}) : assert(
       seed == null || slot == null,
       'Provide either seed or slot, not both.',
     ),
     assert(
       !pin || slot != null,
       'pin requires a slot name.',
     );
```

**Resolution:** Add this assert to all four widgets and to `Mokr.randomUser` / `Mokr.randomPost`:

```dart
static MockUser randomUser({String? slot, bool pin = false}) {
  assert(!pin || slot != null, 'pin requires a slot name.');
  assert(slot == null || slot.isNotEmpty, 'slot name cannot be empty.');
  // ...
}
```

### 1.3 Method Duplication Check

| Method | Purpose | Duplicates? |
|---|---|---|
| `Mokr.user(seed)` | Deterministic user from seed | No — only way to get deterministic user |
| `Mokr.randomUser({slot, pin})` | Random/slot-based user | No — only way to get slotted user |
| `Mokr.post(seed)` | Deterministic post from seed | No — only way to get deterministic post |
| `Mokr.randomPost({slot, pin})` | Random/slot-based post | No — only way to get slotted post |
| `Mokr.feedPage(seed, page, pageSize)` | Deterministic feed page | No — unique functionality |
| `Mokr.avatarUrl(seed, {size})` | Avatar URL from seed | No — URL-only method |
| `Mokr.imageUrl(seed, {category, width, height})` | Image URL from seed | No — URL-only method |
| `Mokr.bannerUrl(seed, {width, height})` | Banner URL from seed | Could merge with `imageUrl`? |

**Finding:** `bannerUrl` is just `imageUrl` with different defaults. However, keeping it separate
improves discoverability and documents intent. **Keep as-is.**

### 1.4 Extension Methods vs String API

| Extension | String API conflict? |
|---|---|
| `String.asMockUser` | No — String has no `asMockUser` |
| `String.asMockPost` | No — String has no `asMockPost` |
| `String.asAvatarUrl` | No — String has no `asAvatarUrl` |

**Result:** All extension methods are safe. No shadowing.

### 1.5 Init Signature Mismatch

**api-contracts.md (outdated):**
```dart
static Future<void> init({MokrImageProvider? imageProvider})
```

**architecture.md (current):**
```dart
static Future<void> init({
  String? unsplashKey,
  MokrImageProvider? imageProvider,
})
```

**Resolution:** Update api-contracts.md to match architecture.md. The `unsplashKey` parameter
was added for the dual-provider system (Picsum default, Unsplash opt-in).

---

## 2. Widget Parameter Audit

### 2.1 MokrAvatar

| Parameter | Type | Default | Sensible? | Notes |
|---|---|---|---|---|
| `key` | `Key?` | null | Yes | Standard Flutter |
| `seed` | `String?` | null | Yes | One of seed/slot/neither |
| `slot` | `String?` | null | Yes | One of seed/slot/neither |
| `pin` | `bool` | false | Yes | Only meaningful with slot |
| `size` | `double` | 48.0 | Yes | Common avatar size |
| `shape` | `MokrShape` | `.circle` | Yes | Most avatars are circular |
| `border` | `BoxBorder?` | null | Yes | Optional decoration |
| `onTap` | `VoidCallback?` | null | Yes | Optional interaction |
| `loadingBuilder` | `WidgetBuilder?` | null | Yes | Custom loading state |
| `errorBuilder` | `WidgetBuilder?` | null | Yes | Custom error state |

**Verdict:** All parameters are sensible. No changes needed.

### 2.2 MokrImage

| Parameter | Type | Default | Sensible? | Notes |
|---|---|---|---|---|
| `key` | `Key?` | null | Yes | Standard Flutter |
| `seed` | `String?` | null | Yes | One of seed/slot/neither |
| `slot` | `String?` | null | Yes | One of seed/slot/neither |
| `pin` | `bool` | false | Yes | Only meaningful with slot |
| `category` | `MokrCategory` | `.nature` | Yes | Common default |
| `width` | `double?` | null | **Unclear** | null means "expand to parent" |
| `height` | `double` | 200.0 | Yes | Reasonable content height |
| `fit` | `BoxFit` | `.cover` | Yes | Standard image fit |
| `borderRadius` | `BorderRadius?` | null | Yes | Optional rounding |
| `loadingBuilder` | `WidgetBuilder?` | null | Yes | Custom loading state |
| `errorBuilder` | `WidgetBuilder?` | null | Yes | Custom error state |

**Issue:** `width` is nullable (expand to parent) but `height` has a default. This asymmetry
could confuse users expecting both to behave the same way.

**Resolution:** Document clearly in dartdoc:
```dart
/// The width of the image. If null, expands to fill available width.
/// The height of the image. Defaults to 200.0 pixels.
```

The asymmetry is intentional: images typically fill width and have fixed height in feeds.
**Keep as-is, but add clarifying docs.**

### 2.3 MokrPostCard

| Parameter | Type | Default | Sensible? | Notes |
|---|---|---|---|---|
| `key` | `Key?` | null | Yes | Standard Flutter |
| `seed` | `String?` | null | Yes | One of seed/slot/neither |
| `slot` | `String?` | null | Yes | One of seed/slot/neither |
| `pin` | `bool` | false | Yes | Only meaningful with slot |
| `onTap` | `VoidCallback?` | null | Yes | Optional interaction |

**Issue:** Missing assert for seed/slot mutual exclusion.

**Resolution:** Add assert (see Section 1.1).

**Verdict:** Otherwise sensible. Minimal parameters for a composite widget.

### 2.4 MokrUserTile

| Parameter | Type | Default | Sensible? | Notes |
|---|---|---|---|---|
| `key` | `Key?` | null | Yes | Standard Flutter |
| `seed` | `String?` | null | Yes | One of seed/slot/neither |
| `slot` | `String?` | null | Yes | One of seed/slot/neither |
| `pin` | `bool` | false | Yes | Only meaningful with slot |
| `trailing` | `Widget?` | null | Yes | Common ListTile pattern |
| `onTap` | `VoidCallback?` | null | Yes | Optional interaction |

**Issue:** Missing assert for seed/slot mutual exclusion.

**Resolution:** Add assert (see Section 1.1).

**Verdict:** Otherwise sensible.

---

## 3. Error Contract

| Input | Expected Behaviour |
|---|---|
| `Mokr.user('')` | `assert(seed.isNotEmpty)` in debug. Never reached in release (release guard). |
| `Mokr.user('   ')` | Allowed — whitespace-only seed is technically valid. Produces deterministic output. |
| `Mokr.post('')` | `assert(seed.isNotEmpty)` in debug. |
| `Mokr.randomUser(slot: '')` | `assert(slot == null \|\| slot.isNotEmpty)` — empty slot is invalid. |
| `Mokr.randomUser(pin: true)` | `assert(!pin \|\| slot != null)` — pin requires slot. |
| `Mokr.randomUser(slot: null, pin: true)` | Same as above — assert fires. |
| `Mokr.feedPage('seed', pageSize: 0)` | Return `<MockPost>[]` — empty page is valid edge case. |
| `Mokr.feedPage('seed', pageSize: -1)` | `assert(pageSize >= 0)` in debug. |
| `Mokr.feedPage('seed', page: -1)` | `assert(page >= 0)` in debug. |
| `MokrAvatar(seed: 'x', slot: 'y')` | `assert(seed == null \|\| slot == null)` — cannot provide both. |
| `MokrAvatar(pin: true)` | `assert(!pin \|\| slot != null)` — pin requires slot. |
| `Mokr.clearSlot('non_existent')` | No-op. No error. Slot was already absent. |
| `Mokr.clearPin('non_existent')` | No-op. No error. |
| `Mokr.clearSlot('pinned_slot')` | No-op. Pinned slots require `clearPin`. |
| `Mokr.avatarUrl('')` | `assert(seed.isNotEmpty)` in debug. |
| `Mokr.imageUrl('seed', width: 0)` | `assert(width > 0)` in debug. |
| `Mokr.imageUrl('seed', height: -1)` | `assert(height > 0)` in debug. |
| Calling any Mokr method before `init()` | `assert(_initialised)` with message: "Call await Mokr.init() in main()". |
| Calling `Mokr.init()` in release mode | `assert(!kReleaseMode)` halts execution. |

### Assert Message Guidelines

All asserts should include a human-readable message:

```dart
assert(seed.isNotEmpty, 'Seed cannot be empty. Provide a non-empty string.');
assert(slot == null || slot.isNotEmpty, 'Slot name cannot be empty.');
assert(!pin || slot != null, 'pin: true requires a slot name.');
assert(seed == null || slot == null, 'Provide either seed or slot, not both.');
assert(pageSize >= 0, 'pageSize must be non-negative.');
assert(page >= 0, 'page must be non-negative.');
assert(_initialised, 'Call await Mokr.init() in main() before using mokr.');
assert(!kReleaseMode, 'mokr is for development only. Remove before release.');
```

---

## 4. Slot Naming Guidance

*This section will appear in README.md.*

### Naming Conventions

Slot names identify where mock data appears in your UI. Good slot names are:

1. **Unique per UI location** — no two widgets should share a slot name
2. **Descriptive** — indicate what the slot represents
3. **Stable** — don't change between runs

### Recommended Format

```
{context}_{identifier}
```

**Examples:**

| Slot name | Use case |
|---|---|
| `'profile_header'` | The profile page's header avatar |
| `'feed_card_0'` | First card in a feed list |
| `'feed_card_$index'` | Dynamic slot in ListView.builder |
| `'sidebar_user'` | User tile in sidebar |
| `'comment_author_$id'` | Comment author keyed by comment ID |

### Avoid

| Anti-pattern | Problem |
|---|---|
| `'card'` | Too generic — which card? |
| `'$index'` | Index alone — no context about where |
| `'user_${DateTime.now()}'` | Non-deterministic — changes every run |
| Same slot in two widgets | Both resolve to same data — probably wrong |

### Dynamic Slots in Lists

Using `'feed_card_$index'` in a `ListView.builder` is correct:

```dart
ListView.builder(
  itemBuilder: (ctx, index) => MokrPostCard(slot: 'feed_card_$index'),
)
```

Each index gets its own stable slot. On rebuild, index 0 still maps to the same seed.

### Pinning Favorites

When you find a result you like, add `pin: true`:

```dart
MokrAvatar(slot: 'hero', pin: true)
```

Pinned slots survive `Mokr.clearAll()`. Use `Mokr.clearPin('hero')` to explicitly remove.

---

## 5. Graduation Flow

*This section will appear in README.md.*

### The Graduation Path

mokr supports four modes, ordered from most volatile to most stable:

```
Fresh Random → Slot → Pinned Slot → Deterministic (graduated)
```

### Step-by-Step

**Step 1: Start with fresh random**

```dart
MokrAvatar(size: 48)  // no seed, no slot
```

Console output:
```
[mokr] 🎲 fresh → seed: 'mokr_a7Be'  (MokrAvatar)
```

**Step 2: See a result you like? Copy the seed from the console.**

The seed `'mokr_a7Be'` is your ticket to that exact result forever.

**Step 3: Choose your path**

**Option A — Graduate immediately (bake seed into code):**
```dart
MokrAvatar(seed: 'mokr_a7Be', size: 48)  // ← fully deterministic
```
No disk, no init required for this path. Same result on any device, forever.

**Option B — Slot it while you work:**
```dart
MokrAvatar(slot: 'hero', size: 48)  // ← stable during development
```
First call generates a seed, stores it. Every subsequent call returns the same result.

**Option C — Pin it to protect:**
```dart
MokrAvatar(slot: 'hero', pin: true, size: 48)  // ← survives clearAll()
```
Same as slot, but `Mokr.clearAll()` won't touch it.

**Step 4: When ready, graduate**

Replace `slot:` with the seed from the console log:

```dart
// Before (slotted):
MokrAvatar(slot: 'hero', size: 48)

// After (graduated):
MokrAvatar(seed: 'mokr_a7Be', size: 48)
```

### Why Graduate?

| Graduated (seed in code) | Slotted (seed on disk) |
|---|---|
| Zero runtime dependency | Requires `Mokr.init()` |
| Works without SharedPreferences | Needs SharedPreferences |
| Same result on any device | Same result on this device |
| Safe to commit to git | Seed lives in device storage |

---

## 6. MokrCategory Usage Guidance

*This section will appear in README.md.*

### Categories by App Type

**Social / content apps:**
| Category | Use for |
|---|---|
| `nature` | Landscape posts, outdoor content |
| `travel` | Destination photos, vacation content |
| `food` | Restaurant posts, recipe content |
| `fashion` | Outfit posts, style content |
| `fitness` | Workout posts, health content |
| `art` | Creative posts, gallery content |
| `face` | Avatars, profile photos (internal use) |

**Tech / productivity apps:**
| Category | Use for |
|---|---|
| `technology` | Device photos, tech content |
| `office` | Workspace photos, business content |
| `abstract_` | Backgrounds, decorative content |

**E-commerce / product apps:**
| Category | Use for |
|---|---|
| `product` | Product photos, lifestyle shots |
| `interior` | Room photos, home content |
| `automotive` | Vehicle photos, auto content |

**General purpose:**
| Category | Use for |
|---|---|
| `architecture` | Building photos, urban content |
| `pets` | Animal photos, pet content |

### Default Category

`MokrCategory.nature` is the default for `MokrImage` and `Mokr.imageUrl()`. It's a safe
choice for generic content that doesn't need a specific category.

### Category and Provider Behaviour

| Provider | Category behaviour |
|---|---|
| Picsum (default) | Category is folded into seed: `'post_1_nature'` vs `'post_1_food'` produce different images, but not category-specific |
| Unsplash (opt-in) | Real keyword search: `nature` returns actual nature photography |

With Picsum, categories provide **variation** — different categories produce different images
for the same seed. With Unsplash, categories provide **semantic matching** — the image content
matches the category keyword.

---

## 7. API Checklist

Implementation must pass all of these before Phase 3 (Core Implementation).

### Documentation

- [ ] All public symbols have dartdoc with at least one code example
- [ ] `Mokr` class has overview dartdoc explaining the four modes
- [ ] `MokrCategory` values have dartdoc suggesting use cases
- [ ] Extension methods have dartdoc showing usage
- [ ] README includes Quick Start, Graduation Flow, and Category Guide

### Type Safety

- [ ] All model classes (`MockUser`, `MockPost`) are `@immutable`
- [ ] All widget constructors are `const`
- [ ] No public method returns `Future<>` except:
  - `Mokr.init()`
  - `Mokr.clearSlot()`
  - `Mokr.clearPin()`
  - `Mokr.clearAll()`

### Assertions

- [ ] `assert(seed == null || slot == null)` in all widgets accepting both
- [ ] `assert(!pin || slot != null)` in all widgets/methods accepting pin
- [ ] `assert(seed.isNotEmpty)` in all deterministic methods
- [ ] `assert(slot == null || slot.isNotEmpty)` in all slot-accepting methods
- [ ] `assert(pageSize >= 0)` in `feedPage`
- [ ] `assert(page >= 0)` in `feedPage`
- [ ] `assert(width > 0)` and `assert(height > 0)` in URL methods
- [ ] `assert(!kReleaseMode)` fires in `Mokr.init()`
- [ ] `assert(_initialised)` fires in all public methods (except init)

### Debug Safety

- [ ] All `debugPrint` calls are guarded by `if (kDebugMode)`
- [ ] Zero logging output in release mode
- [ ] `assert(!kReleaseMode)` halts execution in release before any code runs

### Extension Methods

- [ ] `MokrStringExt` does not shadow any `String` API
- [ ] Extension is exported from the main barrel file
- [ ] Extension works on `const` strings

### Architecture Compliance

- [ ] `SeedHash.hash` uses FNV-1a 32-bit (not `String.hashCode`)
- [ ] RNG consumption order matches Section 5 of architecture.md
- [ ] `MokrImageProvider` interface matches architecture.md Section 7
- [ ] `init()` signature: `{String? unsplashKey, MokrImageProvider? imageProvider}`

---

## 8. Semver Stability Contract

### Frozen at 1.0.0

The following MUST NOT change without a major version bump:

| Contract | Reason |
|---|---|
| `SeedHash.hash(input)` output | Any change breaks all existing seeds |
| RNG consumption order (Section 5) | Changes which data a seed produces |
| `MockUser` field names | Breaking change for code using the model |
| `MockPost` field names | Breaking change for code using the model |
| `MokrCategory` enum values (existing) | Breaking change for code using categories |
| Reference date `DateTime(2026, 1, 1)` | Changes all generated timestamps |
| Seed format `mokr_[A-Za-z0-9]{4}` | May break slot registry parsing |

### May Change in Minor Versions

| Change | Allowed? | Notes |
|---|---|---|
| Add new `MokrCategory` values | Yes | Append only, existing values stable |
| Add new widget parameters with defaults | Yes | Non-breaking addition |
| Add new `MockUser` / `MockPost` fields | Yes | Existing fields unchanged |
| Add new computed getters | Yes | Pure additions |
| Add new static methods to `Mokr` | Yes | Non-breaking |
| Improve data table diversity | Yes | Add names, bios, captions |
| Change default image provider | No | Would change URLs for existing seeds |

### May Change in Patch Versions

| Change | Allowed? | Notes |
|---|---|---|
| Bug fixes | Yes | Standard semver |
| Documentation improvements | Yes | No API changes |
| Internal refactoring | Yes | Public API unchanged |
| Performance improvements | Yes | Behaviour unchanged |

### Pre-1.0.0 Stability

During 0.x development, any of the above may change. The stability contract takes effect
at 1.0.0 release.

---

## 9. API Contracts Update Required

The following changes must be applied to `.claude/context/api-contracts.md` before implementation:

### 9.1 Update `init()` Signature

```dart
/// Initialises mokr. Call once in [main()] before [runApp()].
///
/// ```dart
/// // Zero config — uses Picsum:
/// await Mokr.init();
///
/// // With Unsplash (real category filtering):
/// await Mokr.init(unsplashKey: 'your_api_key');
/// ```
static Future<void> init({
  String? unsplashKey,
  MokrImageProvider? imageProvider,
})
```

### 9.2 Add Asserts to Widget Constructors

All four widgets need both asserts:

```dart
const MokrImage({
  super.key,
  this.seed,
  this.slot,
  this.pin = false,
  // ...
}) : assert(
       seed == null || slot == null,
       'Provide either seed or slot, not both.',
     ),
     assert(
       !pin || slot != null,
       'pin requires a slot name.',
     );
```

### 9.3 Update Image Provider Interface

The `MokrImageProvider` interface now includes `MokrCategory`:

```dart
abstract class MokrImageProvider {
  String avatarUrl(String seed, MokrCategory category, {int size = 80});
  String imageUrl(String seed, MokrCategory category, {int width = 400, int height = 300});
  String bannerUrl(String seed, MokrCategory category, {int width = 800, int height = 300});
}
```

Public `Mokr` methods still have category as optional (defaulting to `.nature` or `.face`
for avatars), but the provider interface always receives it.

### 9.4 Clarify `avatarUrl` Category Handling

`Mokr.avatarUrl()` should always pass `MokrCategory.face` to the provider:

```dart
static String avatarUrl(String seed, {int size = 80}) {
  return _provider.avatarUrl(seed, MokrCategory.face, size: size);
}
```

This is internal — the public signature remains `avatarUrl(String seed, {int size})`.
Users don't need to know avatars use the `face` category.

---

## 10. Summary of Required Changes

| Document | Change | Section |
|---|---|---|
| api-contracts.md | Update `init()` signature | Setup |
| api-contracts.md | Add asserts to `MokrImage`, `MokrPostCard`, `MokrUserTile` | Widgets |
| api-contracts.md | Update `MokrImageProvider` interface | (new section needed) |
| api-contracts.md | Add assert message guidelines | (new section needed) |
| CLAUDE.md | No changes needed | — |
| architecture.md | No changes needed (already current) | — |
