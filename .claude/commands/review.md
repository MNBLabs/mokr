# /review — Code Review

## Determinism Audit (run first)
Scan every file in `lib/src/` for:
- [ ] `Random()` without a seed → fail
- [ ] `DateTime.now()` outside of explicitly random helpers → fail
- [ ] `List.shuffle()` without seeded RNG → fail
- [ ] `hashCode` used for seeding (not stable across VM restarts) → fail
- [ ] Any network call during URL construction → fail

## Mode Integrity Check
- [ ] `Mokr.user(seed)` never touches SlotRegistry
- [ ] `Mokr.randomUser()` with no params never writes to disk
- [ ] `Mokr.randomUser(slot: x)` always writes to disk on first call
- [ ] `Mokr.randomUser(slot: x, pin: true)` adds x to pinned set
- [ ] `Mokr.clearAll()` skips pinned slots
- [ ] `Mokr.clearPin(x)` removes from both map and pinned set

## Widget Check
- [ ] Every widget has `assert(seed == null || slot == null)` where both exist
- [ ] No widget makes a network call directly
- [ ] `MokrShimmer` is NOT in the public export
- [ ] All widget constructors are `const`

## API Surface Check
- [ ] Only `lib/mokr.dart` needs to be imported by the developer
- [ ] No `src/` file is exported directly
- [ ] Every public method has a dartdoc with code example

## Release Guard Check
- [ ] `assert(!kReleaseMode, ...)` fires in `Mokr.init()`
- [ ] Zero `debugPrint` or `[mokr]` logs when `kDebugMode == false`

## Output Format
```
# Review Report — mokr
Date: [date]

✅ Passed: [n items]
⚠️  Warnings: [list]
❌ Must Fix: [list with file:line references]
```
