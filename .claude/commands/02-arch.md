# /arch — API Design Validation

Read `docs/architecture.md` and `.claude/context/api-contracts.md` before starting.

Your output: `docs/api-design.md`

This phase validates and finalises the API before any code is written.
You are NOT implementing. You are stress-testing the design.

---

## 1. Conflict Check
For every public method and widget, confirm:
- [ ] Exactly one of `seed`, `slot`, or neither is required — never more
- [ ] `pin` only makes sense with `slot` — assert this in the constructor
- [ ] No method duplicates what another already does
- [ ] Extension methods don't shadow stdlib String methods

## 2. Widget Parameter Audit
For each widget (MokrAvatar, MokrImage, MokrPostCard, MokrUserTile):
- List every parameter
- State whether it has a sensible default
- Flag any parameter a first-time user would find confusing
- Remove or rename anything unclear

## 3. Error Contract
Define what happens for every bad input:
| Input | Expected behaviour |
|---|---|
| `Mokr.user('')` | assert in debug, fallback seed in release (never reached due to release guard) |
| `Mokr.feedPage(..., pageSize: 0)` | return empty list |
| `Mokr.feedPage(..., pageSize: -1)` | assert |
| `Mokr.randomUser(slot: '', pin: true)` | assert — empty slot name invalid |
| `MokrAvatar(seed: 'x', slot: 'y')` | assert — cannot provide both |
| `Mokr.clearPin('non_existent')` | no-op, no error |

## 4. Slot Naming Guidance (for docs)
Write the guidance developers will see in README:
- Slot names should be unique per UI slot
- Recommended format: `'context_identifier'` e.g. `'feed_card_0'`, `'profile_header'`
- Avoid dynamic slot names based on index alone — `'card_$i'` in a ListView is fine
- Do not use the same slot name in two different widget instances

## 5. Graduation Flow — Final Spec
Write the exact steps as they will appear in README:
1. Start with fresh random → see console log
2. Copy seed from log
3. Two options: bake seed into code (full graduation) OR add slot (stable while working)
4. When ready: remove slot, use seed directly

## 6. MokrCategory Usage Guidance
Define which categories fit which UI contexts:
- Social feed: nature, travel, food, fashion, fitness, art
- Tech/productivity app: technology, office, abstract_
- E-commerce: product, interior, automotive
- General: architecture, pets, any

## 7. API Checklist
Implementation must pass all of these before Phase 3:
- [ ] All public symbols have dartdoc with at least one code example
- [ ] No public method returns Future<> (except init, clearSlot, clearPin, clearAll)
- [ ] All model classes are @immutable
- [ ] All widget constructors are const
- [ ] assert(seed == null || slot == null) in every widget that accepts both
- [ ] assert(!kReleaseMode) fires in Mokr.init()
- [ ] kDebugMode guard on all debug logging
- [ ] Extension methods do not conflict with String API

## 8. Semver Stability Contract
Define what is frozen at 1.0.0:
- Hash output for any seed string → must never change
- RNG consumption order → must never change
- Model field names → must never change without deprecation
- What CAN change in minor versions: new MokrCategory values, new widget parameters with defaults
