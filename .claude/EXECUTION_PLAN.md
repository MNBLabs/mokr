# mokr — Execution Plan

Publisher: MNBLabs (https://github.com/MNBLabs)
Collaborator: nishanbhuinya
Future: DynShift org (if promoted)

---

## Phase Map

| # | Command | Output | Gate |
|---|---|---|---|
| 0 | manual | scaffold + .claude setup | `flutter create` runs clean |
| 1 | `/plan` | `docs/architecture.md` | Nishan reviews + approves |
| 2 | `/arch` | `docs/api-design.md` | API locked before any code |
| 3 | `/implement` | `lib/src/core/`, `data/`, `images/` | `dart test test/core/` passes |
| 4 | `/widgets` | `lib/src/widgets/` | `flutter test test/widgets/` passes |
| 5 | `/example` | `example/` | `flutter run` works, all 4 screens |
| 6 | `/docs` | `README.md`, dartdocs | `dart doc` 0 warnings |
| 7 | `/pubdev` | pub.dev ready | `pana` 130/130 |

Run `/review` and `/test` at any phase to audit current state.

---

## Phase 0 — Bootstrap (manual)

```bash
flutter create --template=package mokr
cd mokr
# Drop .claude/ folder here
git init
git add .
git commit -m "chore: scaffold mokr package"
```

---

## The Four Modes — Quick Reference for Claude Sessions

Always remember these. Every implementation decision maps back here.

```
Mode 1 — Deterministic:  Mokr.user('seed')
Mode 2 — Slot:           Mokr.randomUser(slot: 'x')
Mode 3 — Pinned:         Mokr.randomUser(slot: 'x', pin: true)
Mode 4 — Fresh random:   Mokr.randomUser()

Graduation: Mode 4 → see console seed → Mode 1
```

---

## Estimated Timeline

| Phase | Sessions | Est. time |
|---|---|---|
| Bootstrap | manual | 20 min |
| Architecture | 1 | 20 min |
| API Design | 1 | 15 min |
| Core Impl | 3 | 3 hrs |
| Widgets | 2 | 1.5 hrs |
| Example | 2 | 2 hrs |
| Docs | 1 | 45 min |
| Pub.dev | 1 | 30 min |
| **Total** | ~11 | **~8 hrs** |

---

## v2 Backlog (do not implement in v1)
- MockComment + comment feed
- Video metadata mocking (Pexels source, no playback)
- MokrStory widget
- Locale-aware name generation (beyond word list diversity)
- `mokr.dynshift.com` landing page
