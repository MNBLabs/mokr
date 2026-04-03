# /docs — Documentation

Read the completed `lib/mokr.dart` and example app before writing.
Documentation is a product. A developer should understand mokr in 60 seconds of reading.

---

## README.md Structure

```
[badges: pub version | license | platform]

# mokr

Tagline — one line, value-first.

⚠️ Development only notice (prominent, top of file)

## The Problem (2 paragraphs max)
## Quick Start (install + 5-line example)
## The Four Modes
## Widgets
## Data API
## Image Categories
## The Graduation Flow
## Slot Management
## Custom Image Provider
## License
```

### Writing Rules

**Quick Start must be copy-pasteable and complete:**
```dart
void main() async {
  await Mokr.init();
  runApp(MyApp());
}

// In any widget:
MokrAvatar(seed: 'user_42', size: 48)
Image.network(Mokr.avatarUrl('user_42', size: 80))
final user = Mokr.user('user_42');
```

**The Four Modes section must show all four in one block:**
```dart
// 1. Deterministic — same always
Mokr.user('user_42')

// 2. Slot — random once, then stable
Mokr.randomUser(slot: 'card_1')

// 3. Pinned slot — stable + protected from clearAll()
Mokr.randomUser(slot: 'hero', pin: true)

// 4. Fresh random — throwaway, changes every call
Mokr.randomUser()
```

**The Graduation Flow must be numbered steps:**
```
1. Write Mokr.randomUser() — browse results
2. See result you like → console shows: [mokr] 🎲 fresh → seed: 'mokr_a7Be'
3. Copy that seed
4. Replace with: Mokr.user('mokr_a7Be') — frozen forever
```

**Development-only notice — must be prominent:**
```
> ⚠️ **For development and prototyping only.**  
> Do not use mokr in production apps or ship it to end users.  
> Images are sourced from Unsplash's public API.  
> mokr will assert and refuse to run in release builds.
```

---

## CHANGELOG.md
```markdown
# Changelog

## 0.1.0

### Added
- Deterministic mock users, posts, and paginated feeds
- Four generation modes: deterministic, slot, pinned slot, fresh random
- Slot persistence via SharedPreferences with pin protection
- Graduation flow with debug seed logging
- 15 image categories via Unsplash Source API
- Picsum fallback image provider
- MokrAvatar, MokrImage, MokrPostCard, MokrUserTile widgets
- Loading and error state customisation via builders
- Production release guard
- String extension methods: asMockUser, asMockPost, asAvatarUrl
```

---

## Dartdoc Audit
Run `dart doc .` — fix all warnings.
Confirm every public symbol has:
- One-sentence summary line
- At least one `/// ```dart` code example
- `@param` for non-obvious parameters

---

## pub.dev Score Pre-Check
- [ ] README > 500 words
- [ ] CHANGELOG follows Keep a Changelog
- [ ] pubspec.yaml has description (60-180 chars), homepage, repository, issue_tracker, topics
- [ ] LICENSE file is MIT
- [ ] `dart pub publish --dry-run` passes
