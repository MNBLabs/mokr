# /example — Example App

The example app is the primary marketing artifact.
Every screen demonstrates a real developer use case — not a feature checklist.

---

## App Structure
```
example/lib/
  main.dart
  screens/
    feed_screen.dart          # Paginated post feed
    explore_screen.dart       # Image category grid
    profile_screen.dart       # Full user profile
    playground_screen.dart    # Mode explorer — the key demo
  widgets/
    post_card.dart            # App's own post card (using Mokr data, not MokrPostCard)
```

Note: the example's own `post_card.dart` uses Mokr data API directly — this shows
developers how to use `Mokr.post()` in their own widgets, not just mokr's widgets.
Both approaches (data API + widget API) must be demonstrated.

---

## Screens

### Feed Screen
Use case: "I'm building a social feed. Give me 20 posts, paginated."
```dart
Mokr.feedPage('home_feed', page: 0, pageSize: 20)
```
- Infinite scroll that loads more via `feedPage(page: 1)`, `feedPage(page: 2)` etc.
- Uses the app's own `PostCard` widget with Mokr data
- Shows slot mode for the pinned "featured" card at top:
  ```dart
  Mokr.randomPost(slot: 'featured_card', pin: true)
  ```
- Pull-to-refresh: calls `Mokr.clearAll()` — fresh randoms regenerate, pinned ones stay

### Profile Screen
Use case: "I'm building a profile page. Give me a user and their posts."
```dart
final user = Mokr.user('profile_demo');
final posts = Mokr.feedPage('profile_demo_posts', page: 0, pageSize: 9);
```
- Banner: `MokrImage(seed: 'profile_banner', category: MokrCategory.nature, height: 180)`
- Avatar overlay: `MokrAvatar(seed: 'profile_demo', size: 72)`
- Stats row: followers, following, posts
- 3-column post grid using `MokrImage` for each

### Explore Screen
Use case: "I need a category-filtered image grid."
- Filter chips at top: one per MokrCategory
- Grid updates when category changes
- Each cell: `MokrImage(seed: 'explore_$i', category: selectedCategory)`
- Demonstrates all 15 categories

### Playground Screen (flagship — must be excellent)
Use case: "Show me exactly how the four modes work."

Divided into four labelled sections:

**Section 1 — Fresh Random**
```dart
MokrAvatar(size: 80)
```
A "Regenerate" button that calls `setState` — avatar changes every time.
Label: "No seed, no slot. Changes every rebuild."

**Section 2 — Slot Mode**
```dart
MokrAvatar(slot: 'playground_slot', size: 80)
```
A "Clear Slot" button → `Mokr.clearSlot('playground_slot')` → new random locks in.
Label: "Named slot. Stable until you clear it."

**Section 3 — Pinned Slot**
```dart
MokrAvatar(slot: 'playground_pin', pin: true, size: 80)
```
A "Try Clear All" button → `Mokr.clearAll()` → this one doesn't change.
A "Clear Pin" button → `Mokr.clearPin('playground_pin')` → now it can change.
Label: "Pinned. Survives clearAll()."

**Section 4 — Deterministic**
```dart
MokrAvatar(seed: 'demo_user_permanent', size: 80)
```
Show the name + seed string below it.
Label: "Seed in code. Never changes. No runtime state."

Below all four: a "What seed was that?" console-output display (shows last debug log line).

---

## pubspec.yaml for example
```yaml
name: mokr_example
dependencies:
  flutter:
    sdk: flutter
  mokr:
    path: ../
```
No other dependencies.

---

## Done When
- `flutter run` works without errors
- All four playground sections behave exactly as labelled
- Pull-to-refresh on feed screen: randoms refresh, pinned post stays
- Screenshots taken for README (all 4 screens)
