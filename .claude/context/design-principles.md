# Design Principles — mokr

## The One Rule
Same input → same output.
If something can produce a different result without the developer explicitly asking for it, it is a bug.

---

## The Four Modes in Detail

### Why Four Modes Exist
Developers work at different stages:

| Stage | Need | Mode |
|---|---|---|
| Sketching | "Just put something here" | Fresh random |
| Stabilising | "Stop flickering while I work" | Slot |
| Decided | "I want THIS one, always" | Pinned slot or graduation |
| Production-ready | "Bake it into the code" | Deterministic |

Every mode solves a stage. None overlap.

---

## The Slot Registry — How It Works

SlotRegistry is an internal singleton backed by SharedPreferences.
It holds a `Map<String, String>` where key = slot name, value = generated seed.
A separate `Set<String>` tracks which slots are pinned.

```
On Mokr.init():
  → load map from SharedPreferences
  → load pinned set from SharedPreferences

On Mokr.randomUser(slot: 'x'):
  → check map for 'x'
  → if found: return Mokr.user(map['x'])         // stable result
  → if not found: generate seed → store → return  // first-time random

On Mokr.randomUser(slot: 'x', pin: true):
  → same as above, but also adds 'x' to pinned set

On Mokr.clearAll():
  → remove all keys NOT in pinned set
  → persist to disk

On Mokr.clearPin('x'):
  → remove 'x' from pinned set AND from map
  → persist to disk
```

### Persistence
SharedPreferences keys:
- `mokr_slots` — JSON map of slot name → seed string
- `mokr_pins` — JSON list of pinned slot names

Both are written on every change. Read once on `Mokr.init()`.

---

## The Graduation Path
Graduation = moving from any mode to Mode 4 (deterministic, seed in code).
This is the exit from runtime dependency on disk/map.

### Why Graduate?
- No `Mokr.init()` needed
- Works on any device, any install, forever
- Safe to commit — seed is just a string
- Zero runtime overhead beyond hash computation

### How to Graduate

1. Use fresh random while exploring:
   ```dart
   MokrAvatar(size: 48)
   // [mokr] 🎲 fresh → seed: 'mokr_a7Be'
   ```

2. See a result you like — copy seed from console.

3. Either:
   - Bake it into code immediately:
     ```dart
     MokrAvatar(seed: 'mokr_a7Be', size: 48)  // graduated ✓
     ```
   - Or slot it to preserve while you keep working:
     ```dart
     MokrAvatar(slot: 'hero', size: 48, pin: true)
     // keeps result stable, log still shows the seed
     // graduate later when ready
     ```

---

## API Simplicity Rules

1. **One line to use.** If a use case requires two lines, redesign.
2. **No required configuration** — except `Mokr.init()` in `main()`. Everything else optional.
3. **Behaviour from parameters, not separate classes.**
   - `MokrAvatar(seed:)` vs `MokrAvatar(slot:)` vs `MokrAvatar()` — ONE widget, THREE behaviours.
   - Never: `MokrDeterministicAvatar` + `MokrRandomAvatar` + `MokrSlottedAvatar`.
4. **Progressive disclosure** — simplest use reveals nothing about the deeper system.
   ```dart
   MokrAvatar(size: 48) // works, zero knowledge required
   ```

---

## Anti-Patterns — Banned

| Pattern | Why |
|---|---|
| `Random()` without seed | Non-deterministic |
| `hashCode` for seeding | Not stable across Dart VM restarts |
| `DateTime.now()` in data generation | Changes per call |
| `List.shuffle()` without seeded RNG | Non-deterministic ordering |
| Separate classes per mode | Redundant, confusing API surface |
| `Future<>` in URL generation | Breaks inline widget use |
| Any network call during URL construction | Breaks offline dev |
| `print()` in package code | Use `debugPrint()` + `kDebugMode` guard |
| Running in release mode | Hard assert, non-negotiable |

---

## Consumption Order Contract

When generating a MockUser from a seed, the SeededRng must consume values in this exact order.
Changing this order = breaking change. Never change without a major version bump.

```
Position 1  → first name index
Position 2  → last name index
Position 3  → bio length (1–3 sentences)
Position 4+ → bio phrase indices (variable, = bio length count)
Position N  → follower count (power-law)
Position N+1 → following count
Position N+2 → post count
Position N+3 → isVerified (probability: 0.04)
Position N+4 → joinedAt (days ago, recency-weighted)
```

For MockPost:
```
Position 1  → author seed derivation offset
Position 2  → caption length
Position 3+ → caption phrase indices
Position M  → hasImage (probability: 0.80)
Position M+1 → imageCategory index
Position M+2 → likeCount (normal distribution)
Position M+3 → commentCount
Position M+4 → shareCount
Position M+5 → isLiked (probability: 0.30)
Position M+6 → createdAt (recency-weighted)
Position M+7 → tag count (0–5)
Position M+8+ → tag indices
```
