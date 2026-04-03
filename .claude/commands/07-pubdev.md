# /pubdev — Pub.dev Polish

Run in order. Fix every issue before the next step.

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos lib/
flutter test
dart pub global activate pana
pana --no-warning .
dart pub publish --dry-run
```

Target: 130/130 pub points.

---

## pubspec.yaml Final State
```yaml
name: mokr
description: >-
  Realistic mock data and images for Flutter UI development.
  Stable users, posts, feeds, and images with deterministic seeding.
  For development and prototyping only.
version: 0.1.0
homepage: https://mokr.dynshift.com
repository: https://github.com/MNBLabs/mokr
issue_tracker: https://github.com/MNBLabs/mokr/issues
documentation: https://pub.dev/documentation/mokr/latest/
topics:
  - mock
  - ui
  - flutter
  - fake-data
  - testing
platforms:
  android:
  ios:
  web:
  macos:
  linux:
  windows:
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.0
```

---

## README Hero (first 500 chars — what pub.dev shows in search)
Must contain:
1. Package name + tagline in first line
2. Code example within first fold
3. Development-only notice visible without scrolling
4. Badges

---

## Final Human Check
Install mokr in a fresh Flutter project:
```bash
flutter create test_mokr_install
cd test_mokr_install
flutter pub add mokr
```
Copy the Quick Start from README exactly. Run it.
If anything fails, fix the README or the package.

---

## Versioning Plan
| Version | Milestone |
|---|---|
| 0.1.0 | Initial release — four modes, 15 categories, 4 widgets |
| 0.1.x | Bug fixes, no API changes |
| 0.2.0 | MockComment, MokrStory widget, video metadata (Pexels v2) |
| 1.0.0 | Semver stability locked — hash output guaranteed forever |

Do NOT publish 1.0.0 until the determinism contract is battle-tested in the wild.
